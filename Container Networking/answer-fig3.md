# Figure 3: Distributed Namespaces on Separate Servers

When namespaces reside on two separate servers (VMs or physical hosts) that share a Layer 2 network, there are two main solutions to route traffic between subnets:

## 1. Layer 2 Tunnel (VXLAN or GRE)

1. **Create a VXLAN/GRE interface on each server and attach it to the local bridge**  
   ```bash
   # Example for VXLAN on Server A
   sudo ip link add vxlan10 type vxlan id 10 dev <physical-iface> remote <ServerB_IP> dstport 4789
   sudo ip link set vxlan10 up
   sudo brctl addif br1 vxlan10
   ```
2. **Use the tunnel to extend the broadcast domain**  
   - The VXLAN/GRE tunnel makes both `br1` (on Server A) and `br2` (on Server B) part of the same L2 domain.
   - Namespaces on either server can then communicate via ARP and IP as if they were on the same local network.

## 2. Layer 3 Routing

1. **Assign gateway IPs to bridges on each server**  
   ```bash
   # On Server A (subnet 172.0.0.0/24)
   sudo ip addr add 172.0.0.254/24 dev br1
   # On Server B (subnet 10.10.0.0/24)
   sudo ip addr add 10.10.0.254/24 dev br2
   ```

2. **Enable IP forwarding on both servers**  
   ```bash
   sudo sysctl -w net.ipv4.ip_forward=1
   ```

3. **Add static routes on each server**  
   ```bash
   # On Server A
   sudo ip route add 10.10.0.0/24 via <ServerB_management_IP> dev <phys-iface>
   # On Server B
   sudo ip route add 172.0.0.0/24 via <ServerA_management_IP> dev <phys-iface>
   ```

4. **Set default gateway in each node namespace**  
   - On Server A:
     ```bash
     sudo ip netns exec nodeX ip route add default via 172.0.0.254 dev eth0
     ```
   - On Server B:
     ```bash
     sudo ip netns exec nodeY ip route add default via 10.10.0.254 dev eth0
     ```

## 3. Assumptions and Considerations
- The physical network between the servers supports the chosen tunneling protocol (for L2).
- Management IPs used for L3 routing are reachable and not firewalled.
- IP forwarding and appropriate firewall rules (if any) are configured to allow inter-subnet traffic.
