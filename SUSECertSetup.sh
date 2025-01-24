#!/usr/bin/env bash


# CREATOR: Mike Lu (klu7@lenovo.com)
# CHANGE DATE: 1/17/2025
__version__="1.0"


# SUSE Enterprise Linux Server Hardware Certification Test Environment Setup Script


SCK='http://sdk.suse.com/ndk/systest/builds/current/Current_SCK.zip'
Products='http://sdk.suse.com/ndk/certfiles/products.zip'



# Ensure the user is running the script as root
if [ "$EUID" -ne 0 ]; then 
    echo "⚠️ Please run as root (sudo su) to start the installation."

else

    # Customize keyboard shortcut
    OS_VERSION=`cat /etc/os-release | grep ^VERSION_ID= | awk -F= '{print $2}' | cut -d '"' -f2`
    ID=`id -u $USERNAME`
    sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/','/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/']"
  
    # Open Terminal (Ctrl+Alt+T)
    sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name 'Terminal'     
    sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command 'gnome-terminal' 
    sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding '<ctrl><alt>t' 

    # Enable dark mode
	sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
	
    # Open Current folder (Super+E)
    sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ name 'Current folder' 
    sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ command 'nautilus .' 
    sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ binding '<super>e' 
  
    # Open Settings (Super+I)
    sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ name 'Settings' 
    sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ command 'gnome-control-center' 
    sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ binding '<super>i'


    # Set proxy to automatic
    # sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.system.proxy mode 'auto' 2> /dev/null


    # Disable auto suspend/dim screen/screen blank/auto power-saver
    sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type "nothing" 2> /dev/null
    # sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type "nothing" 2> /dev/null
    sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.power idle-dim "false" 2> /dev/null
    sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.desktop.session idle-delay "0" > /dev/null 2> /dev/null
    # sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.power power-saver-profile-on-low-battery "false" 2> /dev/null


    # Show battery percentage
    # sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.desktop.interface show-battery-percentage "true" 2> /dev/null

  
    # Set time zone and reset NTP
    timedatectl set-timezone Asia/Taipei
    timedatectl set-ntp 0 && sleep 1 && timedatectl set-ntp 1


    # Ensure Internet is connected
    nslookup "google.com" > /dev/null
    if [ $? != 0 ]; then 
        echo "❌ No Internet connection! Please check your network" && sleep 5 && exit 1
    fi


    # Configure required tools
    mkdir -p /home/iso /home/tools /home/cdrom
	[[ ! -f /home/tools/Current_SCK.zip ]] && wget -P /home/tools $SCK
	[[ ! -f /home/tools/products.zip ]] && wget -P /home/tools $Products

    
	# Delete unwanted repos
	while true; do
	    REPOS=`zypper lr | grep -v -E '^[[:space:]]*$|^[R#-]' | wc -l`
	    if [[ $REPOS -gt 0 ]]; then
	        for REPO in $(seq 1 $REPOS); do
	            zypper rr $REPO
			done
		else
		    break
		fi
	done
	zypper lr # 檢查repo
	zypper rr # 刪除repo
	
	
	zypper clean
	zypper ref
	zypper pd
	
	mount 测试工具.iso /home/cdrom/
	bash  /home/cdrom/sck_install.sh
	

fi

exit

