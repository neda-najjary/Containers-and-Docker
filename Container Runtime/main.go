package main

import (
	"fmt"
	"os"
	"os/exec"
	"strconv"
	"syscall"
)

const containerRootPath = "/home/najjari/container-rootfs"

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Usage: ./simple-container <hostname> [memory_limit_in_mb]")
		return
	}

	if os.Args[1] != "child" {
		// مرحله والد: اجرای برنامه به صورت جداگانه داخل namespace جدید
		cmd := exec.Command("/proc/self/exe", append([]string{"child"}, os.Args[1:]...)...)
		cmd.Stdin = os.Stdin
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		cmd.SysProcAttr = &syscall.SysProcAttr{
			Cloneflags: syscall.CLONE_NEWPID | syscall.CLONE_NEWUTS | syscall.CLONE_NEWNS | syscall.CLONE_NEWNET,
		}
		if err := cmd.Run(); err != nil {
			fmt.Printf("Failed to run child process: %v\n", err)
		}
		return
	}

	// داخل کانتینر (child)
	hostname := os.Args[2]

	if err := syscall.Sethostname([]byte(hostname)); err != nil {
		fmt.Printf("Failed to set hostname: %v\n", err)
		return
	}

	if err := syscall.Chroot(containerRootPath); err != nil {
		fmt.Printf("Failed to chroot: %v\n", err)
		return
	}
	if err := os.Chdir("/"); err != nil {
		fmt.Printf("Failed to chdir: %v\n", err)
		return
	}

	// mount /proc
	if err := syscall.Mount("proc", "/proc", "proc", 0, ""); err != nil {
		fmt.Printf("Failed to mount /proc: %v\n", err)
		return
	}
	defer syscall.Unmount("/proc", 0)

	// محدود کردن RAM (اختیاری)
	if len(os.Args) == 4 {
		memoryLimitMB, _ := strconv.Atoi(os.Args[3])
		createCgroup(memoryLimitMB)
	}

	// اجرای bash به عنوان PID 1
	cmd := exec.Command("/bin/bash")
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	if err := cmd.Run(); err != nil {
		fmt.Printf("Failed to run bash: %v\n", err)
	}
}

func createCgroup(memoryLimitMB int) {
	cgroupPath := "/sys/fs/cgroup/memory/simple-container"
	os.MkdirAll(cgroupPath, 0755)

	memoryLimitBytes := strconv.Itoa(memoryLimitMB * 1024 * 1024)
	os.WriteFile(cgroupPath+"/memory.limit_in_bytes", []byte(memoryLimitBytes), 0644)

	pid := strconv.Itoa(os.Getpid())
	os.WriteFile(cgroupPath+"/tasks", []byte(pid), 0644)
}
