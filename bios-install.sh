echo "Installing Arch Linux."
sleep 12
clear
echo "Choosing the wrong disk may cause data loss"
lsblk
echo "/dev/xxx"
read DISK
if [[ $DISK =~ "nvme" ]]; then
  export ROOTPULSE=${DISK}p2
  export BOOTPULSE=${DISK}p1
else
  export ROOTPULSE=${DISK}2
  export BOOTPULSE=${DISK}1
fi
clear
echo "What do you want your username to be?"
read USER
clear
if [ -z "$ROOTPULSE" ]; then
  echo "You have not set your ROOTPULSE!"
else
  if [ -z "$BOOTPULSE" ]; then
    echo "You have not set your BOOTPULSE!"
  else        
    if [ -z "$USER" ]; then
      echo "You have not set your USERNAME! (password will be set later)"
    else
      echo "Are you sure you want to install Arch Linux to $ROOTPULSE? This is irreversible! (Type Y and press enter to confirm, press enter to cancel)"
      read CONFIRM
      if [ "$CONFIRM" == "Y" ]; then
        clear
        echo "DOS/GPT Removal"
        dd if=/dev/zero of=$DISK bs=512M status=progress count=1
        (
          echo o # Create a new DOS disklabel
          echo n # Add a new partition
          echo p # Primary partition
          echo 1 # Partition number
          echo   # First sector (default)
          echo +512M # Last sector (creates a 512M partition)
          echo t # Change partition type
          echo c # Set type to W95 FAT32 (LBA)
          echo n # Add a new partition
          echo p # Primary partition
          echo 2 # Partition number
          echo   # First sector (default)
          echo   # Last sector (default)
          echo w # Write changes
        ) | sudo fdisk $DISK
        clear
        echo "Making filesystems!"
        mkfs.ext4 $ROOTPULSE
        mkfs.fat -F32 $BOOTPULSE
        echo "Done!"
        clear
        echo "Mounting filesystems!"
        mount $ROOTPULSE /mnt
        mkdir /mnt/boot
        mount $BOOTPULSE /mnt/boot
        echo "Done!"
        clear
        echo "Installing base system!"
        pacstrap -K /mnt linux linux-firmware base base-devel
        echo "Making user!"
        arch-chroot /mnt useradd $USER
        clear
        echo "Please set a password for the user!"
        arch-chroot /mnt passwd $USER
        mkdir /mnt/home/$USER
        arch-chroot /mnt chown -R $USER:$USER /home/$USER
        arch-chroot /mnt usermod -a -G wheel $USER
        wget https://raw.githubusercontent.com/trurune/totoro-linux/master/sudoers
        cat sudoers > /mnt/etc/sudoers
        echo "Done!"
        clear
        echo "Installing LXQt desktop environment, terminal, web browser, and basic tools!"
        arch-chroot /mnt pacman -S lxqt sddm lxterminal firefox vim git --noconfirm
        echo "Done!"
        echo "Installing GRUB for BIOS!"
        arch-chroot /mnt pacman -S grub --noconfirm
        arch-chroot /mnt grub-install --target=i386-pc $DISK
        arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
        echo "Done!"
        clear
        echo "Generating fstab"
        genfstab /mnt >> /mnt/etc/fstab
        echo "Done!"
        clear
        echo "Enabling daemons!"
        arch-chroot /mnt systemctl enable sddm
        clear
        echo "Generating locales"
        echo "Please uncomment the line where your locale is (e.g en_US.UTF-8 UTF-8)"
        nano /mnt/etc/locale.gen
        arch-chroot /mnt locale-gen
        echo "Done!"
        clear
        echo "Setting time zone"
        echo "What is your continent?"
        ls /usr/share/zoneinfo
        read CONTINENT
        echo "What is your timezone in that continent (often capital city)"
        ls /usr/share/zoneinfo/$CONTINENT
        read ZONE
        arch-chroot /mnt ln -sf /usr/share/zoneinfo/$CONTINENT/$ZONE /etc/localtime
        echo "Done!"
        arch-chroot /mnt systemctl enable NetworkManager
        echo "archlinux" > /mnt/etc/hostname
        echo "Done!"
        clear
        echo "Installation completed! Rebooting in 5 seconds!"
        sleep 5
        reboot
      else
        echo "Cancelled!"
      fi
    fi
  fi
fi