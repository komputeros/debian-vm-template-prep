# debian-vm-template-prep
Scripts and instructions to prepare a clean and reusable Debian 13 VM template for VMware Workstation. Includes SSH key regeneration on first boot, machine-id reset, log cleanup, and template hardening.

# Debian 13 – VM Template Preparation for VMware Workstation

This repository contains a complete and production-ready script for preparing a **Debian 13 virtual machine template** to be used in **VMware Workstation**.

Using this template allows you to instantly create new Debian VMs **without reinstalling the operating system**. The script cleans the system, resets unique identifiers, removes SSH host keys, and configures the OS to regenerate necessary data on the first boot.

---

## 🚀 Features

- Resets `/etc/machine-id` to enforce unique identity in each clone
- Removes all SSH host keys and regenerates them on first boot
- Cleans APT cache and system logs
- Clears temporary directories
- Removes persistent udev network interface rules
- Deletes shell histories and known_hosts
- 100% automated and safe for Debian 13 templates

---

## 📁 Files in This Repository

```
prepare-template.sh      # Main script used to clean and prepare the VM
README.md                # Documentation
```

---

## 📥 Installation

Clone the repository inside your Debian 13 VM:

```bash
git clone https://github.com/<your_github_username>/debian-vm-template-prep.git
cd debian-vm-template-prep
chmod +x prepare-template.sh
```

---

## 🧰 Usage Instructions

### 1️⃣ Prepare your Debian 13 VM
Install Debian normally and configure:

- system updates
- default packages
- users & sudo
- network config
- open-vm-tools

Once the system is configured the way you want all future clones to look — proceed to the next step.

---

### 2️⃣ Run the template preparation script

```bash
sudo ./prepare-template.sh
```

This script will:

- Clean logs, cache, tmp files
- Remove SSH host keys
- Install a systemd service that regenerates fresh keys on first boot
- Reset machine-id
- Remove persistent network rules
- Clean shell histories

---

### 3️⃣ Shut down the VM

```bash
sudo poweroff
```

⚠️ **Important:** Do **not** boot this VM again. It is now a *template*. Use clones only.

---

### 4️⃣ Create new VMs using the Template

In VMware Workstation:

```
Right-click VM → Manage → Clone → Full Clone
```

Each clone will:

- Generate new SSH host keys
- Generate new machine-id
- Boot as a clean, fresh system

---

## ⚠ Important Notes

- Never boot the template VM after running the script. Only clone it.
- Each clone safely regenerates identifiers on its own.
- Works on Debian 13 stable (systemd-based).

---

## 🛠 Customization

You can extend this repository with optional features:

- auto-randomized hostname on first boot
- additional provisioning scripts
- cloud-init–like customization

Feel free to fork the repo or open PRs.

---

## 📄 License

MIT License — free for personal and commercial use.

---

## ⭐ Support

If this project helps you, please consider giving it a star on GitHub! ⭐
