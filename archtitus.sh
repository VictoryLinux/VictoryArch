#!/bin/bash

# Find the name of the folder the scripts are in
set -a
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
SCRIPTS_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"/scripts
CONFIGS_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"/configs
set +a
echo -ne "
-------------------------------------------------------------------------
       ____    ____  __                                              
       \   \  /   / |__| ____ ________    ____    _______ ___  ___   
        \   \/   /  ___ |   _|\__   __\ /   _  \ |  __   |\  \/  /   
         \      /  |   ||  |_   |  |   |   |_|  ||  | |__| \   /     
          \____/   |___||____|  |__|    \_____ / |__|       |_|      
                                                                
-------------------------------------------------------------------------
                     █████╗ ██████╗  ██████╗██╗  ██╗                  
                    ██╔══██╗██╔══██╗██╔════╝██║  ██║                  
                    ███████║██████╔╝██║     ███████║                  
                    ██╔══██║██╔══██╗██║     ██╔══██║                  
                    ██║  ██║██║  ██║╚██████╗██║  ██║                  
                    ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝                  
-------------------------------------------------------------------------
                    Automated Arch Linux Installer
                        Forked from ArchTitus
-------------------------------------------------------------------------
                Scripts are in directory named VictoryArch
"
    ( bash $SCRIPT_DIR/scripts/startup.sh )|& tee startup.log
      source $CONFIGS_DIR/setup.conf
    ( bash $SCRIPT_DIR/scripts/0-preinstall.sh )|& tee 0-preinstall.log
    ( arch-chroot /mnt $HOME/VictoryArch/scripts/1-setup.sh )|& tee 1-setup.log
    if [[ ! $DESKTOP_ENV == server ]]; then
      ( arch-chroot /mnt /usr/bin/runuser -u $USERNAME -- /home/$USERNAME/VictoryArch/scripts/2-user.sh )|& tee 2-user.log
    fi
    ( arch-chroot /mnt $HOME/VictoryArch/scripts/3-post-setup.sh )|& tee 3-post-setup.log
    cp -v *.log /mnt/home/$USERNAME

echo -ne "
-------------------------------------------------------------------------
       ____    ____  __                                              
       \   \  /   / |__| ____ ________    ____    _______ ___  ___   
        \   \/   /  ___ |   _|\__   __\ /   _  \ |  __   |\  \/  /   
         \      /  |   ||  |_   |  |   |   |_|  ||  | |__| \   /     
          \____/   |___||____|  |__|    \_____ / |__|       |_|      
                                                                
-------------------------------------------------------------------------
                     █████╗ ██████╗  ██████╗██╗  ██╗                  
                    ██╔══██╗██╔══██╗██╔════╝██║  ██║                  
                    ███████║██████╔╝██║     ███████║                  
                    ██╔══██║██╔══██╗██║     ██╔══██║                  
                    ██║  ██║██║  ██║╚██████╗██║  ██║                  
                    ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝                  
-------------------------------------------------------------------------
                    Automated Arch Linux Installer
                        Forked from ArchTitus
-------------------------------------------------------------------------
                Done - Please Eject Install Media and Reboot
"
