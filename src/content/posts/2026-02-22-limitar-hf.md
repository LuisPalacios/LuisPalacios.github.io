---
title: "Limitar ancho de banda Hugging Face"
date: "2026-02-22"
categories: ["software"]
tags:
  ["hugging-face", "docker", "linux", "bandwidth", "tc", "llm", "wondershaper"]
draft: false
cover:
  image: "/img/posts/logo-shaping.svg"
  hidden: true
---

<img src="/img/posts/logo-shaping.svg" alt="Logo Limitar ancho de banda" width="150px" height="150px" style="float:left; padding-right:25px" />

Descargar modelos LLM en local es algo que se hace de vez en cuando, pero cuando te bajas un modelo masivo de 122B parámetros como `Sehyo/Qwen3.5-122B-A10B-NVFP4`, la descarga copa toda la conexión y deja al resto de la casa sin red. El CLI de Hugging Face (`huggingface-cli` o `hf`) no tiene un flag `--limit-rate`, así que toca buscar alternativas. En este apunte explico dos formas de limitar el ancho de banda en Linux usando Docker (mi preferida) o Wondershaper a nivel de host.

<br clear="left"/>
<!--more-->

## El problema

Tengo una conexión de fibra de 1 Gbps en casa. Cuando lanzo una descarga masiva desde Hugging Face, el CLI intenta usar todo el ancho de banda disponible. Eso significa que mientras se descarga un modelo de más de 70GB, nadie más en casa puede navegar o trabajar con normalidad.

Lo lógico sería que `huggingface-cli` tuviese un flag tipo `--limit-rate` como tiene `curl`, así que la solución pasa por limitar el ancho de banda a nivel de red, fuera de la herramienta.

## Método 1: Docker (recomendado)

La idea es levantar un contenedor Docker para la descarga y limitar su tráfico de red con `tc` (Traffic Control de Linux). De esta forma la conexión del host queda intacta y el resto de dispositivos no se ven afectados.

### Por qué tc desde el host y no desde dentro del contenedor

El primer impulso es ejecutar `tc` dentro del propio contenedor, aplicando un Token Bucket Filter (TBF) en su `eth0`. El problema es que `tc` en modo `root qdisc` solo limita el tráfico de **salida (egress)**. Las descargas son tráfico de **entrada (ingress)**, así que el límite no les afecta. Probé también un `ingress policer` dentro del contenedor, pero TCP compensa los paquetes descartados y la limitación real es mínima.

La solución que funciona es aplicar `tc` **desde el host** en la interfaz `veth` que Docker crea para el contenedor. Desde la perspectiva del host, el tráfico que envía hacia el contenedor es **egress**, y ahí sí funciona el TBF perfectamente.

### El script `hf-download-limited.sh`

He creado un script que automatiza todo el proceso:

{{< codefile path="snippets/2026-02-27-limitar-ancho-de-banda-hugging-face/hf-download-limited.sh" lang="bash" title="hf-download-limited.sh" >}}

Ejecútalo pasándole el modelo y el directorio de destino:

```bash
chmod +x hf-download-limited.sh
./hf-download-limited.sh \
    -m "Sehyo/Qwen3.5-122B-A10B-NVFP4" \
    -d "/home/luis/tmp/Qwen3.5-122B-A10B-NVFP4" \
    -b 600
```

El flag `-b` permite ajustar el límite de ancho de banda en Mbps (por defecto 600). Si tienes un token de Hugging Face puedes pasarlo con `-t` para obtener descargas más rápidas y rate limits más altos.

### Qué hace el script paso a paso

1. **Parsea los argumentos** (`-m` modelo, `-d` directorio, `-b` bandwidth, `-t` token) y calcula automáticamente el `burst` del Token Bucket Filter a partir del bandwidth.
2. **Lanza un contenedor** con `sleep infinity` en segundo plano e instala `huggingface_hub` dentro.
3. **Busca la interfaz veth** en el host. Cada contenedor Docker tiene una interfaz `eth0` interna que está conectada a una `veth` en el host. El script lee el `iflink` del contenedor y busca la interfaz correspondiente con `ip -o link`.
4. **Aplica `tc` desde el host** en esa `veth`. Un Token Bucket Filter (TBF) limita el tráfico que el host envía al contenedor, es decir, las descargas.
5. **Ejecuta `hf download`** dentro del contenedor con `-it` para ver la barra de progreso.
6. **Limpia al terminar**. Un `trap cleanup EXIT` se encarga de parar el contenedor si la descarga termina, falla, o haces Ctrl+C.

La salida es limpia:

```text
--- Iniciando contenedor ---
--- Instalando huggingface_hub ---
--- Aplicando tc en vethe4845c6: rate=600mbit burst=12mbit ---

=== Descargando Sehyo/Qwen3.5-122B-A10B-NVFP4 ===
=== Destino: /home/luis/tmp/Qwen3.5-122B-A10B-NVFP4 ===
=== Límite: 600 Mbps ===

Fetching 15 files:  47%|████▋     | 7/15 [02:30<03:00, ...]
```

Cuando la descarga termina, el contenedor desaparece y con él todas las restricciones de red. El sistema queda limpio sin necesidad de hacer nada más.

<div class="image-box">
  <img src="/img/posts/2026-02-22-limitar-hf.png" alt="Limitar ancho de banda en las descargas de Huggingface" width="750px" />
  <div class="image-caption">Limitar ancho de banda descargas de HF.</div>
</div>

## Método 2: Wondershaper en el host

Si prefieres no usar Docker, puedes limitar el ancho de banda directamente en la interfaz de red del host.

{{< admonition "warning" "Ojo con el Wondershaper de apt" >}}
**No** uses el paquete `wondershaper` del repositorio de Ubuntu, está completamente obsoleto y usa módulos del kernel deprecados (`cbq`), lo que provoca errores `RTNETLINK`. Usa el fork moderno de GitHub.
{{< /admonition >}}

### Instalar el fork moderno

El fork mantenido de **[magnific0/wondershaper](https://github.com/magnific0/wondershaper)** usa el módulo `htb` (Hierarchical Token Bucket), que es el estándar actual.

```bash
git clone https://github.com/magnific0/wondershaper.git
cd wondershaper
```

### Aplicar el límite

Primero identifico mi interfaz de red:

```bash
ip route | grep default
```

En mi caso es `enP7s7`. El script usa Kilobits por segundo (Kbps). Para limitar la descarga a unos 75 MB/s (600.000 Kbps) y la subida a 40 MB/s (320.000 Kbps):

```bash
sudo ./wondershaper -a enP7s7 -d 600000 -u 320000
```

### Descargar el modelo

Con la red del host limitada, lanzo la descarga:

```bash
hf download Sehyo/Qwen3.5-122B-A10B-NVFP4 \
    --local-dir /mnt/baul/models/Qwen3.5-122B-A10B-NVFP
```

### Quitar el límite

{{< admonition "warning" "No te olvides de este paso" >}}
Una vez termine la descarga es **crucial** eliminar las restricciones para que la conexión vuelva a funcionar a velocidad completa.
{{< /admonition >}}

```bash
sudo ./wondershaper -c -a enP7s7
```

## Conclusión

Si tienes Docker disponible, el **método 1** es claramente mejor: limita solo el tráfico del contenedor, no necesitas tocar la red del host y se limpia solo al terminar. El **método 2** con Wondershaper es una buena alternativa si no puedes o no quieres usar Docker, pero ten en cuenta que afecta a toda la máquina y tienes que acordarte de quitar el límite cuando termines.

## Enlaces interesantes

- [Hugging Face CLI](https://huggingface.co/docs/huggingface_hub/guides/cli) - Documentación oficial del CLI
- [magnific0/wondershaper](https://github.com/magnific0/wondershaper) - Fork moderno de Wondershaper
- [tc - Traffic Control](https://man7.org/linux/man-pages/man8/tc.8.html) - Manual de `tc` en Linux
- [Token Bucket Filter (TBF)](https://tldp.org/HOWTO/Traffic-Control-HOWTO/classless-qdiscs.html) - Documentación sobre TBF
