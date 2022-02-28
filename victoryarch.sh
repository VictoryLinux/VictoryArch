#!/bin/bash
# Finish Setup my ArcoLinux

#####################################################################
#  ____    ____  __                                                 #
#  \   \  /   / |__| ____ ________    ____    _______ ___  ___      #
#   \   \/   /  ___ |   _|\__   __\ /   _  \ |  __   |\  \/  /      #
#    \      /  |   ||  |_   |  |   |   |_|  ||  | |__| \   /        #
#     \____/   |___||____|  |__|    \_____ / |__|       |_|         #
#                                                                   #
# Victory Linux ArchLinux Setup                                     #
# https://github.com/VictoryLinux                                   #
#####################################################################


echo -e "----------------------------------------------------------------"
echo -e "  ____    ____  __                                              "
echo -e "  \   \  /   / |__| ____ ________    ____    _______ ___  ___   "
echo -e "   \   \/   /  ___ |   _|\__   __\ /   _  \ |  __   |\  \/  /   "
echo -e "    \      /  |   ||  |_   |  |   |   |_|  ||  | |__| \   /     "
echo -e "     \____/   |___||____|  |__|    \_____ / |__|       |_|      "
echo -e "                                                                "
echo -e "----------------------------------------------------------------"
echo -e "               █████╗ ██████╗  ██████╗██╗  ██╗                  "
echo -e "              ██╔══██╗██╔══██╗██╔════╝██║  ██║                  "
echo -e "              ███████║██████╔╝██║     ███████║                  "
echo -e "              ██╔══██║██╔══██╗██║     ██╔══██║                  "
echo -e "              ██║  ██║██║  ██║╚██████╗██║  ██║                  "
echo -e "              ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝                  "
echo -e "----------------------------------------------------------------"
echo -e "-Setting up $iso mirrors for faster downloads"
echo -e "----------------------------------------------------------------"


# Make sure each command executes properly
check_exit_status() {

	if [ $? -eq 0 ]
	then
		echo
		echo "Success"
		echo
	else
		echo
		echo "[ERROR] Update Failed! Check the errors and try again"
		echo
		
		read -p "The last command exited with an error. Exit script? (y/n) " answer

            if [ "$answer" == "y" ]
            then
                exit 1
            fi
	fi
}

function greeting() {
	clear

	echo -e "----------------------------------------------------------------"
echo -e "  ____    ____  __                                              "
echo -e "  \   \  /   / |__| ____ ________    ____    _______ ___  ___   "
echo -e "   \   \/   /  ___ |   _|\__   __\ /   _  \ |  __   |\  \/  /   "
echo -e "    \      /  |   ||  |_   |  |   |   |_|  ||  | |__| \   /     "
echo -e "     \____/   |___||____|  |__|    \_____ / |__|       |_|      "
echo -e "                                                                "
echo -e "----------------------------------------------------------------"
echo -e "               █████╗ ██████╗  ██████╗██╗  ██╗                  "
echo -e "              ██╔══██╗██╔══██╗██╔════╝██║  ██║                  "
echo -e "              ███████║██████╔╝██║     ███████║                  "
echo -e "              ██╔══██║██╔══██╗██║     ██╔══██║                  "
echo -e "              ██║  ██║██║  ██║╚██████╗██║  ██║                  "
echo -e "              ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝                  "
echo -e "----------------------------------------------------------------"
echo -e "-Setting up $iso mirrors for faster downloads"
echo -e "----------------------------------------------------------------"

	echo
#	sleep 5s
	echo "ARE YOU READY TO START? [y,n]"
	read input

	# did we get an input value?
	if [ "$input" == "" ]; then

	   echo "Nothing was entered by the user"

	# was it a y or a yes?
	elif [[ "$input" == "y" ]] || [[ "$input" == "yes" ]]; then

	   echo "You replied $input, you are ready to start"
	   echo
	   echo "Starting VictoryArch Post install script."
	   echo
	   sleep 3s

	# treat anything else as a negative response
	else

	   echo "You replied $input, you are not ready"
	   echo
	   exit 1

fi

	echo
	
	check_exit_status
}

# searching for the fastest mirrors
function mirror() {

	echo "Updating your Mirrors."
	sudo reflector -f 30 -l 30 --number 10 --verbose --save /etc/pacman.d/mirrorlist;
	check_exit_status
}

# Installing any Arch Linux Updates
function general_update() {

	echo "Updating ArchLinux."
	echo
	sleep 3s
	sudo pacman -Syyu --noconfirm;
	check_exit_status
}

# Debloat
function debloat() {

	echo "Debloating."
	echo
	sleep 3s
    sudo pacman -Rdsu gnome-books gnome-clocks gnome-maps gnome-music gnome-weather gnome-boxes --noconfirm
	check_exit_status
}

# cpu
function cpu() {

# determine processor type and install microcode
proc_type=$(lscpu | awk '/Vendor ID:/ {print $3}')
case "$proc_type" in
	GenuineIntel)
		print "Installing Intel microcode"
		pacman -S --noconfirm intel-ucode
		proc_ucode=intel-ucode.img
		;;
	AuthenticAMD)
		print "Installing AMD microcode"
		pacman -S --noconfirm amd-ucode
		proc_ucode=amd-ucode.img
		;;
esac	
	check_exit_status
}

# gpu
function gpu() {

	# Graphics Drivers find and install
if lspci | grep -E "NVIDIA|GeForce"; then
    pacman -S nvidia --noconfirm --needed
	nvidia-xconfig
elif lspci | grep -E "Radeon"; then
    pacman -S xf86-video-amdgpu --noconfirm --needed
elif lspci | grep -E "Integrated Graphics Controller"; then
    pacman -S libva-intel-driver libvdpau-va-gl lib32-vulkan-intel vulkan-intel libva-intel-driver libva-utils --needed --noconfirm
fi

echo -e "\nDone!\n"
if [ $(whoami) = "root"  ];
then
    useradd -m -G wheel,libvirt -s /bin/bash $username 
	passwd $username
	cp -R /root/VictoryArch-Post /home/$username/
    chown -R $username: /home/$username/VictoryArch-Post
	read -p "Please name your machine:" nameofmachine
	echo $nameofmachine > /etc/hostname
else
	echo "You are already a user proceed with aur installs"
fi
	check_exit_status
}

# Running Arch Linux Setup Scripts
function packages() {
	echo
	#Add parallel downloading
sed -i 's/^#Para/Para/' /etc/pacman.conf

#Enable multilib
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
pacman -Sy --noconfirm

echo -e "\nInstalling Base System\n"

PKGS=(
'mesa' # Essential Xorg First
'xorg'
'xorg-server'
'xorg-apps'
'xorg-drivers'
'xorg-xkill'
'xorg-xinit'
'alacarte'
'ark' # compression
'autoconf' # build
'automake' # build
'base'
'bash-completion'
'bind'
'binutils'
'bison'
'bluez'
'bluez-libs'
'bluez-utils'
'btrfs-progs'
'celluloid' # video players
'cmatrix'
'cronie'
'cups'
'dconf-editor'
'dialog'
'dosfstools'
'dtc'
'efibootmgr' # EFI boot
'egl-wayland'
'exfat-utils'
'extra-cmake-modules'
'filelight'
'firefox'
'flatpak'
'flex'
'fuse2'
'fuse3'
'fuseiso'
'gamemode'
'gcc'
'gimp' # Photo editing
'git'
'gnome-tweaks'
'gparted' # partition management
'gptfdisk'
'grub-customizer'
'gst-libav'
'gst-plugins-good'
'gst-plugins-ugly'
'gwenview'
'haveged'
'htop'
'iptables-nft'
'jdk-openjdk' # Java 17
'kcodecs'
'kmail'
'kmag'
'layer-shell-qt'
'libdvdcss'
'libnewt'
'libtool'
'linux'
'linux-firmware'
'linux-headers'
'lsof'
'lzop'
'm4'
'make'
'milou'
'mtools'
'nano'
'neofetch'
'networkmanager'
'ntfs-3g'
'ntp'
'onboard'
'openbsd-netcat'
'openssh'
'os-prober'
'p7zip'
'pacman-contrib'
'patch'
'picom'
'pipewire'
#'pipewire-media-session'
'pkgconf'
'powerline-fonts'
'print-manager'
'python-notify2'
'python-psutil'
'python-pyqt5'
'python-pip'
'rsync'
'samba'
'smbclient'
'smbnetfs'
'gvfs-smb'
'python-pysmbc'
'snapper'
'starship'
'sudo'
'swtpm'
'terminator'
'terminus-font'
'thunar'
'traceroute'
'ufw'
'unrar'
'unzip'
'usbutils'
'variety'
'virtualbox'
'virtualbox-host-modules-arch'
'virtualbox-guest-utils'
'vscodium-bin'
'wireplumber'
'wget'
'which'
'xdg-user-dirs'
'youtube-dl'
'zeroconf-ioslave'
'zip'
)

for PKG in "${PKGS[@]}"; do
    echo "INSTALLING: ${PKG}"
    sudo pacman -S "$PKG" --noconfirm --needed
done

	check_exit_status
}

function aur() {
#echo "CLONING: YAY"
#cd ~
#git clone "https://aur.archlinux.org/yay.git"
#cd ${HOME}/yay
#makepkg -si --noconfirm
cd ~
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $HOME/powerlevel10k

	PKGS=(
'appimagelauncher'
'chrome-gnome-shell'
'awesome-terminal-fonts'
'brave-bin' # Brave Browser
'dxvk-bin' # DXVK DirectX to Vulcan
#'flat-remix'
#'flat-remix-gtk'
'github-desktop-bin' # Github Desktop sync
'gnome-shell-extension-blur-my-shell-git'
'gnome-shell-extension-impatience-git'
'gnome-shell-extension-task-icons-git'
'gnome-shell-extension-no-annoyance-git'
'gnome-shell-extension-dash-to-dock-git'
'gnome-shell-extension-tiling-assistant'
'gnome-shell-extension-extensions'
'gnome-shell-extension-caffeine-git'
'gnome-shell-extension-pop-shell-git'
'gnome-shell-extension-sound-output-device-chooser'
'gnome-shell-extension-vitals-git'
'gnome-shell-extension-gnome-ui-tune'
'inxi'
'loginized'
'multimc-bin'
'nerd-fonts-fira-code'
'pamac-all'
'papirus-icon-theme'
'popsicle-git'
'ocs-url' # install packages from websites
'onlyoffice-bin'
'snap-pac'
'stacer-bin'
'timeshift'
'timeshift-autosnap'
'ttf-droid'
'ttf-hack'
'ttf-meslo' # Nerdfont package
'ttf-roboto'
'xcursor-breeze'
'zoom' # video conferences
)

for PKG in "${PKGS[@]}"; do
    yay -S --noconfirm $PKG
done

    check_exit_status
}

# Install Flatpaks
function flatpaks() {
	sudo flatpak install flathub com.simplenote.Simplenote -y
    sudo flatpak install flathub com.mattjakeman.ExtensionManager -y
    sudo flatpak install flathub com.discordapp.Discord -y
    sudo flatpak install flathub com.bitwarden.desktop -y
    sudo flatpak install flathub nl.hjdskes.gcolor3 -y

    check_exit_status
}

#WALLPAPER
function wallpaper() {
cd ~/
git clone https://gitlab.com/dwt1/wallpapers.git

check_exit_status
}

#GRUB
function grub() {
cd $HOME/VictoryArch-Post/grub/
sudo ./install.sh

check_exit_status
}

#CONFIGS
function configs() {
export PATH=$PATH:~/.local/bin
cp -r $HOME/VictoryArch-Post/configs/* $HOME/.config/
echo
sudo mv -f $HOME/VictoryArch-Post/configs/pacman.conf /etc/
echo
mv $HOME/.config/bashrc $HOME/.config/.bashrc
mv $HOME/.config/.bashrc $HOME
echo
mv $HOME/.config/face $HOME/.config/.face
mv $HOME/.config/.face $HOME

#mv $HOME/.config/smb.conf $HOME /etc/samba/

check_exit_status
}

#APPEARANCE
function appearance() {
cd cd $HOME/VictoryArch-Post/
git clone https://github.com/daniruiz/flat-remix
git clone https://github.com/daniruiz/flat-remix-gtk
#mkdir -p ~/.icons && mkdir -p ~/.themes
#cp -r flat-remix/Flat-Remix* ~/.icons/ && cp -r flat-remix-gtk/themes/Flat-Remix* ~/.themes/
sudo mv flat-remix/Flat-Remix* /usr/share/icons/ 
sudo mv flat-remix-gtk/themes/Flat-Remix* /usr/share/themes/
rm -rf ~/flat-remix flat-remix-gtk
gsettings set org.gnome.desktop.interface gtk-theme "Flat-Remix-GTK-Blue-Dark"
gsettings set org.gnome.desktop.interface icon-theme "Flat-Remix-Blue-Dark"
echo
gsettings set org.gnome.shell favorite-apps "['brave-browser.desktop', 'firefox.desktop', 'org.gnome.Nautilus.desktop', 'terminator.desktop', 'com.simplenote.Simplenote.desktop', 'virtualbox.desktop', 'com.visualstudio.code.desktop', 'onboard.desktop']"
gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
gsettings set org.gnome.desktop.interface clock-format '12h'   
gsettings set org.gnome.desktop.interface cursor-theme 'Breeze'

check_exit_status
}

#EXTENSIONS
function extensions() {
gnome-extensions enable caffeine@patapon.info
gnome-extensions enable dash-to-dock@micxgx.gmail.com
gnome-extensions enable impatience@gfxmonk.net
gnome-extensions enable noannoyance@daase.net
gnome-extensions enable pop-shell@system76.com
gnome-extensions enable tiling-assistant@leleat-on-github
gnome-extensions enable Vitals@CoreCoding.com
gnome-extensions enable window-list@gnome-shell-extensions.gcampax.github.com
gnome-extensions enable sound-output-device-chooser@kgshank.net
gnome-extensions enable gnome-ui-tune@itstime.tech
gnome-extensions enable pamac-updates@manjaro.org
gnome-extensions enable taskicons@rliang.github.com

check_exit_status
}

function leave() {

	echo
	echo "---------------------------------------"
	echo "---- VictoryLinux has been installed! ----"
	echo "---------------------------------------"
	echo
	echo "This PC may need to be restarted"
	echo
	echo
	echo
	echo "Restarting in 15 Seconds"
	sleep 15s
	reboot
}

# Place a # in front of any part of this script yould like to skip:

greeting
#mirror
general_update
debloat
#cpu
gpu
packages
aur
flatpaks
wallpaper
grub
configs
appearance
extensions
leave