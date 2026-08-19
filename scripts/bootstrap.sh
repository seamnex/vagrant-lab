#!/usr/bin/env bash
# Provisioning base de cada nodo del laboratorio.
# Recibe: $1 = rol del nodo (app|monitor), $2 = IP privada
set -euo pipefail

ROL="${1:-app}"
IP="${2:-sin-ip}"

echo "[bootstrap] nodo=$(hostname) rol=${ROL} ip=${IP}"

export DEBIAN_FRONTEND=noninteractive
apt-get update -qq

# Herramientas de diagnóstico que siempre terminás necesitando
# cuando algo falla y no tenés tiempo de instalarlas.
apt-get install -y -qq \
  curl wget vim htop net-tools dnsutils \
  tcpdump traceroute jq unzip ca-certificates

# Sincronía horaria: sin esto, correlacionar logs entre nodos es imposible
timedatectl set-timezone America/Argentina/Buenos_Aires || true

# Resolución de nombres entre nodos del laboratorio
cat >> /etc/hosts <<'EOF'
192.168.56.11  app-01
192.168.56.12  app-02
192.168.56.20  monitor
EOF

if [[ "${ROL}" == "monitor" ]]; then
  echo "[bootstrap] instalando Docker en el nodo monitor"
  apt-get install -y -qq docker.io docker-compose-v2
  systemctl enable --now docker
  usermod -aG docker vagrant
fi

echo "[bootstrap] nodo $(hostname) listo"
