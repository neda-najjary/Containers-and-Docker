#  Simple Container Runtime

This project is a simple container runtime (similar in spirit to Docker) written in **Go**.  
It launches a container with isolated namespaces and a custom Ubuntu 20.04 root filesystem.

---

## ✅ Features

- Creates a new container with isolated namespaces:
  - `net`, `mnt`, `pid`, `uts`
- Sets a custom hostname inside the container
- Mounts a separate root filesystem (`chroot`) using Ubuntu 20.04
- Runs a `bash` shell as **PID 1** inside the container
- [✅ BONUS] Supports optional memory limitation using **cgroups v1**

---

## 📁 Project Structure

The repository contains the following files:

```
.
├── main.go                      # Container runtime source code
├── go.mod                      # Go module definition
├── container-rootfs.tar.gz     # Ubuntu 20.04 root filesystem (compressed)
└── README.md                   # You're reading it
```

---

## ⚙️ Requirements

- Linux system with:
  - `unshare`, `chroot`, `cgroups`, and `procfs`
- **Go 1.24+** (Tested on Go 1.24.5)
- `Docker` (only used to prepare the root filesystem once)
- Must be run with **sudo**

---

## 🔧 Setup Instructions

### 1. Install Go (if not already installed)

```bash
wget https://dl.google.com/go/go1.24.5.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go1.24.5.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
```

### 2. Download and extract this repository

```bash
git clone https://github.com/yourusername/simple-container
cd simple-container
```

### 3. Extract the Ubuntu root filesystem

```bash
tar -xzf container-rootfs.tar.gz
```

> This will extract the `container-rootfs/` directory, which will be used as the container's root filesystem.

---

## 🛠️ Build the CLI

```bash
go mod tidy
go build -o simple-container main.go
```

---

## 🚀 Usage

Run the container with a custom hostname (and optional memory limit in MB):

```bash
sudo ./simple-container <hostname> [memory_limit_MB]
```

### Example:

```bash
sudo ./simple-container testhost 100
```

This will:
- Create a new container with hostname `testhost`
- Set memory usage limit to 100 MB (via cgroups)
- Enter a bash shell inside the container with isolated namespaces

---

## 🧪 Inside the Container

Once inside the container shell:

```bash
# Check the hostname
hostname
# Output: testhost

# Check that bash is PID 1
ps fax
```

Sample Output:
```
  PID TTY      STAT   TIME COMMAND
    1 ?        Sl     0:00 /proc/self/exe child testhost 100
    7 ?        S      0:00 /bin/bash
   11 ?        R+     0:00  \_ ps fax
```

---

## 🧰 How the Root Filesystem Was Prepared

To regenerate the `container-rootfs.tar.gz`, follow these steps:

```bash
# Install Docker
sudo apt update
sudo apt install docker.io -y

# Pull Ubuntu image
docker pull ubuntu:20.04

# Create and exit a temporary container
sudo docker run -it ubuntu:20.04
exit

# Find container ID
sudo docker ps -a

# Export root filesystem (replace <container_id> accordingly)
sudo docker export <container_id> > ubuntu_rootfs.tar

# Extract and compress
mkdir container-rootfs
tar -xf ubuntu_rootfs.tar -C container-rootfs
tar -czf container-rootfs.tar.gz container-rootfs
```

---

## ⚠️ Notes

- You **must run** the program with `sudo` due to namespace and chroot permissions.
- Only works on **Linux**.
- Make sure `cgroups v1` is enabled for memory limitation to work.
- This is a simplified educational project and lacks full security and features of real container runtimes.

---

## 📜 License

MIT License

---

## ✍️ Author

Written by [Your Name], based on a container runtime assignment.
