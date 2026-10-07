#!/bin/bash

# ═══════════════════════════════════════════════════════════════
#   FAHIM'S LXC BOT AUTO INSTALLER  v3.0
#   GitHub : github.com/Fahimplayz20
#   Made with love by FAHIM
# ═══════════════════════════════════════════════════════════════

# Fix locale for proper UTF-8 rendering
export LANG=C.UTF-8
export LC_ALL=C.UTF-8
export TERM=xterm-256color

# ─── COLORS ────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# ─── WATERMARK ─────────────────────────────────────────────────
WM="${DIM}${MAGENTA}[FAHIM]${NC}"

# ─── BANNER ────────────────────────────────────────────────────
show_banner() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"
  #############################################################
  #                                                           #
  #      #######  ###  #    # ### #     #                    #
  #      #       #   # #    #  #  ##   ##                    #
  #      #####   ##### ######  #  # # # #                    #
  #      #       #   # #    #  #  #  #  #                    #
  #      #       #   # #    # ### #     #                    #
  #                                                           #
  #             >>>  LXC BOT AUTO INSTALLER  <<<              #
  #                                                           #
  #############################################################
EOF
    echo -e "${NC}"
    echo -e "${YELLOW}                Powered by ${BOLD}FAHIM${NC}${YELLOW}${NC}"
    echo ""
    sleep 1
}

# ─── SPINNER ───────────────────────────────────────────────────
spinner() {
    local pid=$1
    local message=$2
    local spin='|/-\'
    local i=0
    while kill -0 "$pid" 2>/dev/null; do
        i=$(( (i+1) % 4 ))
        printf "\r${WM} ${CYAN}${spin:$i:1}${NC} ${message}... "
        sleep 0.15
    done
    printf "\r${WM} ${GREEN}[OK]${NC} ${message}                    \n"
}

# ─── STEP HEADER ───────────────────────────────────────────────
step() {
    echo ""
    echo -e "${MAGENTA}=============================================================${NC}"
    echo -e "${MAGENTA}|${NC}  ${YELLOW}>>${NC} ${BOLD}${WHITE}$1${NC}"
    echo -e "${MAGENTA}=============================================================${NC}"
    echo ""
}

# ─── MESSAGE HELPERS ───────────────────────────────────────────
success() { echo -e "${WM} ${GREEN}[OK]${NC} $1"; }
error()   { echo -e "${WM} ${RED}[X]${NC} $1"; }
info()    { echo -e "${WM} ${CYAN}[i]${NC} $1"; }
warn()    { echo -e "${WM} ${YELLOW}[!]${NC} $1"; }

# ─── ROOT CHECK ────────────────────────────────────────────────
check_root() {
    if [ "$EUID" -ne 0 ]; then
        error "Please run this installer as ${BOLD}root${NC}${RED}!"
        echo -e "${WM} ${YELLOW}Try: ${WHITE}sudo bash installer.sh${NC}"
        exit 1
    fi
}

# ─── INTRO ANIMATION ───────────────────────────────────────────
intro_animation() {
    echo -ne "${WM} ${CYAN}Initializing installer"
    for i in 1 2 3; do echo -ne "."; sleep 0.35; done
    echo -e " ${GREEN}[OK]${NC}"
    sleep 0.2

    echo -ne "${WM} ${CYAN}Checking privileges"
    for i in 1 2 3; do echo -ne "."; sleep 0.35; done
    echo -e " ${GREEN}[OK]${NC}"
    sleep 0.2

    echo -ne "${WM} ${CYAN}Preparing environment"
    for i in 1 2 3; do echo -ne "."; sleep 0.35; done
    echo -e " ${GREEN}[OK]${NC}"
    sleep 0.3
    echo ""
}

# ═══════════════════════════════════════════════════════════════
#   MAIN INSTALLATION
# ═══════════════════════════════════════════════════════════════

show_banner
check_root
intro_animation

# ─── STEP 1: Update & Install Git ──────────────────────────────
step "STEP 1/7 : Installing Git"
(apt-get update -qq && apt-get install -y -qq git curl wget nano) >/dev/null 2>&1 &
spinner $! "Installing git, curl, wget, nano"
success "Base packages installed"

# ─── STEP 2: Clone Repository ──────────────────────────────────
step "STEP 2/7 : Cloning Repository"

# Change to /root
cd /root || { error "Cannot cd to /root"; exit 1; }

if [ -d "lxcbot" ]; then
    warn "Existing lxcbot folder found. Removing..."
    rm -rf lxcbot
fi

(git clone https://github.com/Fahimplayz20/lxcbot) >/dev/null 2>&1 &
spinner $! "Cloning lxcbot from GitHub"

if [ ! -d "lxcbot" ]; then
    error "Clone failed! Check internet or repo URL."
    exit 1
fi
success "Repository cloned to /root/lxcbot"

cd /root/lxcbot || { error "Cannot enter /root/lxcbot"; exit 1; }

# ─── STEP 3: Install Python & Pip ──────────────────────────────
step "STEP 3/7 : Installing Python3 & Pip"
(apt-get install -y -qq python3 python3-pip python3-venv) >/dev/null 2>&1 &
spinner $! "Installing python3-pip"
success "Python3 + pip installed"

# ─── STEP 4: Install Python Packages ───────────────────────────
step "STEP 4/7 : Installing Python Dependencies"

PACKAGES=(
    "davey"
    "discord.py"
    "python-dotenv"
    "PyNaCl"
    "paramiko"
    "flask"
    "flask-cors"
)

total=${#PACKAGES[@]}
current=0

for pkg in "${PACKAGES[@]}"; do
    current=$((current + 1))
    echo -e "${WM} ${CYAN}[${current}/${total}]${NC} Installing ${BOLD}${YELLOW}${pkg}${NC}"
    (pip install "$pkg" --break-system-packages --ignore-installed -q) >/dev/null 2>&1 &
    spinner $! "pip install $pkg"
done

success "All ${total} packages installed"

# ─── STEP 5: Setup .env file ───────────────────────────────────
step "STEP 5/7 : Setting up .env Configuration"

# Copy test.env if exists
if [ -f "test.env" ]; then
    cp test.env .env
    success "Copied test.env -> .env"
else
    warn "test.env not found. Creating new .env file"
    touch .env
fi

echo ""
echo -e "${MAGENTA}=============================================================${NC}"
echo -e "${MAGENTA}|${NC}       ${BOLD}${WHITE}ENVIRONMENT CONFIGURATION${NC}"
echo -e "${MAGENTA}=============================================================${NC}"
echo ""
info "Press ${BOLD}ENTER${NC} to skip any variable you don't want to set."
info "Secrets will be hidden while typing."
echo ""

# Clear old .env (start fresh)
> .env

# ─── ASK VAR FUNCTION (fixed - no color inside read) ───────────
ask_var() {
    local varname="$1"
    local description="$2"
    local is_secret="$3"

    echo ""
    echo -e "${WM} ${CYAN}>>${NC} ${BOLD}${varname}${NC} ${DIM}(${description})${NC}"

    if [ "$is_secret" = "secret" ]; then
        read -rsp "   Enter value: " value
        echo ""
    else
        read -rp  "   Enter value: " value
    fi

    if [ -n "$value" ]; then
        echo "${varname}=${value}" >> .env
        success "  ${varname} saved"
    else
        warn "  ${varname} skipped"
    fi
}

# ─── DISCORD / BOT CONFIG ──────────────────────────────────────
echo -e "${CYAN}--- Discord Bot Configuration ---${NC}"
ask_var "DISCORD_BOT_TOKEN" "Your Discord bot token" "secret"
ask_var "DISCORD_GUILD_ID"  "Your Discord server/guild ID"
ask_var "DISCORD_PREFIX"    "Bot command prefix (e.g. !)"
ask_var "ADMIN_USER_ID"     "Admin Discord user ID"

echo ""
echo -e "${CYAN}--- VPS / SSH Configuration ---${NC}"
ask_var "VPS_HOST"          "VPS host/IP"
ask_var "VPS_USERNAME"      "VPS SSH username"
ask_var "VPS_PASSWORD"      "VPS SSH password" "secret"
ask_var "VPS_PORT"          "VPS SSH port (default 22)"

echo ""
echo -e "${CYAN}--- Optional API Config ---${NC}"
ask_var "API_KEY"           "Your API key if any" "secret"

echo ""
echo -e "${MAGENTA}=============================================================${NC}"
success ".env file created at /root/lxcbot/.env"
info "Edit later with: ${WHITE}nano /root/lxcbot/.env${NC}"
sleep 1

# ─── STEP 6: Create systemd service ────────────────────────────
step "STEP 6/7 : Creating Systemd Service"

# Auto-detect bot.py location
BOT_PATH=""
WORK_DIR=""

if [ -f "/root/lxcbot/bot.py" ]; then
    BOT_PATH="/root/lxcbot/bot.py"
    WORK_DIR="/root/lxcbot"
elif [ -f "/root/bot.py" ]; then
    BOT_PATH="/root/bot.py"
    WORK_DIR="/root"
else
    BOT_PATH=$(find /root/lxcbot -maxdepth 3 -name "bot.py" -type f 2>/dev/null | head -n 1)
    if [ -n "$BOT_PATH" ]; then
        WORK_DIR=$(dirname "$BOT_PATH")
    else
        BOT_PATH="/root/lxcbot/bot.py"
        WORK_DIR="/root/lxcbot"
        warn "bot.py not found. Using default path."
    fi
fi

info "Bot path : ${BOLD}${BOT_PATH}${NC}"
info "Work dir : ${BOLD}${WORK_DIR}${NC}"
echo ""

cat > /etc/systemd/system/bot.service << EOF
# =========================================================
#   FAHIM LXC BOT SERVICE
#   Watermark : FAHIM
#   GitHub    : github.com/Fahimplayz20
# =========================================================

[Unit]
Description=Fahim LXC Deploy Bot
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=${WORK_DIR}
ExecStart=/usr/bin/python3 ${BOT_PATH}
Restart=always
RestartSec=5
Environment=PYTHONUNBUFFERED=1
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

success "Service file created: /etc/systemd/system/bot.service"

# ─── STEP 7: Enable & Start Service ────────────────────────────
step "STEP 7/7 : Enabling & Starting Service"

(systemctl daemon-reload) >/dev/null 2>&1 &
spinner $! "Reloading systemd daemon"

(systemctl enable bot) >/dev/null 2>&1 &
spinner $! "Enabling bot service"

(systemctl restart bot) >/dev/null 2>&1 &
spinner $! "Starting bot service"

sleep 3

# ─── STATUS CHECK ──────────────────────────────────────────────
echo ""
if systemctl is-active --quiet bot; then
    success "Bot service is ${GREEN}${BOLD}RUNNING${NC}"
else
    error "Bot service failed to start!"
    echo -e "${WM} ${YELLOW}Recent logs:${NC}"
    journalctl -u bot -n 15 --no-pager 2>/dev/null
fi

# ─── FINAL SUMMARY ─────────────────────────────────────────────
echo ""
echo -e "${GREEN}"
cat << "EOF"
  #############################################################
  #                                                           #
  #        I N S T A L L A T I O N   C O M P L E T E D        #
  #                                                           #
  #############################################################
EOF
echo -e "${NC}"

echo -e "${CYAN}+-----------------------------------------------------------+${NC}"
echo -e "${CYAN}|${NC}  ${BOLD}${WHITE}USEFUL COMMANDS${NC}"
echo -e "${CYAN}+-----------------------------------------------------------+${NC}"
echo -e "${CYAN}|${NC}  ${YELLOW}>>${NC} Check status  : ${GREEN}systemctl status bot${NC}"
echo -e "${CYAN}|${NC}  ${YELLOW}>>${NC} View logs     : ${GREEN}journalctl -u bot -f${NC}"
echo -e "${CYAN}|${NC}  ${YELLOW}>>${NC} Restart bot   : ${GREEN}systemctl restart bot${NC}"
echo -e "${CYAN}|${NC}  ${YELLOW}>>${NC} Stop bot      : ${GREEN}systemctl stop bot${NC}"
echo -e "${CYAN}|${NC}  ${YELLOW}>>${NC} Edit .env     : ${GREEN}nano /root/lxcbot/.env${NC}"
echo -e "${CYAN}+-----------------------------------------------------------+${NC}"
echo ""

echo -e "${MAGENTA}+-----------------------------------------------------------+${NC}"
echo -e "${MAGENTA}|${NC}                                                           ${MAGENTA}|${NC}"
echo -e "${MAGENTA}|${NC}             ${BOLD}${WHITE}POWERED BY FAHIM${NC}                          ${MAGENTA}|${NC}"
echo -e "${MAGENTA}|${NC}                                                           ${MAGENTA}|${NC}"
echo -e "${MAGENTA}|${NC}            ${DIM}github.com/Fahimplayz20${NC}                     ${MAGENTA}|${NC}"
echo -e "${MAGENTA}|${NC}                                                           ${MAGENTA}|${NC}"
echo -e "${MAGENTA}+-----------------------------------------------------------+${NC}"
echo ""

echo -e "${GREEN}${BOLD}Setup finished successfully! Enjoy your bot!${NC}"
echo ""
