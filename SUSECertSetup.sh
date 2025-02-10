#!/usr/bin/env bash


# CREATOR: Mike Lu (klu7@lenovo.com)
# CHANGE DATE: 2/10/2025
__version__="1.0"


# SUSE Enterprise Linux Server Hardware Certification Test Environment Setup Script
# [Note] The OS version installed on TC MUST be older than the SUT (for example: TC: 15-SP5   SUT: 15-SP6)

# Prerequisites for TC:
# Boot to GM (n-1) ISO
#    a) Select "SUSE Linux Enterprise Server" to install
#    b) Skip Registration
#    c) Select the following 5 modules/extensions
#         - Basesystem Module
#         - Desktop Application Module
#         - Development Tools Module
#         - SUSE Linux Enterprise Workstation Extension
#         - Server Application Module
#    d) Skip User creation
#    e) Set root password -> suse
# Boot to OS
#    a) Put all the tools (OS ISO/product.zip/Current_SCK.zip) to the same directory as this script
# SCK installation prompt
#    a) Enter the TestConsole's IP address -> 10.1.1.2
#    b) Select installation type option -> TC
#    c) Set SMB password -> suse
#    d) Make the machine a DHCP/PXE server -> yes
#    e) Select the nic used to serve DHCP -> eth0
#    f) Change the dhcp available address range -> No
#    g) Add new PXE install menu items from local ISO image

# Prerequisites for SUT:
# PXE boot
#    a) Select option "Server single disk automated install"



# User-defined settings
TIME_ZONE='Asia/Taipei'
OS_FILENAME_15SP5="SLE-15-SP5-Full-x86_64-GM-Media1.iso"
OS_FILENAME_15SP6="SLE-15-SP6-Full-x86_64-GM-Media1.iso"


# Fixed settings
SCK_URL='http://sdk.suse.com/ndk/systest/builds/current/Current_SCK.zip'
Products_URL='http://sdk.suse.com/ndk/certfiles/products.zip'
SCK_FILENAME="Current_SCK.zip"
Products_FILENAME="products.zip"
red='\e[41m'
green='\e[32m'
yellow='\e[93m'
nc='\e[0m'


# Ensure the user is running the script as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${yellow}Please run as root (sudo su) to start the installation.${nc}"

else
    # Customize keyboard shortcut
    TC_OS_VER=`cat /etc/os-release | grep ^VERSION_ID= | awk -F= '{print $2}' | cut -d '"' -f2`
    ID=`id -u $USERNAME`
    sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/','/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/']"

  
    # Open Terminal (Ctrl+Alt+T)
    sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name 'Terminal'     
    sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command 'gnome-terminal' 
    sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding '<ctrl><alt>t' 


    # Enable dark mode
    if [[ $TC_OS_VER == '15.6' ]]; then 
        sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    elif [[ $TC_OS_VER == '15.5' ]]; then 
        dconf write /org/gnome/desktop/interface/gtk-theme "'Adwaita-dark'"
    fi
	
    # Open Current folder (Super+E)
    sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ name 'Current folder' 
    sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ command 'nautilus .' 
    sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ binding '<super>e' 

  
    # Open Settings (Super+I)
    sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ name 'Settings' 
    sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ command 'gnome-control-center' 
    sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ binding '<super>i'


    # Set proxy to automatic
    sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.system.proxy mode 'auto' 2> /dev/null


    # Disable auto suspend/dim screen/screen blank/auto power-saver
    sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type "nothing" 2> /dev/null
    sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type "nothing" 2> /dev/null
    sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.power idle-dim "false" 2> /dev/null
    sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.desktop.session idle-delay "0" > /dev/null 2> /dev/null
    sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.power power-saver-profile-on-low-battery "false" 2> /dev/null


    # Show battery percentage
    sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.desktop.interface show-battery-percentage "true" 2> /dev/null


    # Enable SSH and disable firewall
    ! systemctl status sshd | grep 'running' > /dev/null && systemctl enable sshd && systemctl start sshd
    systemctl status firewalld | grep 'running' > /dev/null && systemctl stop firewalld && systemctl disable firewalld
 
 
    # Set local time zone and reset NTP
    timedatectl set-timezone $TIME_ZONE
    ln -sf /usr/share/zoneinfo/$TIME_ZONE /etc/localtime
    timedatectl set-ntp 0 && sleep 1 && timedatectl set-ntp 1


    # Ensure Internet is connected
    CheckInternet() {
        nslookup "google.com" > /dev/null
        if [ $? != 0 ]; then 
            echo -e "${red}No Internet connection! Please check your network${nc}" && sleep 5 && exit 1
        fi
    }
    #CheckInternet


    # Get system type from user
    echo "╭───────────────────────────────────────────────────────╮"
    echo "│    SLES YES Certification Test Environment Setup      │"
    echo "╰───────────────────────────────────────────────────────╯"
    echo "Are you setting up a SUT or TC?"
    read -p "(s)SUT   (t)TC: " TYPE
    while [[ "$TYPE" != [SsTt] ]]; do 
        read -p "(s)SUT   (t)TC: " TYPE
    done   
    
	
    #================ TC ===================
    if [[ "$TYPE" == [Tt] ]]; then
        echo "Which OS version are you going to certify for SUT?"
        read -p "(1)15 SP6   (2)15 SP5: " SUT_OS_VER
        while [[ "$SUT_OS_VER" != [12] ]]; do 
            read -p "(1)15 SP6   (2)15 SP5: " SUT_OS_VER
        done


        # Set hostname for TC
        ! hostname | grep 'TC' > /dev/null && hostnamectl set-hostname 'TC' 

	
        # Set IP and netmask for TC
        echo
        echo "-----------------------------"
        echo "CONFIGURING TC NETWORK IP...."
        echo "-----------------------------"
        echo
        declare -A ip_addresses=(
	    ["eth0"]="10.1.1.2"
	    ["eth1"]="10.1.2.2"
	    ["eth2"]="10.1.3.2"
	    ["eth3"]="10.1.4.2"
        )
        NETMASK="24"
        for interface in eth0 eth1 eth2 eth3; do 
            if ip a | grep -q $interface; then
                CONFIG_FILE="/etc/sysconfig/network/ifcfg-$interface"
                IPADDR=${ip_addresses[$interface]}  
                # Check if the IP and netmask have been correctly set to avoid repeating
                if [[ -f "$CONFIG_FILE" ]]; then
                    current_ip=$(cat "$CONFIG_FILE" | grep 'IPADDR' | awk -F "'" '{print $2}')
                    if [[ "$current_ip" == "$IPADDR/$NETMASK" ]]; then
                        continue
                    else
                        rm -f "$CONFIG_FILE"
                    fi
                fi
                echo "Configuring $interface with IP $IPADDR" 
                echo "IPADDR='$IPADDR/$NETMASK'" | sudo tee -a "$CONFIG_FILE" > /dev/null
                echo "BOOTPROTO='static'" | sudo tee -a "$CONFIG_FILE" > /dev/null
                echo "STARTMODE='auto'" | sudo tee -a "$CONFIG_FILE" > /dev/null
                sudo systemctl restart network
            fi
        done
        [[ $? == 0 ]] && echo -e "\n${green}Done.${nc}\n"

        # Move or download required tools
        echo
        echo "----------------------"
        echo "LOCATING TEST TOOLS..."
        echo "----------------------"
        echo
        mkdir -p /home/iso /home/tools /home/cdrom
        if [[ ! -f /home/tools/$SCK_FILENAME ]]; then
            if [[ -f ./$SCK_FILENAME ]]; then
                mv ./$SCK_FILENAME /home/tools/
            else
                wget -P /home/tools $SCK_URL
            fi
        fi
        if [[ ! -f /home/tools/$Products_FILENAME ]]; then
            if [[ -f ./$Products_FILENAME ]]; then
                mv ./$Products_FILENAME /home/tools/
            else
                wget -P /home/tools $Products_URL
            fi
        fi
        if [[ $SUT_OS_VER == "1" ]]; then
            if [[ ! -f /home/iso/$OS_FILENAME_15SP6 ]]; then
                if [[ -f ./$OS_FILENAME_15SP6 ]]; then
                    mv ./$OS_FILENAME_15SP6 /home/iso/
                else
                    echo -e "${yellow}Please put the OS ISO file to the same directory as this script.${nc}"
                    exit 1
                fi
            fi
        elif [[ $SUT_OS_VER == "2" ]]; then
            if [[ ! -f /home/iso/$OS_FILENAME_15SP5 ]]; then
                if [[ -f ./$OS_FILENAME_15SP5 ]]; then
                    mv ./$OS_FILENAME_15SP5 /home/iso/
                else
                    echo -e "${yellow}Please put the OS ISO file to the same directory as this script.${nc}"
                    exit 1
                fi
            fi
        fi
	    [[ $? == 0 ]] && echo -e "\n${green}Done.${nc}\n"
	
        # Unzip SCK.zip and products.zip files
        find "/home/tools/" -name "*.zip" -exec unzip -q -o {} -d "/home/tools/" \;
        
        # Delete unwanted repos (List repo: zypper lr   Remove repo: zypper rr) 
        echo
        echo "-----------------------------------"
        echo "DELETING UNWANTED SOFTWARE REPOS..."
        echo "-----------------------------------"
        echo
        while true; do
            REPOS=`zypper lr | grep -v -E '^[[:space:]]*$|^[R#-]' | grep -vE "(No repositories defined|Use the 'zypper addrepo' command)" | wc -l`
            if [[ $REPOS -gt 0 ]]; then
                for REPO in $(seq 1 $REPOS); do
                    zypper rr $REPO 2> /dev/null
                done
            else
                break
            fi
        done
        [[ $? == 0 ]] && echo -e "\n${green}Done.${nc}\n"
		
		
        # Add local ISO image to repo
        echo
        echo "--------------------------"
        echo "UPDATING SOFTWARE REPOS..."
        echo "--------------------------"
        echo
        case $SUT_OS_VER in		
        "1") # 15 SP6
            ISO_PATH=/home/iso/$OS_FILENAME_15SP6
            declare -A MODULE_ID
            MODULE_ID=(
                ["Module-Basesystem"]="sle-module-basesystem"
                ["Module-Containers"]="sle-module-containers"
                ["Module-Desktop-Applications"]="sle-module-desktop-applications"
                ["Module-Development-Tools"]="sle-module-development-tools"
                ["Module-HPC"]="sle-module-hpc"
                ["Module-Legacy"]="sle-module-legacy"
                ["Module-Live-Patching"]="sle-module-live-patching"
                ["Module-Public-Cloud"]="sle-module-public-cloud"
                ["Module-Python3"]="sle-module-python3"
                ["Module-SAP-Applications"]="sle-module-sap-applications"
                ["Module-SAP-Business-One"]="sle-module-sap-business-one"
                ["Product-HA"]="sle-ha"
                ["Product-WE"]="sle-we"
                ["Module-RT"]="sle-module-rt"
                ["Module-Server-Applications"]="sle-module-server-applications"
                ["Module-Transactional-Server"]="sle-module-transactional-server"
                ["Module-Web-Scripting"]="sle-module-web-scripting"
            )
            MODULES=(
                "Module-Basesystem"           # Name: Basesystem-Module 15.6-0   
                "Module-Containers"           # Name: Containers-Module 15.6-0  
                "Module-Desktop-Applications" # Name: Desktop-Applications-Module 15.6-0  
                "Module-Development-Tools"    # Name: Development-Tools-Module 15.6-0  
                "Module-HPC"                  # Name: HPC-Module 15.6-0  
                "Module-Legacy"               # Name: Legacy-Module 15.6-0  
                "Module-Live-Patching"        # Name: Live-Patching-Module 15.6-0  
                "Module-Public-Cloud"         # Name: Public-Cloud-Module 15.6-0
                "Module-Python3"              # Name: Python3-Module 15.6-0
                "Module-SAP-Applications"     # Name: SAP-Applications-Module 15.6-0
                "Module-SAP-Business-One"     # Name: SAP-Business-One-Module 15.6-0
                "Product-HA"                  # Name: SLEHA15-SP6 15.6-0 
                "Product-WE"                  # Name: SLEWE15-SP6 15.6-0
                "Module-RT"                   # Name: SUSE-Real-Time-Module 15.6-0
                "Module-Server-Applications"  # Name: Server-Applications-Module 15.6-0
                "Module-Transactional-Server" # Name: Transactional-Server-Module 15.6-0
                "Module-Web-Scripting"        # Name: Web-Scripting-Module 15.6-0
            )
            ;;
        "2") # 15 SP5
            ISO_PATH=/home/iso/$OS_FILENAME_15SP5
            declare -A MODULE_ID
            MODULE_ID=(
                ["Module-Basesystem"]="sle-module-basesystem"
                ["Module-Containers"]="sle-module-containers"
                ["Module-Desktop-Applications"]="sle-module-desktop-applications"
                ["Module-Development-Tools"]="sle-module-development-tools"
                ["Module-HPC"]="sle-module-hpc"
                ["Module-Legacy"]="sle-module-legacy"
                ["Module-Live-Patching"]="sle-module-live-patching"
                ["Module-Public-Cloud"]="sle-module-public-cloud"
                ["Module-Python3"]="sle-module-python3"
                ["Module-SAP-Applications"]="sle-module-sap-applications"
                ["Module-SAP-Business-One"]="sle-module-sap-business-one"
                ["Product-HA"]="sle-ha"
                ["Product-WE"]="sle-we"
                ["Module-RT"]="sle-module-rt"
                ["Module-Server-Applications"]="sle-module-server-applications"
                ["Module-Transactional-Server"]="sle-module-transactional-server"
                ["Module-Web-Scripting"]="sle-module-web-scripting"
            )
            MODULES=(
                "Module-Basesystem"           # Name: Basesystem-Module 15.5-0
                "Module-Containers"           # Name: Containers-Module 15.5-0
                "Module-Desktop-Applications" # Name: Desktop-Applications-Module 15.5-0
                "Module-Development-Tools"    # Name: Development-Tools-Module 15.5-0
                "Module-HPC"                  # Name: HPC-Module 15.5-0
                "Module-Legacy"               # Name: Legacy-Module 15.5-0
                "Module-Live-Patching"        # Name: Live-Patching-Module 15.5-0
                "Module-Public-Cloud"         # Name: Public-Cloud-Module 15.5-0
                "Module-Python3"              # Name: Python3-Module 15.5-0
                "Module-SAP-Applications"     # Name: SAP-Applications-Module 15.5-0
                "Module-SAP-Business-One"     # Name: SAP-Business-One-Module 15.5-0
                "Product-HA"                  # Name: SLEHA15-SP6 15.5-0
                "Product-WE"                  # Name: SLEWE15-SP6 15.5-0
                "Module-RT"                   # Name: SUSE-Real-Time-Module 15.5-0
                "Module-Server-Applications"  # Name: Server-Applications-Module 15.5-0
                "Module-Transactional-Server" # Name: Transactional-Server-Module 15.5-0
                "Module-Web-Scripting"        # Name: Web-Scripting-Module 15.5-0
            )
            ;;
        esac
        
        MOUNT_POINT=/mnt/iso
        # Unmount existing OS ISO
        umount "$MOUNT_POINT" 2> /dev/null
        mkdir -p "$MOUNT_POINT"
        mount "$ISO_PATH" "$MOUNT_POINT" || { echo -e "${red}Mount OS ISO failed!${nc}"; exit 1; } 
        for module in "${MODULES[@]}"; do
            module_ID="${MODULE_ID[$module]}"
            zypper ar "dir:${MOUNT_POINT}/${module}" ${module_ID} || { echo -e "${red}zypper ar failed for $module${nc}"; exit 1; }
        done
        
        # Refresh matadata
        zypper ref   
			
        # Rebuild cache
        zypper clean
			
        # List products	     
        zypper pd
        [[ $? == 0 ]] && echo -e "\n${green}Done.${nc}\n"

        # Mount SCK tool ISO
        iso_file=$(find "/home/tools/Current_SCK" -name "*.iso") 
        sudo mount -o loop,ro "$iso_file" /home/cdrom
			
        # Install SCK
        # [Note] Manually add product.zip (path: /home/tools) after SCK is launched
        echo
        echo "--------------------------"
        echo "INSTALLING TEST CONSOLE..."
        echo "--------------------------"
        echo
        [[ -f /home/cdrom/sck_install.sh ]] && bash /home/cdrom/sck_install.sh
        if [[ $? == 0 ]]; then
            systemctl restart chronyd
            echo -e "\n${green}All set! You are okay to go :)${nc}\n"
            read -p "Launch SCK tool now? (y/n): " LAUNCH
            while [[ "$LAUNCH" != [YyNn] ]]; do 
                read -p "Launch SCK tool now? (y/n): " LAUNCH
            done
        else
            echo -e "\n${red}SCK was not installed successfully${nc}\n"
            exit 1
        fi
        [[ $LAUNCH == [Yy] ]] && bash /opt/suse/testKits/bin/testconsole.sh
        [[ $LAUNCH == [Nn] ]] && exit
			
				
        ## Reconfigure or remove SCK (Uncomment to run if needed)
        # bash /opt/suse/testKits/system/bin/configinstserver.sh
               

    #================ SUT ===================
    elif [[ "$TYPE" == [Ss] ]]; then
    
        # Set hostname for SUT
        ! hostname | grep 'SUT' > /dev/null && hostnamectl set-hostname 'SUT' 

        # Start NTP and sync with TC
        echo
        echo "--------------------------"
        echo "SYNC NTP SERVER WITH TC..."
        echo "--------------------------"
        echo
        systemctl start chronyd
        systemctl enable chronyd
        if ! grep -q "server 10.1.1.2 iburst prefer" /etc/chrony.conf; then
            echo "server 10.1.1.2 iburst prefer" >> /etc/chrony.conf
        fi
        sed -i 's/NETCONFIG_NTP_POLICY="auto"/NETCONFIG_NTP_POLICY="Static"/' /etc/sysconfig/network/config
        sed -i 's/NETCONFIG_NTP_STATIC_SERVERS=""/NETCONFIG_NTP_STATIC_SERVERS="10.1.1.2"/' /etc/sysconfig/network/config
        netconfig update
        systemctl restart chronyd
        chronyc sources
        # Wait 5 secs for NTP to sync
        sleep 5
        chronyc tracking
        [[ $? == 0 ]] && echo -e "\n${green}Done.${nc}\n"
			
		
        # Set IP and netmask for SUT
        echo
        echo "-----------------------------"
        echo "CONFIGURING SUT NETWORK IP..."
        echo "-----------------------------"
        echo
        declare -A ip_addresses=(
        ["eth0"]="10.1.1.1"
        ["eth1"]="10.1.2.1"
        ["eth2"]="10.1.3.1"
        ["eth3"]="10.1.4.1"
        )
        NETMASK="24"
        for interface in eth0 eth1 eth2 eth3; do 
            if ip a | grep -q $interface; then
                CONFIG_FILE="/etc/sysconfig/network/ifcfg-$interface"
                IPADDR=${ip_addresses[$interface]}  
                # Check if the IP and netmask have been correctly set to avoid repeating
                if [[ -f "$CONFIG_FILE" ]]; then
                    current_ip=$(cat "$CONFIG_FILE" | grep 'IPADDR' | awk -F "'" '{print $2}')
                    if [[ "$current_ip" == "$IPADDR/$NETMASK" ]]; then
                        continue
                    else
                        rm -f "$CONFIG_FILE"
                    fi
                fi
                echo "Configuring $interface with IP $IPADDR" 
                echo "IPADDR='$IPADDR/$NETMASK'" | sudo tee -a "$CONFIG_FILE" > /dev/null
                echo "BOOTPROTO='static'" | sudo tee -a "$CONFIG_FILE" > /dev/null
                echo "STARTMODE='auto'" | sudo tee -a "$CONFIG_FILE" > /dev/null
                sudo systemctl restart network
            fi
        done
        [[ $? == 0 ]] && echo -e "\n${green}Done.${nc}\n"        
		
        # Install ipmctl tool on SUT and configure PMEMs
        echo
        echo "---------------------"
        echo "CONFIGURING PMEMS...."
        echo "---------------------"
        echo
        [[ ! -f /usr/bin/ipmctl ]] && zypper --non-interactive install ipmctl
        ipmctl show -dimm && ipmctl show -memoryresources && ipmctl show -region && ipmctl create -goal PersistentMemoryType=AppDirect
			
        # Create namespace
        while true; do
            ndctl create-namespace --mode=fsdax
            if [[ $? != 0 ]]; then
                break
            fi
        done
        # Check if at least one PMEM device exists
        if find /dev/pmem* -maxdepth 0 -print -quit 2>/dev/null; then
            for pmem_device in /dev/pmem*; do
                pmem_id=$(echo "$pmem_device" | grep -oE '^/dev/pmem([0-9]+)$' | cut -d'm' -f2)
                if [[ -n "$pmem_id" ]]; then
                    if ! mkfs.xfs "$pmem_device"; then
                        echo -e "${red}Failed to create filesystem on $pmem_device${nc}"
                        exit 1
                    fi
                    mkdir -p "/mnt/pmem$pmem_id"
                    if [[ $? != 0 ]]; then
                        echo -e "${red}Failed to create mount point /mnt/pmem$pmem_id${nc}"
                        exit 1
                    fi
                    echo "$pmem_device /mnt/pmem$pmem_id xfs defaults 0 0" >> /etc/fstab
                    if ! mount "/mnt/pmem$pmem_id"; then
                        echo -e "${red}Failed to mount $pmem_device${nc}"
                        exit 1
                    fi
                fi
            done
        else  
            echo "PMEM devices not found. Skipping to create namespace..."
        fi
        [[ $? == 0 ]] && echo -e "\n${green}All set! You are okay to go :)${nc}\n"
    fi	
	
fi

exit

