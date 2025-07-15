## Container Networking Project (Problem 1)

This repository contains the implementation of the network namespace topology shown in **Figure 1** using Linux network namespaces and bridges, along with utilities to test connectivity. It also includes placeholders for answers to the conceptual questions for **Figures 2** and **3**.

---
### 📂 Project Structure

```plaintext
Container Networking/               # Project folder
├── README.md
├── setup-fig1.sh        # Bash script to create topology (Figure 1)
├── ping-ns.sh           # Bash script to ping between namespaces
├── answer-fig2.md      # Explanation for routing without router (Figure 2)
└── answer-fig3.md      # Explanation for distributed namespaces (Figure 3)
```

---
## Prerequisites

- **OS:** Linux distribution with `iproute2` utilities installed.
- **Permissions:** `sudo` privileges to create network namespaces and bridges.
- **Shell:** Bash (scripts use `#!/usr/bin/env bash`).

Make sure you have:
```bash
sudo apt update
sudo apt install -y iproute2
```

---
## Getting Started


1️⃣ **Download the files**

Download these two scripts from the repository to your local machine and place them into a directory named `problem1`:

- `setup-fig1.sh`
- `ping-ns.sh`

2️⃣ **Create and enter the project folder**

Open a terminal and run:

```bash
mkdir problem1
cd problem1
```

3️⃣ **Make scripts executable**
```bash
chmod +x setup-fig1.sh ping-ns.sh
```

4️⃣ **Run the topology setup (Figure 1)**
```bash
sudo ./setup-fig1.sh
```

   - This will:
     - Create namespaces: `node1`, `node2`, `node3`, `node4`, and `router`.
     - Create bridges `br1` and `br2` in the root namespace.
     - Create veth pairs connecting each node to its bridge.
     - Connect the router to both bridges.
     - Assign IP addresses in subnets `172.0.0.0/24` and `10.10.0.0.0/24`.
     - Configure IP forwarding in the router and default routes in the nodes.

5️⃣ **Test connectivity**

- To ping from one namespace to another, use the `ping-ns.sh` utility:
```bash
sudo ./ping-ns.sh <source-namespace> <destination-namespace> [count]
```

- Example: Ping the router from `node1`:
```bash
sudo ./ping-ns.sh node1 router
```

---
## Scripts Description

### `setup-fig1.sh`
- **Purpose:** Automates creation of the network topology for Figure 1.
- **Usage:** `sudo ./setup-fig1.sh`
- **Key steps:**
  1. Clean existing namespaces and bridges.
  2. Create namespaces and bridges.
  3. Set up veth interfaces and attach them to bridges.
  4. Assign IP addresses.
  5. Enable packet forwarding on the router namespace.
  6. Configure default routes on all nodes.

### `ping-ns.sh`
- **Purpose:** Simplifies ping tests between two namespaces.
- **Usage:** `sudo ./ping-ns.sh <src-ns> <dst-ns> [count]`
- **Key steps:**
  1. Validate both namespaces exist.
  2. Automatically detect the destination IPv4 address.
  3. Execute `ping` from source namespace.

---
## Conceptual Questions

Two additional questions for **Figures 2** and **3** require explanatory answers (no implementation). Please provide your responses in the corresponding files:

- **Figure 2 (No Router):** `answer-fig2.md`
- **Figure 3 (Distributed Namespaces on Separate Servers):** `answer-fig3.md`

Each document should include:

1. Description of how to route packets between subnets.
2. List of required commands or rules in the root namespace (or on each server).
3. Any assumptions or considerations.

---
## Cleanup

To remove the topology created by `setup-fig1.sh`, execute:
```bash
# Delete namespaces
for ns in node1 node2 node3 node4 router; do
  sudo ip netns del "$ns" 2>/dev/null || :
done

# Delete bridges
sudo ip link del br1 2>/dev/null || :
sudo ip link del br2 2>/dev/null || :
```

---
*Download, run, and explore the container networking topology on your Linux machine!*