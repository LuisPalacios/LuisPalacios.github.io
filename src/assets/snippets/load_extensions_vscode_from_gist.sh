#!/bin/bash
# Reinstalar extensiones de VSCode desde Gist
# Autor: Luis Palacios
# Gist: https://gist.github.com/LuisPalacios/9bccecf260cf4cc73d74fe9d500f7e94
#
# Uso: ./load_extensions_vscode_from_gist.sh [opciones] [binario]
# Ejemplos:
#   ./load_extensions_vscode_from_gist.sh           # Usa 'code' por defecto
#   ./load_extensions_vscode_from_gist.sh cursor
#   ./load_extensions_vscode_from_gist.sh --sync    # Sincroniza (ofrece borrar extras)
#   ./load_extensions_vscode_from_gist.sh --sync cursor

# Configuración
GIST_URL="https://gist.githubusercontent.com/LuisPalacios/9bccecf260cf4cc73d74fe9d500f7e94/raw/"
SYNC_MODE=false
CODE_BIN="code"

# Función para mostrar ayuda
show_help() {
    cat << EOF
Uso: $(basename "$0") [opciones] [binario]

Instala extensiones de VSCode desde un Gist de GitHub.

OPCIONES:
    --help, -h      Muestra esta ayuda
    --sync          Sincroniza extensiones (ofrece eliminar las que no están en el gist)

ARGUMENTOS:
    binario         Comando del editor (por defecto: code)
                    Ejemplos: code, cursor, antigravity, code-insiders

EJEMPLOS:
    $(basename "$0")                  # Instala extensiones faltantes usando 'code'
    $(basename "$0") cursor           # Instala extensiones faltantes usando 'cursor'
    $(basename "$0") --sync           # Sincroniza extensiones usando 'code'
    $(basename "$0") --sync cursor    # Sincroniza extensiones usando 'cursor'

GIST:
    https://gist.github.com/LuisPalacios/9bccecf260cf4cc73d74fe9d500f7e94

AUTOR:
    Luis Palacios
EOF
    exit 0
}

# Procesar argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        --help|-h)
            show_help
            ;;
        --sync)
            SYNC_MODE=true
            shift
            ;;
        -*)
            echo "Error: Opción desconocida '$1'" >&2
            echo "Usa '$(basename "$0") --help' para ver las opciones disponibles." >&2
            exit 1
            ;;
        *)
            CODE_BIN="$1"
            shift
            ;;
    esac
done

# Verificar que el binario existe
if ! command -v "$CODE_BIN" &> /dev/null; then
    echo "Error: El comando '$CODE_BIN' no está disponible." >&2
    echo "Usa '$(basename "$0") --help' para ver las opciones disponibles." >&2
    exit 1
fi

echo "Usando binario: $CODE_BIN"
[[ "$SYNC_MODE" == true ]] && echo "Modo sincronización: activado"
echo "Obteniendo extensiones instaladas actualmente..."

# Obtener lista de extensiones instaladas (compatible con bash 3.x)
installed=()
while IFS= read -r line; do
    [[ -n "$line" ]] && installed+=("$line")
done < <("$CODE_BIN" --list-extensions)

echo "Extensiones instaladas: ${#installed[@]}"
echo ""
echo "Descargando lista de extensiones desde gist..."

# Descargar el contenido del gist (con cache buster para evitar versiones antiguas)
gist_content=$(curl -sL "${GIST_URL}?_=$(date +%s)")

if [[ -z "$gist_content" ]]; then
    echo "Error: No se pudo descargar el contenido del gist." >&2
    exit 1
fi

# Crear arrays para tracking
declare -a to_install=()
declare -a already_installed=()
declare -a gist_extensions=()

# Leer todas las extensiones del gist
while IFS= read -r ext; do
    # Saltar líneas vacías y comentarios
    [[ -z "$ext" || "$ext" =~ ^[[:space:]]*# ]] && continue

    # Limpiar espacios en blanco
    ext=$(echo "$ext" | xargs)

    [[ -z "$ext" ]] && continue

    gist_extensions+=("$ext")
done <<< "$gist_content"

# Comparar instaladas vs gist
for ext in "${installed[@]}"; do
    if printf '%s\n' "${gist_extensions[@]}" | grep -q "^${ext}$"; then
        already_installed+=("$ext")
    fi
done

# Determinar cuáles instalar
for ext in "${gist_extensions[@]}"; do
    if ! printf '%s\n' "${installed[@]}" | grep -q "^${ext}$"; then
        to_install+=("$ext")
    fi
done

# Determinar cuáles son extra (solo en modo sync)
declare -a to_remove=()
if [[ "$SYNC_MODE" == true ]]; then
    for ext in "${installed[@]}"; do
        if ! printf '%s\n' "${gist_extensions[@]}" | grep -q "^${ext}$"; then
            to_remove+=("$ext")
        fi
    done
fi

# Mostrar resumen
echo ""
echo "=== RESUMEN ==="
echo "Extensiones en el gist: ${#gist_extensions[@]}"
echo "Ya instaladas: ${#already_installed[@]}"
echo "Por instalar: ${#to_install[@]}"
[[ "$SYNC_MODE" == true ]] && echo "Extra (no en gist): ${#to_remove[@]}"
echo ""

# Crear lista unificada (compatible con bash 3.x - sin arrays asociativos)
# Combinar y ordenar todas las extensiones únicas
all_exts_list=$(printf '%s\n' "${gist_extensions[@]}" "${installed[@]}" | sort -u)

echo "Extensiones:"
while IFS= read -r ext; do
    [[ -z "$ext" ]] && continue

    printf "  - %-50s" "$ext"

    # Determinar estado de la extensión
    in_gist=false
    in_installed=false

    for g in "${gist_extensions[@]}"; do
        [[ "$g" == "$ext" ]] && in_gist=true && break
    done

    for i in "${installed[@]}"; do
        [[ "$i" == "$ext" ]] && in_installed=true && break
    done

    # Mostrar estado
    if [[ "$in_gist" == true && "$in_installed" == true ]]; then
        echo "Está en Gist  - ✅ Ya instalada"
    elif [[ "$in_gist" == true && "$in_installed" == false ]]; then
        echo "Está en Gist  - ⚠️  Pendiente de instalarse"
    elif [[ "$in_gist" == false && "$in_installed" == true ]]; then
        if [[ "$SYNC_MODE" == true ]]; then
            echo "No en Gist    - ℹ️  Se va a desinstalar (--sync)"
        else
            echo "No en Gist    - ℹ️  Usa --sync para desinstalarla"
        fi
    fi
done <<< "$all_exts_list"
echo ""

# Instalar las que faltan
if [[ ${#to_install[@]} -gt 0 ]]; then
    echo "↓ Instalando extensiones faltantes..."
    echo ""

    declare -a failed_installs=()

    for ext in "${to_install[@]}"; do
        printf "Instalando: %-38s " "$ext"

        # Capturar salida y código de error
        output=$("$CODE_BIN" --install-extension "$ext" 2>&1)
        exit_code=$?

        if [[ $exit_code -eq 0 ]]; then
            printf "\033[32m[Ok]\033[0m\n"
        else
            # Determinar causa del error y mostrar en la misma línea
            if echo "$output" | grep -qi "not found"; then
                printf "\033[31m[Error]\033[0m - No disponible en el marketplace de %s\n" "$CODE_BIN"
            elif echo "$output" | grep -qi "network\|timeout\|ENOTFOUND"; then
                printf "\033[31m[Error]\033[0m - Error de conectividad\n"
            elif echo "$output" | grep -qi "already installed"; then
                printf "\033[33m[Advertencia]\033[0m - Ya instalada\n"
            else
                printf "\033[31m[Error]\033[0m - Falló la instalación\n"
            fi

            failed_installs+=("$ext")
        fi
    done

    echo ""

    if [[ ${#failed_installs[@]} -eq 0 ]]; then
        echo "✓ Instalación completa."
    else
        echo "⚠️  Instalación completada con ${#failed_installs[@]} errores."
    fi
else
    echo "✓ Todas las extensiones ya están instaladas."
fi

# Ofrecer desinstalar extensiones extra (solo en modo sync)
if [[ "$SYNC_MODE" == true && ${#to_remove[@]} -gt 0 ]]; then
    echo ""
    echo "⚠️  EXTENSIONES NO PRESENTES EN EL GIST:"
    for ext in "${to_remove[@]}"; do
        echo "  - $ext"
    done
    echo ""
    read -p "¿Deseas desinstalar estas extensiones? (s/N): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        echo ""
        echo "↓ Desinstalando extensiones extra..."
        echo ""

        declare -a failed_uninstalls=()

        for ext in "${to_remove[@]}"; do
            printf "Desinstalando: %-35s " "$ext"

            # Capturar salida y código de error
            output=$("$CODE_BIN" --uninstall-extension "$ext" 2>&1)
            exit_code=$?

            if [[ $exit_code -eq 0 ]]; then
                printf "\033[32m[Ok]\033[0m\n"
            else
                # Determinar causa del error y mostrar en la misma línea
                if echo "$output" | grep -qi "not installed\|not found"; then
                    printf "\033[31m[Error]\033[0m - No está instalada\n"
                else
                    printf "\033[31m[Error]\033[0m - Falló la desinstalación\n"
                fi

                failed_uninstalls+=("$ext")
            fi
        done

        echo ""

        if [[ ${#failed_uninstalls[@]} -eq 0 ]]; then
            echo "✓ Desinstalación completa."
        else
            echo "⚠️  Desinstalación completada con errores (${#failed_uninstalls[@]} fallidas)."
        fi
    else
        echo "Desinstalación cancelada."
    fi
fi
