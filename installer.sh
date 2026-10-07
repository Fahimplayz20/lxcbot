#!/bin/bash

# ═══════════════════════════════════════════════════════════════
#   ███████╗ █████╗ ██╗  ██╗██╗███╗   ███╗
#   ██╔════╝██╔══██╗██║  ██║██║████╗ ████║
#   █████╗  ███████║███████║██║██╔████╔██║
#   ██╔══╝  ██╔══██║██╔══██║██║██║╚██╔╝██║
#   ██║     ██║  ██║██║  ██║██║██║ ╚═╝ ██║
#   ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝     ╚═╝
#
#        LXC BOT AUTO INSTALLER  •  By FAHIM
# ═══════════════════════════════════════════════════════════════

set -e

# ─────────── COLORS ───────────
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
NC='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'
BLINK='\033[5m'

# ─────────── WATERMARK (everywhere) ───────────
WM="${DIM}${MAGENTA}[FAHIM]${NC}"

# ─────────── ASCII BANNER ───────────
show_banner() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"
   ███████╗ █████╗ ██╗  ██╗██╗███╗   ███╗
   ██╔════╝██╔══██╗██║  ██║██║████╗ ████║
   █████╗  ███████║███████║██║██╔████╔██║
   ██╔══╝  ██╔══██║██╔══██║██║██║╚██╔╝██║
   ██║     ██║  ██║██║  ██║██║██║ ╚═╝ ██║
   ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝     ╚═╝
EOF
    echo -e "${NC}"
    echo -e "${MAGENTA}${BOLD}        ⚡  LXC BOT AUTO INSTALLER  ⚡${NC}"
    echo -e "${YELLOW}${BOLD}             Crafted with ❤  By FAHIM${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

# ─────────── TYPEWRITER EFFECT ───────────
typewriter() {
    local text="$1"
    local delay="${2:-0.02}"
    for (( i=0; i<${#text}; i++ )); do
        echo -ne "${text:$i:1}"
        sleep "$delay"
    done
    echo ""
}

# ─────────── ANIMATED STEP HEADER ───────────
step_anim() {
    local step="$1"
    local total="$2"
    local title="$3"
    echo ""
    echo -e "${BLUE}${BOLD}┌─────────────────────────────────────────────────────────────┐${NC}"
    printf "${BLUE}${BOLD}│${NC} ${YELLOW}${BOLD}STEP %s/%s${NC} ${WM} ${WHITE}%s${NC}\n" "$step" "$total" "$title"
    echo -e "${BLUE}${BOLD}└─────────────────────────────────────────────────────────────┘${NC}"
    sleep 0.3
}

# ─────────── SPINNER ───────────
spinner() {
    local pid=$1
    local msg="$2"
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0
    while kill -0 "$pid" 2>/dev/null; do
        i=$(( (i+1) % ${#spin} ))
        printf "\r${MAGENTA}%s${NC} ${CYAN}%s${NC} ${WM}" "${spin:$i:1}" "$msg"
        sleep 0.08
    done
    printf "\r${GREEN}✔${NC} ${CYAN}%s${NC} ${DIM}(done)${NC} ${WM}\n" "$msg"
}

# ─────────── RUN CMD WITH SPINNER ───────────
run_silent() {
    local msg="$1"
    shift
    "$@" > /tmp/fahim_install.log 2>&1 &
    local pid=$!
    spinner "$pid" "$msg"
    wait "$pid"
    local rc=$?
    if [ $rc -ne 0 ]; then
        echo -e "${RED}✘ Failed:${NC} $msg"
        echo -e "${DIM}--- log ---${NC}"
        tail -n 20 /tmp/fahim_install.log
        exit 1
    fi
}

# ─────────── PROGRESS BAR ───────────
progress_bar() {
    local label="$1"
    local duration="${2:-1.5}"
    local width=40
    local steps=40
    echo -ne "${CYAN}${label}${NC} ${WM} ["
    for (( i=0; i<steps; i++ )); do
        echo -ne "${GREEN}█${NC}"
        sleep "$(echo "$duration / $steps" | bc -l)"
    done
    echo -e "] ${GREEN}100%${NC}"
}

# ─────────── PULSING TEXT ───────────
pulse() {
    local text="$1"
    for i in 1 2 3; do
        echo -ne "\r${MAGENTA}${BOLD}>>> ${text} <<<${NC} ${WM}   "
        sleep 0.3
        echo -ne "\r${CYAN}${BOLD}>>> ${text} <<<${NC} ${WM}   "
        sleep 0.3
    done
    echo ""
}

# ─────────── ROOT CHECK ───────────
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}${BOLD}✘ Please run as root (sudo bash installer.sh)${NC} ${WM}"
        exit 1
    fi
}

# ─────────── INTRO ───────────
intro() {
    show_banner
    typewriter "  Initializing installer for FAHIM's LXC Bot..." 0.015
    echo ""
    pulse "GET READY"
    sleep 0.5
}

# ─────────── MAIN INSTALL ───────────
main() {
    check_root
    intro

    TOTAL=9

    # STEP 1 - Update apt
    step_anim 1 $TOTAL "Updating apt package index"
    run_silent "Updating apt..." apt update -y

    # STEP 2 - Install git
    step_anim 2 $TOTAL "Installing Git"
    if ! command -v git &>/dev/null; then
        run_silent "Installing git..." apt install git -y
    else
        echo -e "${GREEN}✔${NC} Git already installed ${WM}"
    fi

    # STEP 3 - Clone repo
    step_anim 3 $TOTAL "Cloning LXC Bot repository"
    cd /root || cd ~
    if [ -d "lxcbot" ]; then
        echo -e "${YELLOW}⚠${NC} lxcbot folder exists — pulling latest... ${WM}"
        cd lxcbot && run_silent "Pulling latest..." git pull || true
    else
        run_silent "Cloning https://github.com/Fahimplayz20/lxcbot ..." \
            git clone https://github.com/Fahimplayz20/lxcbot
        cd lxcbot
    fi
    progress_bar "Repository ready" 1.0

    # STEP 4 - Install pip
    step_anim 4 $TOTAL "Installing python3-pip"
    if ! command -v pip3 &>/dev/null; then
        run_silent "Installing pip3..." apt install python3-pip -y
    else
        echo -e "${GREEN}✔${NC} pip3 already installed ${WM}"
    fi

    # STEP 5 - Install Python packages
    step_anim 5 $TOTAL "Installing Python dependencies"

    PIP_PKGS=(
        "davey"
        "discord"
        "dotenv"
        "PyNaCl"
        "paramiko"
        "flask"
        "flask_cors"
    )

    for pkg in "${PIP_PKGS[@]}"; do
        run_silent "pip install $pkg" \
            pip install "$pkg" --break-system-packages --ignore-installed
    done
    progress_bar "Python deps installed" 1.0

    # STEP 6 - Setup .env (interactive)
    step_anim 6 $TOTAL "Configuring .env file"
    [ -f test.env ] && cp test.env .env && echo -e "${GREEN}✔${NC} Copied test.env → .env ${WM}"

    echo ""
    echo -e "${CYAN}${BOLD}┌── .env CONFIGURATION ──────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC} ${DIM}Press ENTER to skip any variable.${NC} ${WM}"
    echo -e "${CYAN}└────────────────────────────────────────────────────────────┘${NC}"

    ask_env() {
        local key="$1"
        local current
        current=$(grep -E "^${key}=" .env 2>/dev/null | head -n1 | cut -d'=' -f2-)
        echo -ne "${YELLOW}${BOLD}${key}${NC} ${DIM}[current: ${current:-empty}]${NC} ${WM} → "
        read -r value
        if [ -n "$value" ]; then
            if grep -qE "^${key}=" .env; then
                sed -i "s|^${key}=.*|${key}=${value}|" .env
            else
                echo "${key}=${value}" >> .env
            fi
            echo -e "   ${GREEN}✔${NC} ${key} ${GREEN}set${NC} ${WM}"
        else
            echo -e "   ${DIM}skipped${NC} ${WM}"
        fi
    }

    # Discover keys from test.env (if present) + always prompt for key ones
    DEFAULT_KEYS=(
        "DISCORD_BOT_TOKEN"
        "DISCORD_GUILD_ID"
        "DISCORD_CATEGORY_ID"
        "DISCORD_LOG_CHANNEL_ID"
        "PTERODACTYL_URL"
        "PTERODACTYL_API_KEY"
        "PTERODACTYL_CLIENT_KEY"
        "LXC_HOST"
        "LXC_USERNAME"
        "LXC_PASSWORD"
        "FLASK_PORT"
        "OWNER_ID"
    )

    echo ""
    for k in "${DEFAULT_KEYS[@]}"; do
        ask_env "$k"
    done

    echo ""
    echo -e "${GREEN}${BOLD}✔ .env configuration complete!${NC} ${WM}"
    sleep 0.7

    # STEP 7 - Locate bot.py
    step_anim 7 $TOTAL "Locating bot.py"
    BOT_PATH=""
    if [ -f "/root/lxcbot/bot.py" ]; then
        BOT_PATH="/root/lxcbot/bot.py"
        WORKDIR="/root/lxcbot"
    elif [ -f "/root/bot.py" ]; then
        BOT_PATH="/root/bot.py"
        WORKDIR="/root"
    else
        FOUND=$(find /root -maxdepth 3 -name "bot.py" -type f 2>/dev/null | head -n1)
        if [ -n "$FOUND" ]; then
            BOT_PATH="$FOUND"
            WORKDIR="$(dirname "$FOUND")"
        fi
    fi

    if [ -z "$BOT_PATH" ]; then
        echo -e "${RED}✘ bot.py not found! Please check repo structure.${NC} ${WM}"
        exit 1
    fi
    echo -e "${GREEN}✔${NC} Found bot at: ${CYAN}${BOT_PATH}${NC} ${WM}"
    echo -e "${GREEN}✔${NC} Working dir:  ${CYAN}${WORKDIR}${NC} ${WM}"

    # STEP 8 - Create systemd service
    step_anim 8 $TOTAL "Creating systemd service"
    cat > /etc/systemd/system/bot.service << EOF
# ══════════════════════════════════════════════
#   LXC Bot Service  •  Managed By FAHIM
# ══════════════════════════════════════════════
[Unit]
Description=Vps Deploy Bot (FAHIM)
After=network.target

[Service]
User=root
WorkingDirectory=${WORKDIR}
ExecStart=/usr/bin/python3 ${BOT_PATH}
Restart=always
RestartSec=5
Environment=PYTHONUNBUFFERED=1

[Install]
WantedBy=multi-user.target
EOF

    echo -e "${GREEN}✔${NC} Service file written → /etc/systemd/system/bot.service ${WM}"

    # STEP 9 - Enable + Start
    step_anim 9 $TOTAL "Enabling & starting service"
    run_silent "Reloading systemd..." systemctl daemon-reload
    run_silent "Enabling bot service..." systemctl enable bot
    systemctl restart bot
    sleep 1.5

    # ─────────── FINAL ───────────
    echo ""
    echo -e "${MAGENTA}${BOLD}"
    cat << "EOF"
   ╔═══════════════════════════════════════════════════════════╗
   ║                                                           ║
   ║        ✅   INSTALLATION COMPLETE SUCCESSFULLY   ✅       ║
   ║                                                           ║
   ║               ███████╗ █████╗ ██╗  ██╗██╗███╗   ███╗      ║
   ║               ██╔════╝██╔══██╗██║  ██║██║████╗ ████║      ║
   ║               █████╗  ███████║███████║██║██╔████╔██║      ║
   ║               ██╔══╝  ██╔══██║██╔══██║██║██║╚██╔╝██║      ║
   ║               ██║     ██║  ██║██║  ██║██║██║ ╚═╝ ██║      ║
   ║               ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝     ╚═╝      ║
   ║                                                           ║
   ╚═══════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"

    pulse "BOT IS RUNNING"
    sleep 0.5

    echo ""
    echo -e "${CYAN}${BOLD}📊 Service Status:${NC} ${WM}"
    systemctl status bot --no-pager -l | head -n 12

    echo ""
    echo -e "${YELLOW}${BOLD}🛠  USEFUL COMMANDS${NC} ${WM}"
    echo -e "   ${GREEN}systemctl status bot${NC}   → Check status"
    echo -e "   ${GREEN}systemctl restart bot${NC}  → Restart bot"
    echo -e "   ${GREEN}systemctl stop bot${NC}     → Stop bot"
    echo -e "   ${GREEN}journalctl -u bot -f${NC}   → Live logs"
    echo ""
    echo -e "${MAGENTA}${BOLD}        ── Powered by FAHIM ──${NC}"
    echo -e "${DIM}${MAGENTA}     github.com/Fahimplayz20${NC}"
    echo ""
}

# ─────────── RUN ───────────
main "$@"
