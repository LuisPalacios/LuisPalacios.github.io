---
title: "Limiting Hugging Face Bandwidth"
date: "2026-02-22"
categories: ["software"]
tags:
  ["hugging-face", "docker", "linux", "bandwidth", "tc", "llm", "wondershaper"]
draft: false
cover:
  image: "/img/posts/logo-shaping.svg"
  hidden: true
---

<img src="/img/posts/logo-shaping.svg" alt="Bandwidth Limiting Logo" width="150px" height="150px" style="float:left; padding-right:25px" />

Downloading LLM models locally is something you do occasionally, but when you pull a massive 122B parameter model like `Sehyo/Qwen3.5-122B-A10B-NVFP4`, the download hogs the entire connection and leaves the rest of the household without internet. The Hugging Face CLI (`huggingface-cli` or `hf`) doesn't have a `--limit-rate` flag, so you need to find alternatives. In this post I explain two ways to limit bandwidth on Linux using Docker (my preferred method) or Wondershaper at the host level.

<br clear="left"/>
<!--more-->

## The problem

I have a 1 Gbps fiber connection at home. When I launch a massive download from Hugging Face, the CLI tries to use all available bandwidth. That means while a 70GB+ model is downloading, nobody else at home can browse or work normally.

The logical thing would be for `huggingface-cli` to have a `--limit-rate` flag like `curl` does, so the solution is to limit bandwidth at the network level, outside the tool.

## Method 1: Docker (recommended)

The idea is to spin up a Docker container for the download and limit its network traffic with `tc` (Linux Traffic Control). This way the host's connection stays intact and other devices are unaffected.

### Why tc from the host and not from inside the container

The first instinct is to run `tc` inside the container itself, applying a Token Bucket Filter (TBF) on its `eth0`. The problem is that `tc` in `root qdisc` mode only limits **egress (outbound)** traffic. Downloads are **ingress (inbound)** traffic, so the limit doesn't affect them. I also tried an `ingress policer` inside the container, but TCP compensates for dropped packets and the actual throttling is minimal.

The solution that works is applying `tc` **from the host** on the `veth` interface that Docker creates for the container. From the host's perspective, traffic sent toward the container is **egress**, and there the TBF works perfectly.

### The `hf-download-limited.sh` script

I've created a script that automates the entire process:

{{< codefile path="snippets/2026-02-27-limitar-ancho-de-banda-hugging-face/hf-download-limited.sh" lang="bash" title="hf-download-limited.sh" >}}

Run it passing the model and destination directory:

```bash
chmod +x hf-download-limited.sh
./hf-download-limited.sh \
    -m "Sehyo/Qwen3.5-122B-A10B-NVFP4" \
    -d "/home/luis/tmp/Qwen3.5-122B-A10B-NVFP4" \
    -b 600
```

The `-b` flag lets you adjust the bandwidth limit in Mbps (default 600). If you have a Hugging Face token you can pass it with `-t` for faster downloads and higher rate limits.

### What the script does step by step

1. **Parses the arguments** (`-m` model, `-d` directory, `-b` bandwidth, `-t` token) and automatically calculates the Token Bucket Filter `burst` from the bandwidth.
2. **Launches a container** with `sleep infinity` in the background and installs `huggingface_hub` inside it.
3. **Finds the veth interface** on the host. Each Docker container has an internal `eth0` interface connected to a `veth` on the host. The script reads the container's `iflink` and finds the corresponding interface with `ip -o link`.
4. **Applies `tc` from the host** on that `veth`. A Token Bucket Filter (TBF) limits traffic the host sends to the container -- i.e., the downloads.
5. **Runs `hf download`** inside the container with `-it` to see the progress bar.
6. **Cleans up when done**. A `trap cleanup EXIT` takes care of stopping the container whether the download finishes, fails, or you hit Ctrl+C.

The output is clean:

```text
--- Iniciando contenedor ---
--- Instalando huggingface_hub ---
--- Aplicando tc en vethe4845c6: rate=600mbit burst=12mbit ---

=== Descargando Sehyo/Qwen3.5-122B-A10B-NVFP4 ===
=== Destino: /home/luis/tmp/Qwen3.5-122B-A10B-NVFP4 ===
=== Límite: 600 Mbps ===

Fetching 15 files:  47%|████▋     | 7/15 [02:30<03:00, ...]
```

When the download finishes, the container disappears along with all network restrictions. The system is left clean without needing to do anything else.

<div class="image-box">
  <img src="/img/posts/2026-02-22-limitar-hf.png" alt="Limiting bandwidth for Hugging Face downloads" width="750px" />
  <div class="image-caption">Limiting bandwidth for HF downloads.</div>
</div>

## Method 2: Wondershaper on the host

If you prefer not to use Docker, you can limit bandwidth directly on the host's network interface.

{{< admonition "warning" "Watch out for apt's Wondershaper" >}}
**Do not** use the `wondershaper` package from Ubuntu's repository -- it's completely outdated and uses deprecated kernel modules (`cbq`), which causes `RTNETLINK` errors. Use the modern GitHub fork instead.
{{< /admonition >}}

### Install the modern fork

The maintained fork by **[magnific0/wondershaper](https://github.com/magnific0/wondershaper)** uses the `htb` (Hierarchical Token Bucket) module, which is the current standard.

```bash
git clone https://github.com/magnific0/wondershaper.git
cd wondershaper
```

### Apply the limit

First I identify my network interface:

```bash
ip route | grep default
```

In my case it's `enP7s7`. The script uses Kilobits per second (Kbps). To limit downloads to about 75 MB/s (600,000 Kbps) and uploads to 40 MB/s (320,000 Kbps):

```bash
sudo ./wondershaper -a enP7s7 -d 600000 -u 320000
```

### Download the model

With the host's network limited, I launch the download:

```bash
hf download Sehyo/Qwen3.5-122B-A10B-NVFP4 \
    --local-dir /mnt/baul/models/Qwen3.5-122B-A10B-NVFP
```

### Remove the limit

{{< admonition "warning" "Don't forget this step" >}}
Once the download finishes, it's **crucial** to remove the restrictions so the connection returns to full speed.
{{< /admonition >}}

```bash
sudo ./wondershaper -c -a enP7s7
```

## Conclusion

If you have Docker available, **method 1** is clearly better: it only limits the container's traffic, you don't need to touch the host's network, and it cleans up automatically when done. **Method 2** with Wondershaper is a good alternative if you can't or don't want to use Docker, but keep in mind it affects the entire machine and you have to remember to remove the limit when you're done.

## Useful links

- [Hugging Face CLI](https://huggingface.co/docs/huggingface_hub/guides/cli) - Official CLI documentation
- [magnific0/wondershaper](https://github.com/magnific0/wondershaper) - Modern Wondershaper fork
- [tc - Traffic Control](https://man7.org/linux/man-pages/man8/tc.8.html) - Linux `tc` manual
- [Token Bucket Filter (TBF)](https://tldp.org/HOWTO/Traffic-Control-HOWTO/classless-qdiscs.html) - TBF documentation
