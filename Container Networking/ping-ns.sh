#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 2 ]; then
  echo "Usage: $0 <src-ns> <dst-ns> [count]"
  exit 1
fi
src=$1; dst=$2; cnt=${3:-4}

# ۱) بررسی وجود namespace
for ns in "$src" "$dst"; do
  ip netns list | grep -qw "$ns" || { echo "Namespace $ns not found"; exit 1; }
done

# ۲) گرفتن اولین آدرس IPv4 که در هر interface ست شده
ip_addr=$(ip netns exec "$dst" ip -4 -o addr show scope global \
         | awk '{print $4}' | cut -d/ -f1 | head -n1)

echo "Pinging $dst ($ip_addr) from $src ..."
ip netns exec "$src" ping -c "$cnt" "$ip_addr"
