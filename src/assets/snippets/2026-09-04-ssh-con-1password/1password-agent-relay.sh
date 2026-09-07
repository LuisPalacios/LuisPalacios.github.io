#!/usr/bin/env bash
# Puente WSL -> agente SSH de 1Password en Windows (opción B, NO documentada
# por 1Password; ellos solo la citan como "workaround con npiperelay y socat").
#
# Requisitos:
#   - En WSL:      sudo apt install -y socat
#   - En Windows:  npiperelay.exe (fork mantenido: github.com/albertony/npiperelay)
#                  descárgalo de Releases y ponlo en una ruta fija, por ejemplo
#                  C:\tools\npiperelay.exe
#
# Uso: añade a ~/.bashrc o ~/.zshrc:
#   source ~/.local/bin/1password-agent-relay.sh
#
# El socket se crea en ~/.1password/agent.sock a propósito: así el mismo
# ~/.ssh/config.d/linux.conf del Linux de escritorio funciona en WSL sin tocarlo.

NPIPERELAY="/mnt/c/tools/npiperelay.exe"
export SSH_AUTH_SOCK="$HOME/.1password/agent.sock"

if [ ! -x "$NPIPERELAY" ]; then
    echo "1password-agent-relay: no encuentro $NPIPERELAY" >&2
    return 1 2>/dev/null || exit 1
fi

# Si no hay ya un socat escuchando en ese socket, lo levanto.
if ! ss -xl 2>/dev/null | grep -q "$SSH_AUTH_SOCK"; then
    rm -f "$SSH_AUTH_SOCK"
    mkdir -p "$(dirname "$SSH_AUTH_SOCK")"
    chmod 700 "$(dirname "$SSH_AUTH_SOCK")"
    (setsid socat \
        UNIX-LISTEN:"$SSH_AUTH_SOCK",fork,umask=077 \
        EXEC:"$NPIPERELAY -ei -s //./pipe/openssh-ssh-agent",nofork &) >/dev/null 2>&1
fi
