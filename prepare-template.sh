#!/bin/bash
# prepare-template.sh
# Przygotowanie Debiana 13 jako template VM (golden image)

set -euo pipefail

if [[ "$EUID" -ne 0 ]]; then
    echo "Uruchom ten skrypt jako root."
    exit 1
fi

echo "=== [1/9] Czyszczenie cache APT ==="
if command -v apt-get >/dev/null 2>&1; then
    apt-get clean
    rm -rf /var/lib/apt/lists/* || true
fi

echo "=== [2/9] Czyszczenie katalogów tymczasowych ==="
rm -rf /tmp/* /var/tmp/* || true

echo "=== [3/9] Czyszczenie logów systemowych ==="
if [ -d /var/log ]; then
    find /var/log -type f -exec truncate -s 0 {} \; || true
fi

echo "=== [4/9] Usuwanie kluczy SSH hosta ==="
if [ -d /etc/ssh ]; then
    rm -f /etc/ssh/ssh_host_* || true
fi

echo "=== [5/9] Tworzenie usługi systemd do regeneracji kluczy SSH przy pierwszym starcie ==="
cat >/etc/systemd/system/regenerate-ssh-host-keys.service <<'EOF'
[Unit]
Description=Regenerate SSH host keys on first boot
After=network.target
Before=ssh.service sshd.service

[Service]
Type=oneshot
ExecStart=/usr/bin/ssh-keygen -A
# Po wygenerowaniu kluczy wyłącz usługę, żeby nie uruchamiała się ponownie
ExecStartPost=/bin/systemctl disable regenerate-ssh-host-keys.service

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable regenerate-ssh-host-keys.service

echo "=== [6/9] Reset machine-id ==="
# Upewnij się, że plik istnieje, potem go zeruj
if [ ! -f /etc/machine-id ]; then
    touch /etc/machine-id
fi

truncate -s 0 /etc/machine-id || true

# D-Bus machine-id jako link symboliczny do /etc/machine-id
rm -f /var/lib/dbus/machine-id || true
mkdir -p /var/lib/dbus || true
ln -s /etc/machine-id /var/lib/dbus/machine-id || true

echo "=== [7/9] Usuwanie persistent net rules (udev) ==="
rm -f /etc/udev/rules.d/70-persistent-net.rules || true

echo "=== [8/9] Czyszczenie historii shelli ==="
# Historia bieżącej powłoki (jeśli jest interaktywna)
history -c 2>/dev/null || true

# root
: > /root/.bash_history 2>/dev/null || true

# pozostali użytkownicy
for home in /home/*; do
    [ -d "$home" ] || continue
    : > "$home/.bash_history" 2>/dev/null || true
done

echo "=== [9/9] Czyszczenie known_hosts użytkowników ==="
rm -f /root/.ssh/known_hosts 2>/dev/null || true
for home in /home/*; do
    [ -d "$home/.ssh" ] || continue
    rm -f "$home/.ssh/known_hosts" 2>/dev/null || true
done

echo
echo "==============================================="
echo "  Przygotowanie template zakończone."
echo "  Teraz WYŁĄCZ tę maszynę i używaj jej tylko"
echo "  jako źródła do klonowania w VMware."
echo "==============================================="
