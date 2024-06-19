clear
echo "Installing ArchPulse "Eclipse" 06.2024"
lsblk
echo "What is your root partition (/dev/sdx-)?"
read ROOTARCHPULSE
echo "What is your boot partition (/dev/sdx-)?"
read BOOTARCHPULSE
echo "What do you want your username to be?"
read USER
echo "Please pick an ArchPulse Version (gnome, suckless, xfce)"
read VER
if [ -z VER ]
then
echo "You have not set your VER!"

else
if [ -z "$ROOTARCHPULSE" ]
then
	echo "You have not set your root partition (/)!"

else
if [ -z "$BOOTARCHPULSE" ]
then
	echo "You have not set your boot partition (/boot/efi)!"

else	
	if [ -z "$USER" ]
 	then
  	echo "You have not set your username! (passwd will be run later)"
   	else
  	echo "Are you sure you want to install ArchPulse to $ROOTARCHPULSE? This is irreversible! (Type "I KNOW WHAT I AM DOING!" and press enter to confirm, press enter to cancel)"
   	read CONFIRM
   	if [ $CONFIRM == "I KNOW WHAT I AM DOING!" ]
    then
	echo "Making Filesystems!"
	mkfs.ext4 $ROOTARCHPULSE
 	mkfs.fat -F32 $BOOTARCHPULSE
  	echo "Done!"
  	echo "Mounting Filesystems!"
  	mount $ROOTARCHPULSE /mnt
   	mount $BOOTARCHPULSE /mnt/boot --mkdir
    	echo "Done!"
     	echo "Running pacstrap!"
    	pacstrap -K /mnt linux linux-firmware base base-devel
     	echo "Creating users!"
 	arch-chroot /mnt useradd $USER
  	echo "Enter your password:"
  	arch-chroot /mnt passwd $USER
   	mkdir /mnt/home/$USER
	arch-chroot /mnt chown -R $USER:$USER /home/$USER
 	arch-chroot /mnt usermod -a -G wheel gato
  	wget https://raw.githubusercontent.com/trurune/totoro-linux/master/sudoers
   	cat sudoers > /mnt/etc/sudoers
   	echo "Done!"
     	echo "Installing extra packages!"
      	if [ $VER == "gnome" ]
	then
     	wget https://raw.githubusercontent.com/trurune/totoro-linux/master/gnome-packages.txt
      	mv gnome-packages.txt /mnt/packages.txt
      	wget https://raw.githubusercontent.com/trurune/totoro-linux/master/issue
       	mv issue /mnt/etc/issue
	wget https://raw.githubusercontent.com/trurune/totoro-linux/master/os-release
 	mv os-release /mnt/etc/os-release
      	arch-chroot /mnt pacman -S - < /mnt/packages.txt
       	echo "Done!"
	fi
 	if [ $VER == "suckless" ]
  	then
   	
 	echo "exec dwm" >> /mnt/home/$USER/.xinitrc
   	wget https://raw.githubusercontent.com/trurune/totoro-linux/master/suckless-packages.txt
    	mv suckless-packages.txt /mnt/packages.txt
      	wget https://raw.githubusercontent.com/trurune/totoro-linux/master/issue
       	mv issue /mnt/etc/issue
	wget https://raw.githubusercontent.com/trurune/totoro-linux/master/os-release
 	mv os-release /mnt/etc/os-release
      	arch-chroot /mnt pacman -S - < /mnt/packages.txt
       	echo "Installing the dwm version requires some packages to be compiled."
	arch-chroot /mnt git clone https://git.suckless.org/dwm
 	wget https://raw.githubusercontent.com/trurune/totoro-linux/master/config.h
  	mv config.h /mnt/dwm/config.h
 	arch-chroot /mnt make -C dwm
  	arch-chroot /mnt sudo make install -C dwm
	rm -rf dwm
	arch-chroot /mnt git clone https://git.suckless.org/st
 	arch-chroot /mnt make -C st
  	arch-chroot /mnt sudo make install -C st
   	rm -rf st
    	arch-chroot /mnt git clone https://git.suckless.org/dmenu
 	arch-chroot /mnt make -C dmenu
  	arch-chroot /mnt sudo make install -C dmenu
   	rm -rf dmenu
 echo "Done!"
	fi
 	if [ $VER == "xfce" ]
	then
     	wget https://raw.githubusercontent.com/trurune/totoro-linux/master/xfce-packages.txt
      	mv xfce-packages.txt /mnt/packages.txt
      	wget https://raw.githubusercontent.com/trurune/totoro-linux/master/issue
       	mv issue /mnt/etc/issue
	wget https://raw.githubusercontent.com/trurune/totoro-linux/master/os-release
 	mv os-release /mnt/etc/os-release
      	arch-chroot /mnt pacman -S - < /mnt/packages.txt
       	echo "Done!"
	fi
 	echo "Installing systemd-boot!"
     	arch-chroot /mnt bootctl install
      	echo "Done!"
      
       	echo "Generating fstab"
	genfstab /mnt > /mnt/etc/fstab
	echo "Configuring systemd-boot!"
 	echo "title ArchPulse "Eclipse"" >> /mnt/boot/loader/entries/arch.conf
  	echo "linux /vmlinuz-linux" >> /mnt/boot/loader/entries/arch.conf
   	echo "initrd /initramfs-linux.img" >> /mnt/boot/loader/entries/arch.conf
    	echo "options root=$ROOTARCHPULSE rw" >> /mnt/boot/loader/entries/arch.conf
     	echo "" > /mnt/boot/loader/loader.conf
      	echo "timeout 15" >> /mnt/boot/loader/loader.conf
   	echo "default arch.conf" >> /mnt/boot/loader/loader.conf
    	echo "Done!"
     	echo "Bootloader check!"
      	arch-chroot /mnt bootctl list
       	echo "Done!"
     	echo "Enabling daemons!"
      	if [ $VER == "gnome" ]
        then
      	arch-chroot /mnt systemctl enable gdm
       	fi
	if [ $VER == "xfce" ]
 	then
  	arch-chroot /mnt systemctl enable sddm
   	fi
 	arch-chroot /mnt systemctl enable NetworkManager
  	echo "archpulse" > /mnt/etc/hostname
  	echo "Done!"
   	echo "Installation Completed, You Can Reboot Now!"
    	if [ $VER == "suckless" ]
     	then
      	echo "On the suckless version there is no display manager preinstalled so please just run startx instead"
       	fi
    	else
     	echo "Cancelled!"
      	fi

fi
fi
fi
fi
