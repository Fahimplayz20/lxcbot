#!/bin/bash

# ═══════════════════════════════════════════════════════════════
#  ███████╗ █████╗ ██╗  ██╗██╗███╗   ███╗
#  ██╔════╝██╔══██╗██║  ██║██║████╗ ████║
#  █████╗  ███████║███████║██║██╔████╔██║
#  ██╔══╝  ██╔══██║██╔══██║██║██║╚██╔╝██║
#  ██║     ██║  ██║██║  ██║██║██║ ╚═╝ ██║
#  ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝     ╚═╝
#          LXC BOT INSTALLER  v2.0
#         Made with ❤️  by FAHIM
# ═══════════════════════════════════════════════════════════════

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
DIM='\033[2m'
BLINK='\033[5m'
NC='\033[0m'

# Watermark
WATERMARK="${DIM}${MAGENTA}[ FAHIM ]${NC}"

# Banner
show_banner() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"
    ╔═══════════════════════════════════════════════════════════╗
    ║                                                           ║
    ║      ███████╗ █████╗ ██╗  ██╗██╗███╗   ███╗               ║
    ║      ██╔════╝██╔══██╗██║  ██║██║████╗ ████║               ║
    ║      █████╗  ███████║███████║██║██╔████╔██║               ║
    ║      ██╔══╝  ██╔══██║██╔══██║██║██║╚██╔╝██║               ║
    ║      ██║     ██║  ██║██║  ██║██║██║ ╚═╝ ██║               ║
    ║      ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝     ╚═╝               ║
    ║                                                           ║
    ║              🚀  LXC BOT AUTO INSTALLER  🚀               ║
    ║                                                           ║
    ╚═══════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    echo -e "${YELLOW}                ⚡ Powered by ${BOLD}FAHIM${NC}${YELLOW} ⚡${NC}"
    echo ""
    sleep 1
}

# Animated spinner
spinner() {
    local pid=$1
    local message=$2
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0
    while kill -0 "$pid" 2>/dev/null; do
        i=$(( (i+1) % 10 ))
        printf "\r${WATERMARK} ${CYAN}${spin:$i:1}${NC} ${message}... "
        sleep 0.1
    done
    printf "\r${WATERMARK} ${GREEN}✔${NC} ${message} ${GREEN}DONE${NC}          \n"
}

# Animated typing text
type_text() {
    local text="$1"
    local delay="${2:-0.02}"
    for (( i=0; i<${#text}; i++ )); do
        printf "%s" "${text:$i:1}"
        sleep "$delay"
    done
    echo ""
}

# Progress bar
progress_bar() {
    local duration=${1:-3}
    local width=40
    echo -ne "${WATERMARK} ${CYAN}Progress:${NC} ["
    for ((i=0; i<width; i++)); do echo -ne " "; done
    echo -ne "]"
    echo -ne "\r${WATERMARK} ${CYAN}Progress:${NC} ["
    for ((i=0; i<=width; i++)); do
        echo -ne "${GREEN}█${NC}"
        sleep $(echo "scale=3; $duration/$width" | bc)
    done
    echo -e "] ${GREEN}100%${NC}"
}

# Step header
step() {
    echo ""
    echo -e "${MAGENTA}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}║${NC}  ${YELLOW}▸${NC} ${BOLD}${WHITE}$1${NC}"
    echo -e "${MAGENTA}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Success message
success() {
    echo -e "${WATERMARK} ${GREEN}✔ $1${NC}"
}

# Error message
error() {
    echo -e "${WATERMARK} ${RED}✘ $1${NC}"
}

# Info message
info() {
    echo -e "${WATERMARK} ${CYAN}ℹ $1${NC}"
}

# Warning message
warn() {
    echo -e "${WATERMARK} ${YELLOW}⚠ $1${NC}"
}

# Check root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        error "Please run this installer as ${BOLD}root${NC}${RED}!"
        echo -e "${WATERMARK} ${YELLOW}Try: ${WHITE}sudo bash installer.sh${NC}"
        exit 1
    fi
}

# Animated intro
intro_animation() {
    echo -ne "${WATERMARK} ${CYAN}Initializing installer"
    for i in {1..3}; do
        echo -ne "."
        sleep 0.4
    done
    echo -e " ${GREEN}✓${NC}"
    sleep 0.3
    echo -ne "${WATERMARK} ${CYAN}Checking privileges"
    for i in {1..3}; do
        echo -ne "."
        sleep 0.4
    done
    echo -e " ${GREEN}✓${NC}"
    sleep 0.3
}

# ═══════════════════════════════════════════════════════════════
#  MAIN INSTALLATION
# ═══════════════════════════════════════════════════════════════

show_banner
check_root
intro_animation

# ─── STEP 1: Install Git ───────────────────────────────────────
step "STEP 1/7 : Installing Git"
(apt update -qq && apt install git -y -qq) >/dev/null 2>&1 &
spinner $! "Installing git package"
success "Git installed successfully"

# ─── STEP 2: Clone Repo ────────────────────────────────────────
step "STEP 2/7 : Cloning Repository"
cd /root || exit 1
if [ -d "lxcbot" ]; then
    warn "Existing lxcbot folder detected. Removing..."
    rm -rf lxcbot
fi
(git clone https://github.com/Fahimplayz20/lxcbot) >/dev/null 2>&1 &
spinner $! "Cloning lxcbot from GitHub"
if [ ! -d "lxcbot" ]; then
    error "Clone failed! Check your internet or repo URL."
    exit 1
fi
success "Repository cloned"

cd lxcbot || exit 1

# ─── STEP 3: Install Python & pip ──────────────────────────────
step "STEP 3/7 : Installing Python & Pip"
(apt install python3-pip -y -qq) >/dev/null 2>&1 &
spinner $! "Installing python3-pip"
success "Python3-pip installed"

# ─── STEP 4: Install Python Packages ───────────────────────────
step "STEP 4/7 : Installing Python Dependencies"

PACKAGES=(
    "davey"
    "discord"
    "dotenv"
    "PyNaCl"
    "paramiko"
    "flask"
    "flask_cors"
)

total=${#PACKAGES[@]}
current=0

for pkg in "${PACKAGES[@]}"; do
    current=$((current + 1))
    echo -e "${WATERMARK} ${CYAN}[${current}/${total}]${NC} Installing ${BOLD}${YELLOW}${pkg}${NC}"
    (pip install "$pkg" --break-system-packages --ignore-installed -q) >/dev/null 2>&1 &
    spinner $! "pip install $pkg"
done

success "All ${total} packages installed"

# ─── STEP 5: Setup .env file ───────────────────────────────────
step "STEP 5/7 : Setting up .env Configuration"

# Copy test.env
if [ -f "test.env" ]; then
    cp test.env .env
    success "Copied test.env → .env"
else
    warn "test.env not found. Creating new .env file"
    touch .env
fi

echo ""
echo -e "${MAGENTA}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${MAGENTA}║${NC}      ${BOLD}${WHITE}🔧  ENVIRONMENT CONFIGURATION  🔧${NC}                      ${MAGENTA}║${NC}"
echo -e "${MAGENTA}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
info "Press ${BOLD}ENTER${NC} to skip any variable you don't want to set."
echo ""

# Clear the old .env content (keep structure if needed)
> .env

# Ask for each variable
ask_var() {
    local varname="$1"
    local description="$2"
    local is_secret="$3"
    echo -e "${WATERMARK} ${CYAN}▸${NC} ${BOLD}${varname}${NC} ${DIM}(${description})${NC}"
    if [ "$is_secret" = "secret" ]; then
        read -rsp "  ${YELLOW}→ ${NC}" value
        echo ""
    else
        read -rp "  ${YELLOW}→ ${NC}" value
    fi
    if [ -n "$value" ]; then
        echo "${varname}=${value}" >> .env
        success "  ${varname} set ✓"
    else
        warn "  ${varname} skipped"
    fi
    echo ""
}

# Common bot env vars - adjust these based on your bot
ask_var "DISCORD_BOT_TOKEN" "Your Discord bot token" "secret"
ask_var "DISCORD_GUILD_ID" "Your Discord server/guild ID"
ask_var "DISCORD_PREFIX" "Bot command prefix (e.g. !)"
ask_var "ADMIN_USER_ID" "Admin Discord user ID"
ask_var "VPS_HOST" "VPS host/IP"
ask_var "VPS_USERNAME" "VPS SSH username"
ask_var "VPS_PASSWORD" "VPS SSH password" "secret"
ask_var "VPS_PORT" "VPS SSH port (default 22)"
ask_var "API_KEY" "Your API key if any" "secret"

echo -e "${MAGENTA}═══════════════════════════════════════════════════════════${NC}"
success ".env file created successfully"
info "You can edit it later with: ${WHITE}nano /root/lxcbot/.env${NC}"

# ─── STEP 6: Create systemd service ────────────────────────────
step "STEP 6/7 : Creating Systemd Service"

# Determine bot.py location
if [ -f "/root/lxcbot/bot.py" ]; then
    BOT_PATH="/root/lxcbot/bot.py"
    WORK_DIR="/root/lxcbot"
elif [ -f "/root/bot.py" ]; then
    BOT_PATH="/root/bot.py"
    WORK_DIR="/root"
else
    # Search for bot.py in lxcbot
    BOT_PATH=$(find /root/lxcbot -name "bot.py" -type f 2>/dev/null | head -n 1)
    if [ -z "$BOT_PATH" ]; then
        BOT_PATH="/root/lxcbot/bot.py"
        WORK_DIR="/root/lxcbot"
        warn "bot.py not found. Using default path: ${BOT_PATH}"
    else
        WORK_DIR=$(dirname "$BOT_PATH")
    fi
fi

info "Bot path   : ${BOLD}${BOT_PATH}${NC}"
info "Work dir   : ${BOLD}${WORK_DIR}${NC}"
echo ""

cat > /etc/systemd/system/bot.service << EOF
# ═══════════════════════════════════════════════════════════
#  FAHIM LXC BOT SERVICE
#  Watermark: FAHIM
# ═══════════════════════════════════════════════════════════

[Unit]
Description=${GREEN}Fahim's VPS Deploy Bot${NC}
After=network.target

[Service]
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

success "Service file created at /etc/systemd/system/bot.service"

# ─── STEP 7: Enable & Start Service ────────────────────────────
step "STEP 7/7 : Enabling & Starting Service"

(systemctl daemon-reload) >/dev/null 2>&1 &
spinner $! "Reloading systemd daemon"

(systemctl enable bot) >/dev/null 2>&1 &
spinner $! "Enabling bot service"

(systemctl restart bot) >/dev/null 2>&1 &
spinner $! "Starting bot service"

sleep 2

# Check status
if systemctl is-active --quiet bot; then
    success "Bot service is ${GREEN}${BOLD}RUNNING${NC}"
else
    error "Bot service failed to start. Check logs:"
    echo -e "${WATERMARK} ${YELLOW}→ journalctl -u bot -n 50 --no-pager${NC}"
fi

# ─── FINAL SUMMARY ─────────────────────────────────────────────
echo ""
echo -e "${GREEN}"
cat << "EOF"
    ╔═══════════════════════════════════════════════════════════╗
    ║                                                           ║
    ║   ✔   I N S T A L L A T I O N   C O M P L E T E D         ║
    ║                                                           ║
    ╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}  ${BOLD}${WHITE}📋  USEFUL COMMANDS${NC}"
echo -e "${CYAN}╠══════════════════════════════════════════════════════════╣${NC}"
echo -e "${CYAN}║${NC}  ${YELLOW}▸${NC} Check status   : ${GREEN}systemctl status bot${NC}"
echo -e "${CYAN}║${NC}  ${YELLOW}▸${NC} View logs      : ${GREEN}journalctl -u bot -f${NC}"
echo -e "${CYAN}║${NC}  ${YELLOW}▸${NC} Restart bot    : ${GREEN}systemctl restart bot${NC}"
echo -e "${CYAN}║${NC}  ${YELLOW}▸${NC} Stop bot       : ${GREEN}systemctl stop bot${NC}"
echo -e "${CYAN}║${NC}  ${YELLOW}▸${NC} Edit .env      : ${GREEN}nano /root/lxcbot/.env${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"

echo ""
echo -e "${MAGENTA}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${MAGENTA}║${NC}                                                          ${MAGENTA}║${NC}"
echo -e "${MAGENTA}║${NC}          ${BOLD}${WHITE}⚡  P O W E R E D   B Y   F A H I M  ⚡${NC}            ${MAGENTA}║${NC}"
echo -e "${MAGENTA}║${NC}                                                          ${MAGENTA}║${NC}"
echo -e "${MAGENTA}║${NC}                ${DIM}github.com/Fahimplayz20${NC}                  ${MAGENTA}║${NC}"
echo -e "${MAGENTA}║${NC}                                                          ${MAGENTA}║${NC}"
echo -e "${MAGENTA}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Final animated flourish
echo -ne "${WATERMARK} ${CYAN}Cleaning up"
for i in {1..3}; do echo -ne "."; sleep 0.4; done
echo -e " ${GREEN}✓${NC}"
echo ""
echo -e "${GREEN}${BOLD}🎉 Setup finished successfully! Enjoy your bot! 🎉${NC}"
echo ""
