# Figure 2: Routing Without a Router

## 1. Overview
When the `router` namespace and its links to `br1` and `br2` are deleted, the two bridges remain in the root namespace without any direct routing between the two subnets. To enable packet forwarding between these subnets, the root namespace itself can act as a software router:

## 2. Required Commands and Rules

1. **Enable IP forwarding**  
   ```bash
   # In the root namespace
   sudo sysctl -w net.ipv4.ip_forward=1
   ```

2. **Assign gateway IPs to the bridges**  
   ```bash
   # On root namespace
   sudo ip addr add 172.0.0.254/24 dev br1
   sudo ip addr add 10.10.0.254/24 dev br2
   ```

3. **Add static routes in the root namespace**  
   ```bash
   sudo ip route add 10.10.0.0/24 via 172.0.0.254 dev br1
   sudo ip route add 172.0.0.0/24 via 10.10.0.254 dev br2
   ```

4. **Configure default gateway in each node namespace**  
   - For nodes on the `172.0.0.0/24` subnet (e.g., `node1`, `node2`):
     ```bash
     sudo ip netns exec nodeX ip route add default via 172.0.0.254 dev eth0
     ```
   - For nodes on the `10.10.0.0/24` subnet (e.g., `node3`, `node4`):
     ```bash
     sudo ip netns exec nodeY ip route add default via 10.10.0.254 dev eth0
     ```

## 3. Assumptions and Considerations
- Both bridges `br1` and `br2` remain connected to their respective veth interfaces from the node namespaces.
- No IP conflicts exist between the gateway addresses and node addresses.
- All commands are executed in the root namespace unless otherwise specified.
