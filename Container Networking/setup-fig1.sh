#!/usr/bin/env bash
# setup-fig1.sh — ایجاد namespaceها و برقراری توپولوژی شکل ۱

set -euo pipefail

# ——— پاک‌سازی اگر وجود دارند ———
for ns in node1 node2 node3 node4 router; do
  ip netns del "$ns" 2>/dev/null || :
done
ip link del br1 2>/dev/null || :
ip link del br2 2>/dev/null || :

# ——— ساخت namespaceها ———
for ns in node1 node2 node3 node4 router; do
  ip netns add "$ns"
done

# ——— ساخت و بالا آوردن bridgeها ———
for br in br1 br2; do
  ip link add name "$br" type bridge
  ip link set "$br" up
done

# ——— ساخت veth و وصل به bridge ———
link_veth() {
  local ns=$1 local br=$2
  ip link add "v-$ns" type veth peer name "b-$ns"
  ip link set "v-$ns" netns "$ns"
  ip link set "b-$ns" master "$br" up
  ip netns exec "$ns" ip link set "v-$ns" name eth0 up
}
link_veth node1 br1
link_veth node2 br1
link_veth node3 br2
link_veth node4 br2

# ——— وصل روتر به هر دو bridge ———
ip link add v-router1 type veth peer name b-router1
ip link set b-router1 master br1 up
ip link set v-router1 netns router

ip link add v-router2 type veth peer name b-router2
ip link set b-router2 master br2 up
ip link set v-router2 netns router

ip netns exec router ip link set v-router1 name eth1 up
ip netns exec router ip link set v-router2 name eth2 up

# ——— تنظیم IP ———
ip netns exec node1 ip addr add 172.0.0.2/24 dev eth0
ip netns exec node2 ip addr add 172.0.0.3/24 dev eth0
ip netns exec node3 ip addr add 10.10.0.2/24 dev eth0
ip netns exec node4 ip addr add 10.10.0.3/24 dev eth0

ip netns exec router ip addr add 172.0.0.1/24 dev eth1
ip netns exec router ip addr add 10.10.0.1/24 dev eth2

# ——— فعال‌سازی forwarding و gateway ———
ip netns exec router sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"

for ns in node1 node2; do
  ip netns exec "$ns" ip route add default via 172.0.0.1 dev eth0
done
for ns in node3 node4; do
  ip netns exec "$ns" ip route add default via 10.10.0.1 dev eth0
done

echo "=== Topology Figure 1 is up ==="
