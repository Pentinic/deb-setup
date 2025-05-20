#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

read -p "Setup for user: " user
if ! getent passwd $user > /dev/null 2>&1; then
    echo "User doesn't exist, exiting..."
    exit 
fi





# Update packages
apt update -y
apt full-upgrade -y
apt autoremove -y


# Important Programs
apt install python-is-python3 curl gpg pipx golang firefox-esr -y







# Terminal
curl -fsSL https://apt.fury.io/wez/gpg.key | gpg --yes --dearmor -o /etc/apt/keyrings/wezterm-fury.gpg
echo 'deb [signed-by=/etc/apt/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | tee /etc/apt/sources.list.d/wezterm.list
apt update -y
apt install wezterm -y

# Change terminal icon
cp -r applications/* /usr/share/applications







# Docker
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian bullseye stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update -y
apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y




# VS Code
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | tee /etc/apt/sources.list.d/vscode.list > /dev/null
rm -f packages.microsoft.gpg
apt install apt-transport-https -y
apt update -y
apt install code -y



# Utilities
apt install magic-wormhole ncdu tmux code-oss firefox-esr zip -y
pipx install smbclientng











# Install GUI
# Check if this is wanted
apt install sddm -y
apt install kde-plasma-desktop --no-install-recommends -y 
apt install i3 -y

# Customise KDE
rm /home/$user/.config -rf
rm /etc/sddm.conf.d -rf
rm /usr/share/plasma/desktoptheme -rf
mkdir /home/$user/.config -p
mkdir /home/$user/.local/share/plasma/desktoptheme -p
mkdir /etc/sddm.conf.d -p
cp -r config/* /home/$user/.config
cp -r icons/* /usr/share/icons
cp -r desktoptheme /usr/share/plasma/desktoptheme
cp -r Obsidian-Edge /home/$user/.local/share/plasma/desktoptheme # Custom theme
cp kde_settings.conf /etc/sddm.conf.d/kde_settings.conf

chown $user:$user -R /home/$user/.config
chown $user:$user -R /home/$user/.local

# Replace 
find "/home/$user/.config" -type f -exec sed -Ei "s#/home/.+/.config#/home/$user/.config#g" {} \;


# Remove bloat    
apt remove kate -y
apt remove konqueror -y
rm /home/$user/.config/kate* -rf
rm /home/$user/.config/konqueror* -rf




# Reboot system
systemctl reboot