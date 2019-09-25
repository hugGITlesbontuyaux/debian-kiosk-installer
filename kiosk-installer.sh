#!/bin/bash

# Add non-free drivers
if [ -e "/etc/apt/source.list" ]; then
  cp /etc/apt/source.list /etc/apt/source.list.backup
fi
cat >> /etc/apt/source.list << EOF
# non-free drivers
deb http://httpredir.debian.org/debian/ buster main contrib non-free
EOF

# Regenarate Source list
apt-get update && apt-get upgrade

# Install non-free drivers
apt-get install firmware-realtek firmware-misc-nonfree -y

# Install component
apt-get install xorg lxde-core tightvncserver chromium unclutter xrdp -y

# create group
groupadd kiosk

# create user if not exists
id -u kiosk &>/dev/null || useradd -m kiosk -g kiosk -s /bin/bash 

# rights
chown -R kiosk:kiosk /home/kiosk

# Config lightdm
if [ -e "/etc/lightdm/lightdm.conf" ]; then
  cp /etc/lightdm/lightdm.conf /etc/lightdm/lightdm.backup
fi
cat > /etc/lightdm/lightdm.conf << EOF
[SeatDefaults]
autologin-user=kiosk
[VNCServer]
enabled=true
command=Xvnc
port=5900
EOF

# Autostart
if [ -e "/etc/xdg/lxsession/LXDE/autostart" ]; then
  cp /etc/xdg/lxsession/LXDE/autostart /etc/xdg/lxsession/LXDE/autostart.backup
fi
cat > /etc/xdg/lxsession/LXDE/autostart << EOF
@lxpanel --profile LXDE
@pcmanfm --desktop --profile LXDE
# @xscreensaver -no-splash
@chromium --kiosk http://play.playr.biz
EOF

# Desactivation du powersaving
systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

echo "Done!"
