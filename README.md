# SLES Hardware Certification Test Environment Setup Script

#### [Release Note]
1.	Customized function includes hotkey/disable auto-suspend/collect test log..,etc
2.	Support SLES 15 SP5/SP6


#### [Note] The OS version installed on TC MUST be older than the SUT (for example: TC 15 SP5 vs. SUT 15 SP6)

## Prerequisites for Test Console (TC) 
1. Boot from the GM (n-1) ISO
2. Select "SUSE Linux Enterprise Server" for installation
3. Skip registration
4. Select the following modules/extensions:
    * Basesystem Module
    * Desktop Application Module
    * Development Tools Module
    * SUSE Linux Enterprise Workstation Extension
    * Server Application Module
5. Skip user creation
6. Set the root password to `suse`

### Boot into the installed OS

Place all necessary tools (OS ISO, `product.zip`, `Current_SCK.zip`) in the same directory as this script

### SCK installation prompts

1. Enter the TestConsole's IP address: `10.1.1.2`
2. Select installation type: `TC`
3. Set the SMB password: `suse`
4. Configure the machine as a DHCP/PXE server: `yes`
5. Select the network interface for DHCP: `eth0`
6. Keep the default DHCP address range: `No`
7. Add new PXE install menu items from the local ISO image

## Prerequisites for System Under Test (SUT)

1. PXE boot the SUT
2. Select the option: "Server single disk automated install"
