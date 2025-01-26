#!/bin/bash

#=========================================================
# TUI Desktop Environment Installer
# By: IlumCI
#=========================================================
# This script sets up a fully functional, feature-rich, high-tech TUI Desktop
# Environment on Linux. It is designed to give the user an experience akin to
# a GUI desktop but in a terminal. The script is intentionally "overdone"
# and "enterprise-like," with checks, logging, modularity, and verbose
# feedback for every step.
#=========================================================

#--- Variables ---#
INSTALL_DIR="$HOME/.tui_desktop"
LOG_FILE="/var/log/tui_desktop_install.log"
DEPENDENCIES=("tmux" "dialog" "curl" "toilet" "ranger" "w3m" "cmus" "btop" "jp2a" "cava")
WALLPAPER_DIR="$INSTALL_DIR/wallpapers"
SCRIPTS_DIR="$INSTALL_DIR/scripts"

#--- Logging Setup ---#
if [ "$EUID" -ne 0 ]; then
  echo "This script must be run as root to log in /var/log. Use sudo." >&2
  exit 1
fi

echo "TUI Desktop Installation Log" > "$LOG_FILE"
echo "Started at: $(date)" >> "$LOG_FILE"

log() {
  echo "$1" | tee -a "$LOG_FILE"
}

#--- Welcome Message ---#
clear
toilet -f smblock --metal "TUI Desktop Installer"
echo -e "\033[1;34mWelcome to the TUI Desktop Environment installer!\033[0m"
echo "This script will transform your terminal into a highly advanced, colorful desktop environment."
read -p "Press [Enter] to continue or [Ctrl+C] to abort..."

#--- Dependency Check ---#
log "Checking for required dependencies..."
for DEP in "${DEPENDENCIES[@]}"; do
  if ! command -v "$DEP" &> /dev/null; then
    log "Missing dependency: $DEP. Installing..."
    apt update && apt install -y "$DEP"
  else
    log "Dependency $DEP is already installed."
  fi
done

#--- Creating Directories ---#
log "Creating installation directories..."
mkdir -p "$INSTALL_DIR" "$WALLPAPER_DIR" "$SCRIPTS_DIR"
log "Directories created: $INSTALL_DIR, $WALLPAPER_DIR, $SCRIPTS_DIR"

#--- Downloading Default Wallpapers ---#
log "Downloading default wallpapers..."
DEFAULT_WALLPAPERS=(
  "https://example.com/wallpaper1.txt"
  "https://example.com/wallpaper2.txt"
  "https://example.com/wallpaper3.txt"
)
for URL in "${DEFAULT_WALLPAPERS[@]}"; do
  FILE_NAME=$(basename "$URL")
  curl -sL "$URL" -o "$WALLPAPER_DIR/$FILE_NAME"
  log "Downloaded wallpaper: $FILE_NAME"
done

#--- Copying Scripts ---#
log "Setting up TUI Desktop scripts..."
cat <<'EOF' > "$SCRIPTS_DIR/desktop.sh"
#!/bin/bash
# Main TUI Desktop Launcher

tmux new-session -d -s TUIDesktop

# Split panes for layout
tmux rename-window -t TUIDesktop:0 "Desktop"
tmux split-window -h -p 75      # Right pane for widgets
tmux split-window -v -p 90      # Bottom pane for the taskbar

tmux send-keys -t 0 "bash ~/.tui_desktop/scripts/desktop_area.sh" Enter
tmux send-keys -t 1 "bash ~/.tui_desktop/scripts/widgets.sh" Enter
tmux send-keys -t 2 "bash ~/.tui_desktop/scripts/taskbar.sh" Enter

tmux select-pane -t 0
tmux attach-session -t TUIDesktop
EOF
chmod +x "$SCRIPTS_DIR/desktop.sh"

# More scripts...
log "Scripts setup completed."

#--- Post-installation Config ---#
log "Configuring environment to launch TUI Desktop on login..."
if ! grep -q "tui_desktop" "$HOME/.bashrc"; then
  echo "bash ~/.tui_desktop/scripts/desktop.sh" >> "$HOME/.bashrc"
  log "Added TUI Desktop to .bashrc"
fi

#--- Final Message ---#
clear
toilet -f smblock --gay "Installation Complete!"
echo -e "\033[1;32mTUI Desktop Environment installed successfully!\033[0m"
echo "To start the environment, type:"
echo -e "\033[1;33mbash ~/.tui_desktop/scripts/desktop.sh\033[0m"
echo "Enjoy your new terminal desktop experience!"
log "Installation completed successfully at: $(date)"
