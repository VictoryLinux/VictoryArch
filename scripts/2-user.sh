#!/usr/bin/env bash
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
                      
                       SCRIPTHOME: VictoryArch
-------------------------------------------------------------------------

Installing AUR Softwares
"
source $HOME/VictoryArch/configs/setup.conf

  #cd ~
  #mkdir "/home/$USERNAME/.cache"
  #touch "/home/$USERNAME/.cache/zshhistory"
  #git clone "https://github.com/ChrisTitusTech/zsh"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
  #ln -s "~/zsh/.zshrc" ~/.zshrc

sed -n '/'$INSTALL_TYPE'/q;p' ~/VictoryArch/pkg-files/${DESKTOP_ENV}.txt | while read line
do
  if [[ ${line} == '--END OF MINIMAL INSTALL--' ]]
  then
    # If selected installation type is FULL, skip the --END OF THE MINIMAL INSTALLATION-- line
    continue
  fi
  echo "INSTALLING: ${line}"
  sudo pacman -S --noconfirm --needed ${line}
done


if [[ ! $AUR_HELPER == none ]]; then
  cd ~
  git clone "https://aur.archlinux.org/$AUR_HELPER.git"
  cd ~/$AUR_HELPER
  makepkg -si --noconfirm
  # sed $INSTALL_TYPE is using install type to check for MINIMAL installation, if it's true, stop
  # stop the script and move on, not installing any more packages below that line
  sed -n '/'$INSTALL_TYPE'/q;p' ~/VictoryArch/pkg-files/aur-pkgs.txt | while read line
  do
    if [[ ${line} == '--END OF MINIMAL INSTALL--' ]]; then
      # If selected installation type is FULL, skip the --END OF THE MINIMAL INSTALLATION-- line
      continue
    fi
    echo "INSTALLING: ${line}"
    $AUR_HELPER -S --noconfirm --needed ${line}
  done
fi

export PATH=$PATH:~/.local/bin

# Theming DE if user chose FULL installation
if [[ $INSTALL_TYPE == "FULL" ]]; then
  if [[ $DESKTOP_ENV == "kde" ]]; then
    cp -r ~/VictoryArch/configs/.config/* ~/.config/
    pip install konsave
    konsave -i ~/VictoryArch/configs/kde.knsv
    sleep 1
    konsave -a kde
  elif [[ $DESKTOP_ENV == "openbox" ]]; then
    cd ~
    git clone https://github.com/stojshic/dotfiles-openbox
    ./dotfiles-openbox/install-titus.sh
  fi
fi

echo -ne "
-------------------------------------------------------------------------
                    SYSTEM READY FOR 3-post-setup.sh
-------------------------------------------------------------------------
"
exit
