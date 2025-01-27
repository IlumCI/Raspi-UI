#!/bin/bash

# Advanced TUI Desktop Environment Setup Script
# A fully-fledged, terminal-based desktop environment resembling Windows 95
# by integrating several advanced TUI tools, custom scripts, and utilities.

set -e

# === Functions ===
log_info() {
    echo -e "\e[34m[INFO]\e[0m $1"
}

log_error() {
    echo -e "\e[31m[ERROR]\e[0m $1" >&2
}

check_command() {
    command -v "$1" >/dev/null 2>&1 || {
        log_error "$1 is not installed. Please install it and re-run the script."
        exit 1
    }
}

# === Prerequisites ===
log_info "Checking prerequisites..."
check_command git
check_command curl
check_command wget
check_command make
check_command gcc
check_command python3
check_command pip3

# === Install Core Dependencies ===
log_info "Installing core dependencies..."
sudo apt update && sudo apt install -y \
    ncurses-bin \
    dialog \
    tmux \
    fzf \
    ranger \
    neofetch \
    htop \
    cmatrix \
    figlet \
    toilet \
    lolcat \
    feh \
    mpv \
    cava \
    alsa-utils \
    xclip \
    vim \
    zsh \
    jq

pip3 install --upgrade pip
pip3 install \
    asciimatics \
    pyfiglet \
    rich \
    textual \
    pandas \
    numpy \
    pyyaml

# === Directory Setup ===
TUI_DESKTOP_DIR="$HOME/.tui-desktop"
mkdir -p "$TUI_DESKTOP_DIR"/apps "$TUI_DESKTOP_DIR"/config "$TUI_DESKTOP_DIR"/logs "$TUI_DESKTOP_DIR"/themes "$TUI_DESKTOP_DIR"/automation "$TUI_DESKTOP_DIR"/power-management

log_info "Created base directory structure at $TUI_DESKTOP_DIR."

# === Download and Install Additional Tools ===
log_info "Installing additional tools..."

# Install btop for advanced resource monitoring
log_info "Installing btop..."
git clone https://github.com/aristocratos/btop.git "$TUI_DESKTOP_DIR/btop"
cd "$TUI_DESKTOP_DIR/btop"
make && sudo make install
cd -

# Install TUI File Manager
log_info "Installing TUI file manager (nnn)..."
git clone https://github.com/jarun/nnn.git "$TUI_DESKTOP_DIR/nnn"
cd "$TUI_DESKTOP_DIR/nnn"
make && sudo make install
cd -

# === Custom Scripts ===
log_info "Setting up custom scripts..."

# Boot animation
cat > "$TUI_DESKTOP_DIR/config/boot-animation.sh" <<'EOF'
#!/bin/bash
animation_choice=""
while [ -z "$animation_choice" ]; do
    echo "Choose an animation:"
    echo "1. CMatrix"
    echo "2. Star Wars ASCII"
    echo -n "Enter choice (1 or 2): "
    read animation_choice
    case $animation_choice in
        1)
            cmatrix -b -u 2 -C cyan
            ;;
        2)
            telnet towel.blinkenlights.nl
            ;;
        *)
            animation_choice=""
            echo "Invalid choice. Try again."
            ;;
    esac
done
EOF
chmod +x "$TUI_DESKTOP_DIR/config/boot-animation.sh"

# Login screen
cat > "$TUI_DESKTOP_DIR/config/login-screen.sh" <<'EOF'
#!/bin/bash
clear
figlet -c "TUI Desktop" | lolcat
pyfiglet "Welcome!" -f slant | lolcat
while :; do
    echo -n "Enter your username: "
    read username
    echo -n "Enter your password: "
    stty -echo
    read password
    stty echo
    if [ "$username" == "user" ] && [ "$password" == "password" ]; then
        echo "Login successful!" | lolcat
        break
    else
        echo "Invalid credentials. Please try again."
    fi
done
EOF
chmod +x "$TUI_DESKTOP_DIR/config/login-screen.sh"

# App Store
cat > "$TUI_DESKTOP_DIR/apps/app-store.sh" <<'EOF'
#!/bin/bash
clear
figlet "TUI App Store" | lolcat
while :; do
    echo "Available App Categories:"
    echo "1. Office Apps"
    echo "2. Development Tools"
    echo "3. Security Utilities"
    echo "4. Entertainment"
    echo "5. Games"
    echo "6. Customization"
    echo "7. Exit"
    echo -n "Choose a category: "
    read category
    case $category in
        1)
            echo "Installing LibreOffice..."
            sudo apt install libreoffice -y
            ;;
        2)
            echo "Installing Visual Studio Code..."
            sudo apt install code -y
            ;;
        3)
            echo "Installing Nmap and Wireshark..."
            sudo apt install nmap wireshark -y
            ;;
        4)
            echo "Installing VLC Media Player..."
            sudo apt install vlc -y
            ;;
        5)
            echo "Installing Steam..."
            sudo apt install steam -y
            ;;
        6)
            echo "Installing Gnome Tweak Tool..."
            sudo apt install gnome-tweaks -y
            ;;
        7)
            break
            ;;
        *)
            echo "Invalid option. Try again."
            ;;
    esac
done
EOF
chmod +x "$TUI_DESKTOP_DIR/apps/app-store.sh"

# Wallpaper support
cat > "$TUI_DESKTOP_DIR/config/set-wallpaper.sh" <<'EOF'
#!/bin/bash
if [ -z "$1" ]; then
    echo "Usage: set-wallpaper.sh <image-path>"
    exit 1
fi
feh --bg-scale "$1"
EOF
chmod +x "$TUI_DESKTOP_DIR/config/set-wallpaper.sh"

# Taskbar
cat > "$TUI_DESKTOP_DIR/config/taskbar.sh" <<'EOF'
#!/bin/bash
echo "[Date/Time: $(date)] [User: $(whoami)] [Uptime: $(uptime -p)] [Battery: $(acpi -b | awk '{print $4}')] [Connection: $(nmcli -t -f ACTIVE,SSID dev wifi | grep '^yes' | cut -d':' -f2)]"
EOF
chmod +x "$TUI_DESKTOP_DIR/config/taskbar.sh"

# App Search
cat > "$TUI_DESKTOP_DIR/apps/search-apps.sh" <<'EOF'
#!/bin/bash
echo "Search for an app:"
echo -n "Enter app name: "
read app_name
command -v "$app_name" >/dev/null 2>&1 && echo "$app_name is installed." || echo "$app_name is not installed."
EOF
chmod +x "$TUI_DESKTOP_DIR/apps/search-apps.sh"

# Automation script
cat > "$TUI_DESKTOP_DIR/automation/automate-task.sh" <<'EOF'
#!/bin/bash
clear
echo "Automate your tasks"
while :; do
    echo "1. Schedule a Task"
    echo "2. View Scheduled Tasks"
    echo "3. Exit"
    echo -n "Choose an option: "
    read choice
    case $choice in
        1)
            echo -n "Enter task command: "
            read task_cmd
            echo -n "Enter execution time (e.g., '2am', 'now + 1 hour'): "
            read exec_time
            echo "$task_cmd" | at "$exec_time"
            echo "Task scheduled successfully."
            ;;
        2)
            atq
            ;;
        3)
            break
            ;;
        *)
            echo "Invalid option. Try again."
            ;;
    esac
done
EOF
chmod +x "$TUI_DESKTOP_DIR/automation/automate-task.sh"

# Power Management
cat > "$TUI_DESKTOP_DIR/power-management/power-mode.sh" <<'EOF'
#!/bin/bash
clear
echo "Choose Power Mode:"
echo "1. Performance"
echo "2. Balanced"
echo "3. Power Saver"
read -p "Enter your choice: " choice
case $choice in
    1)
        echo "Switching to Performance mode..."
        echo 1 | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo
        ;;
    2)
        echo "Switching to Balanced mode..."
        echo 0 | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo
        ;;
    3)
        echo "Switching to Power Saver mode..."
        sudo cpufreq-set -g powersave
        ;;
    *)
        echo "Invalid choice."
        ;;
esac
EOF
chmod +x "$TUI_DESKTOP_DIR/power-management/power-mode.sh"

# === Main Launcher ===
log_info "Creating main launcher script..."
cat > "$TUI_DESKTOP_DIR/launcher.sh" <<'EOF'
#!/bin/bash
clear
figlet "TUI Desktop" | lolcat
while :; do
    echo "1. Start Menu"
    echo "2. File Manager"
    echo "3. Taskbar"
    echo "4. App Store"
    echo "5. Search Apps"
    echo "6. Automation"
    echo "7. Power Management"
    echo "8. Settings"
    echo "9. Exit"
    echo -n "Choose an option: "
    read choice
    case $choice in
        1)
            dialog --menu "Start Menu" 20 50 10 \
                1 "File Explorer" \
                2 "Settings" \
                3 "Run Command" \
                4 "Logout"
            ;;
        2)
            ranger
            ;;
        3)
            "$TUI_DESKTOP_DIR/config/taskbar.sh"
            ;;
        4)
            "$TUI_DESKTOP_DIR/apps/app-store.sh"
            ;;
        5)
            "$TUI_DESKTOP_DIR/apps/search-apps.sh"
            ;;
        6)
            "$TUI_DESKTOP_DIR/automation/automate-task.sh"
            ;;
        7)
            "$TUI_DESKTOP_DIR/power-management/power-mode.sh"
            ;;
        8)
            "$TUI_DESKTOP_DIR/config/login-screen.sh"
            ;;
        9)
            exit 0
            ;;
        *)
            echo "Invalid option. Exiting..."
            exit 1
            ;;
    esac
done
EOF
chmod +x "$TUI_DESKTOP_DIR/launcher.sh"

# === Finalizing Setup ===
log_info "Setup complete! To start the TUI desktop, run: $TUI_DESKTOP_DIR/launcher.sh"
