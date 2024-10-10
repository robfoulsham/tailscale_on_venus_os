#!/bin/bash

clear

FALLBACK_VERSION="1.74.1"

# Function to validate the version format
is_valid_version() {
  [[ "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

# Try to fetch the latest Tailscale version from the website
LATEST_VERSION=$(curl -s https://pkgs.tailscale.com/stable/#static | grep -o 'tailscale_[^"]*arm.tgz' | head -n 1 | sed 's/tailscale_//; s/_arm.tgz//')

# Validate the fetched version, fallback if invalid
if [ -z "$LATEST_VERSION" ] || ! is_valid_version "$LATEST_VERSION"; then
  echo "Failed to fetch a valid version, falling back to hardcoded version. Please notify repo maintainer."
  TAILSCALE_VERSION="$FALLBACK_VERSION"
else
  TAILSCALE_VERSION="$LATEST_VERSION"
fi

# Set the TGZ filename
TAILSCALE_TGZ="tailscale_${TAILSCALE_VERSION}_arm.tgz"

# Output the selected version and TGZ filename
echo "Installing Tailscale version: $TAILSCALE_VERSION"
echo "Tailscale TGZ filename: $TAILSCALE_TGZ"

#
# move into home directory of the user root.
#
echo "move into home directory of the user root."
echo ""
cd /home/root
echo ""
sleep 1

#
# download the latest tailscale package.
#
echo "download the latest tailscale package."
echo ""
curl -o tailscale_loc.tgz https://pkgs.tailscale.com/stable/$TAILSCALE_TGZ
echo "done."
echo ""
sleep 1
echo $TAILSCALE_TGZ


#
# uncompress the package.
#
echo "uncompress the package."
echo ""
tar -xvf tailscale_loc.tgz
echo "done."
echo ""
sleep 1

#
# copy the nessesary files to /usr/bin.
#
echo "copy the nessesary files to /usr/bin."
echo ""
cp /home/root/tailscale_"$TAILSCALE_VERSION"_arm/tailscale /home/root/tailscale_"$TAILSCALE_VERSION"_arm/tailscaled /usr/bin/
echo "done."
echo ""
sleep 1

#
# copy the nessesary file to /etc/init.d.
#
echo "copy the nessesary file to /etc/init.d."
echo ""
curl -o /etc/init.d/tailscaled https://raw.githubusercontent.com/mcfrojd/tailscale_on_venus_os/master/etc/init.d/tailscaled
echo "done."
echo ""
sleep 1

#
# make init script executable
#
echo "make init script executable"
echo ""
chmod +x /etc/init.d/tailscaled
echo "done."
echo ""
sleep 1

#
# test the init script
#
echo "test the init script"
echo ""
/etc/init.d/tailscaled start
/etc/init.d/tailscaled stop
/etc/init.d/tailscaled start
echo "done."
echo ""
sleep 1

#
# configure tailscale init script to start automatically on boot
#
echo "configure tailscale init script to start automatically on boot"
echo ""
update-rc.d tailscaled defaults
echo "done."
sleep 1

#
# enable ip-forward
#
echo "enable ip-forward"
echo ""
echo 'net.ipv4.ip_forward = 1' | tee -a /etc/sysctl.conf
echo 'net.ipv6.conf.all.forwarding = 1' | tee -a /etc/sysctl.conf
echo "done."
echo ""
sleep 1

# cleanup downloaded files
echo "cleaning up files"
rm -r /home/root/tailscale*
rm /home/root/setup_victron.sh

#
# connect to your tailscale account
# Theese settings are custom for my setup, change the ip address to match your system!
#
echo "connect to your tailscale account"
echo ""
echo 'run "tailscale up -ssh --advertise-routes=192.168.77.0/24"'

#
# if there were no errors, tailscale should be installed and ready!
#
echo "if there were no errors, tailscale should be installed and ready!"
echo ""

