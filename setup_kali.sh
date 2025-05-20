#!/bin/bash
# This is not complete


####################################################
# This script organises my kali install in such a way that suites my needs.
#
# The important directories are as follows:
#  - /tools/pentest             # Pentesting tools that can't be apt installed
#  - /tools/scripts             # Useful pentesting scripts
#  - /wordlists                 # Wordlists
#  - /inject                    # Files used to inject
#  - /inject/images
#  - /inject/format*
####################################################








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
sudo apt install libsasl2-dev python2-dev libldap2-dev libssl-dev python-is-python3 -y
apt install curl gpg pipx golang -y









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













# Pentest
mkdir /tools/pentest -p
mkdir /tools/scripts -p
mkdir /inject -p

# Network stuff
apt install netcat-traditional rlwrap socat telnet autorecon recon-ng -y
git clone https://github.com/RUB-NDS/PRET.git /tools/pentest/PRET

# Wifi
apt install aircrack-ng -y
wget https://github.com/Ragnt/AngryOxide/releases/download/v0.8.32/angryoxide-linux-x86_64.tar.gz -O /tools/pentest/temp/angryoxide-linux-x86_64.tar.gz
tar -xvzf /tools/pentest/temp/angryoxide-linux-x86_64.tar.gz -C /tools/pentest/temp
./tools/pentest/temp/install.sh
rm -rf /tools/pentest/temp


# Web stuff
apt install burpsuite sqlmap laudanum -y
pipx install bbot
git clone https://github.com/vladko312/SSTImap.git /tools/pentest/SSTImap
ln -s /usr/share/laudanum /inject


# Vuln scanners
apt install nikto nuclei ssh-audit wpscan -y
docker pull immauss/openvas:latest
echo "alias openvas-start='sudo docker run --publish 8080:9392 --name openvas immauss/openvas:latest'" >> ~/.zshrc
echo "alias openvas-start='sudo docker run --publish 8080:9392 --name openvas immauss/openvas:latest'" >> ~/.bashrc
echo "alias openvas-new-db='sudo docker volume create openvas'" >> ~/.zshrc
echo "alias openvas-new-db='sudo docker volume create openvas'" >> ~/.bashrc
echo "alias openvas-rm-db='sudo docker volume remove openvas'" >> ~/.zshrc
echo "alias openvas-rm-db='sudo docker volume remove openvas'" >> ~/.bashrc
echo "alias openvas-start-per='sudo docker run --publish 8080:9392 --name openvas --volume openvas:/data immauss/openvas:latest'" >> ~/.zshrc
echo "alias openvas-start-per='sudo docker run --publish 8080:9392 --name openvas --volume openvas:/data immauss/openvas:latest'" >> ~/.bashrc

# AD Tools
apt install netexec responder coercer enum4linux-ng evil-winrm python3-impacket impacket-scripts ldap-utils mitm6 -y
git clone https://github.com/SecuProject/ADenum.git /tools/pentest/ADenum
wget https://github.com/ropnop/kerbrute/releases/download/v1.0.3/kerbrute_linux_amd64 -O /tools/pentest/kerbrute

# Bruteforce
apt install seclists -y
mkdir /usr/share/wordlists -p
ln -s /usr/share/seclists /usr/share/wordlists

apt install crunch feroxbuster ffuf gobuster hashcat hydra john -y

# Frameworks
apt install metasploit-framework -y

# Privesc Scripts
apt install peass
ln -s /usr/share/peass/winpeas /tools/scripts
ln -s /usr/share/peass/linpeas /tools/scripts

wget https://raw.githubusercontent.com/rebootuser/LinEnum/refs/heads/master/LinEnum.sh -O /tools/scripts/linenum.sh
wget https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/master/Privesc/PowerUp.ps1 -O /tools/scripts/PowerUp.ps1
wget https://github.com/ohpe/juicy-potato/releases/download/v0.1/JuicyPotato.exe -O /tools/scripts/JuicyPotato.exe

# Utilities
apt install hash-identifier magic-wormhole ncdu tmux code-oss -y
pipx install smbclientng











# Install GUI
# Check if this is wanted
apt install sddm -y
apt install kde-plasma-desktop --no-install-recommends -y 

# Customise KDE
rm /home/$user/.config -rf
rm /etc/sddm.conf.d -rf
mkdir /home/$user/.config -p
mkdir /etc/sddm.conf.d -p
cp -r config/* /home/$user/.config
cp kde_settings.conf /etc/sddm.conf.d/kde_settings.conf

chown $user:$user -R /home/$user/.config

# Remove bloat    
apt remove kate -y
apt remove konqueror -y
rm /home/$user/.config/kate* -rf
rm /home/$user/.config/konqueror* -rf




# Reboot system
reboot