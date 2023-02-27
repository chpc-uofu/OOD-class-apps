# Remove any preconfigured monitors
if [[ -f "${HOME}/.config/monitors.xml" ]]; then
  mv "${HOME}/.config/monitors.xml" "${HOME}/.config/monitors.xml.bak"
fi

# Copy over default panel if doesn't exist, otherwise it will prompt the user
PANEL_CONFIG="${HOME}/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml"
if [[ ! -e "${PANEL_CONFIG}" ]]; then
  mkdir -p "$(dirname "${PANEL_CONFIG}")"
  cp "/etc/xdg/xfce4/panel/default.xml" "${PANEL_CONFIG}"
fi

# Disable startup services
xfconf-query -c xfce4-session -p /startup/ssh-agent/enabled -n -t bool -s false
xfconf-query -c xfce4-session -p /startup/gpg-agent/enabled -n -t bool -s false

# Set the desktop background
# set background image
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorVNC-0/workspace0/last-image -s /uufs/chpc.utah.edu/sys/ondemand/chpc-class/R25_neurostats/template/desktops/MainLogo_blk_fullcolor.tif
# set tiled image style
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorVNC-0/workspace0/image-style -s 2

# Set Firefox default homepage
# rough info at https://www.commandlinefu.com/commands/view/5314/change-the-homepage-of-firefox
# at start there's no "browser.startup.homepage" defined, so, add it to prefs.js
if ! grep -q Website  "$HOME/.mozilla/firefox/*.default-default/prefs.js"; then
  echo 'user_pref("browser.startup.homepage", "file:///uufs/chpc.utah.edu/sys/ondemand/chpc-class/R25_neurostats/Website/html/index.html");' >> $HOME/.mozilla/firefox/*.default-default/prefs.js
fi
# or if exists
# sed -i 's|\("browser.startup.homepage",\) "\(.*\)"|\1 "file:///uufs/chpc.utah.edu/sys/ondemand/chpc-class/R25_neurostats/Website/html/index.html"|' $HOME/.mozilla/firefox/*.default-default/prefs.js


# Disable useless services on autostart
AUTOSTART="${HOME}/.config/autostart"
rm -fr "${AUTOSTART}"    # clean up previous autostarts
mkdir -p "${AUTOSTART}"
for service in "pulseaudio" "rhsm-icon" "spice-vdagent" "tracker-extract" "tracker-miner-apps" "tracker-miner-user-guides" "xfce4-power-manager" "xfce-polkit"; do
  echo -e "[Desktop Entry]\nHidden=true" > "${AUTOSTART}/${service}.desktop"
done

# this causes Terminal to automatically start in the desktop
cp /usr/share/applications/xfce4-terminal.desktop "${AUTOSTART}"

# Run Xfce4 Terminal as login shell (sets proper TERM)
TERM_CONFIG="${HOME}/.config/xfce4/terminal/terminalrc"
if [[ ! -e "${TERM_CONFIG}" ]]; then
  mkdir -p "$(dirname "${TERM_CONFIG}")"
  sed 's/^ \{4\}//' > "${TERM_CONFIG}" << EOL
    [Configuration]
    CommandLoginShell=TRUE
EOL
else
  sed -i \
    '/^CommandLoginShell=/{h;s/=.*/=TRUE/};${x;/^$/{s//CommandLoginShell=TRUE/;H};x}' \
    "${TERM_CONFIG}"
fi

# Start up xfce desktop (block until user logs out of desktop)
xfce4-session
