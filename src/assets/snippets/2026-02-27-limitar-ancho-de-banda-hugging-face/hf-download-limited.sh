#!/usr/bin/env bash
# hf-download-limited.sh
#
# Descarga un modelo de Hugging Face con ancho de banda limitado.
# Usa Docker + tc aplicado desde el host en la interfaz veth del contenedor.
#
# Requiere: docker, sudo (para tc), iproute2 en el host

set -euo pipefail

CONTAINER="hf-dl-$$"
LATENCY="400ms"

# ─── Ayuda ────────────────────────────────────────────────────
usage() {
    cat <<'EOF'
Uso: hf-download-limited.sh -m MODEL -d DIR [-b BANDWIDTH]

Descarga un modelo de Hugging Face limitando el ancho de banda
mediante Docker + tc (Traffic Control).

Argumentos obligatorios:
  -m, --model MODEL       Modelo de Hugging Face (ej: usuario/modelo)
  -d, --dir   DIR         Directorio local donde guardar el modelo

Argumentos opcionales:
  -b, --bandwidth MBIT    Ancho de banda máximo en Mbps (default: 600)
  -t, --token TOKEN       Token de Hugging Face (o usa env HF_TOKEN)
  -h, --help              Muestra esta ayuda

Ejemplo:
  ./hf-download-limited.sh \
    -m "Sehyo/Qwen3.5-122B-A10B-NVFP4" \
    -d "/home/luis/tmp/Qwen3.5-122B-A10B-NVFP4" \
    -b 600
EOF
    exit "${1:-0}"
}

# ─── Parseo de argumentos ────────────────────────────────────
MODEL=""
LOCAL_DIR=""
RATE_MBIT=600

while [[ $# -gt 0 ]]; do
    case "$1" in
        -m|--model)     MODEL="$2";    shift 2 ;;
        -d|--dir)       LOCAL_DIR="$2"; shift 2 ;;
        -b|--bandwidth) RATE_MBIT="$2"; shift 2 ;;
        -t|--token)     HF_TOKEN="$2"; shift 2 ;;
        -h|--help)      usage 0 ;;
        *)              echo "Error: argumento desconocido '$1'"; usage 1 ;;
    esac
done

if [[ -z "$MODEL" || -z "$LOCAL_DIR" ]]; then
    echo "Error: -m MODEL y -d DIR son obligatorios."
    echo ""
    usage 1
fi

# ─── Calcular parámetros de tc ────────────────────────────────
# burst = 2% del rate, mínimo 1 mbit (suficiente para kernels con HZ=250..1000)
RATE="${RATE_MBIT}mbit"
BURST_MBIT=$(( RATE_MBIT / 50 ))
if (( BURST_MBIT < 1 )); then
    BURST_MBIT=1
fi
BURST="${BURST_MBIT}mbit"

# ─── Limpieza al salir (Ctrl+C, error, etc.) ─────────────────
cleanup() {
    echo ""
    echo "--- Limpiando ---"
    docker stop "$CONTAINER" 2>/dev/null || true
    echo "Contenedor eliminado."
}
trap cleanup EXIT

# 1. Lanzar contenedor en segundo plano
echo "--- Iniciando contenedor ---"
HF_TOKEN_ARGS=()
if [[ -n "${HF_TOKEN:-}" ]]; then
    HF_TOKEN_ARGS=(-e "HF_TOKEN=$HF_TOKEN")
fi

docker run -d --rm --name "$CONTAINER" \
    -v "$(dirname "$LOCAL_DIR"):$(dirname "$LOCAL_DIR")" \
    -e DEBIAN_FRONTEND=noninteractive \
    "${HF_TOKEN_ARGS[@]}" \
    python:3.10-slim \
    sleep infinity > /dev/null

# 2. Instalar huggingface_hub dentro del contenedor
echo "--- Instalando huggingface_hub ---"
docker exec "$CONTAINER" pip install -qqq -U huggingface_hub

# 3. Encontrar la interfaz veth en el host
IFLINK=$(docker exec "$CONTAINER" cat /sys/class/net/eth0/iflink)
VETH=$(ip -o link | awk -v idx="$IFLINK" '$1 == idx":" {print $2}' | sed 's/@.*//')

if [[ -z "$VETH" ]]; then
    VETH=$(ip -o link | grep "^${IFLINK}: " | awk '{print $2}' | sed 's/@.*//' | sed 's/://')
fi

if [[ -z "$VETH" ]]; then
    echo "ERROR: No se encontró la interfaz veth para iflink=$IFLINK"
    exit 1
fi

# 4. Aplicar tc (Token Bucket Filter) en la veth del host
echo "--- Aplicando tc en $VETH: rate=$RATE burst=$BURST ---"
sudo tc qdisc add dev "$VETH" root tbf \
    rate "$RATE" burst "$BURST" latency "$LATENCY"

# 5. Lanzar la descarga (-it para barra de progreso)
echo ""
echo "=== Descargando $MODEL ==="
echo "=== Destino: $LOCAL_DIR ==="
echo "=== Límite: ${RATE_MBIT} Mbps ==="
echo ""
docker exec -it -e "PYTHONWARNINGS=ignore::UserWarning" "${HF_TOKEN_ARGS[@]}" "$CONTAINER" \
    hf download "$MODEL" --local-dir "$LOCAL_DIR"

echo ""
echo "=== Descarga completada ==="
