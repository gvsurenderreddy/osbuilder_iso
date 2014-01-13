#!/bin/bash

# Make Sure All Local Programs Are Installed
printf "\e[01;32m\nChecking and Installing Dependencies...\n\n\e[00m"
sudo apt-get install --yes debootstrap syslinux squashfs-tools genisoimage lzma >/dev/null

reset

# Questions About OS
printf "\e[01;33mOperating System Name: \e[00m"
read os_name
printf "\e[01;33m$os_name Build Version: \e[00m"
read os_build_version
printf "\e[01;33mProcessor Type: (i386, amd64): \e[00m"
read -i "amd64" -e os_processor_type
printf "\e[01;33mUbuntu Base OS (oneiric, precise): \e[00m"
read -i "precise" -e os_ubuntu_version

# Create Working Directory
printf "\e[01;32m\nBuilding Filesystem Directories...\n\e[00m"
mkdir -p ~/os/$os_name/$os_processor_type/$os_build_version/

ISO=$1

cp $ISO ~/os/$os_name/$os_processor_type/$os_build_version/
cd ~/os/$os_name/$os_processor_type/$os_build_version/

printf "\e[01;32m\nMounting ISO...\n\e[00m"
mkdir mnt
sudo mount -o loop *.iso mnt

printf "\e[01;32m\nExtracting ISO...\n\e[00m"
mkdir extract-cd
sudo rsync --exclude=/casper/filesystem.squashfs -a mnt/ extract-cd

printf "\e[01;32m\nExtracting Filesystem...\n\e[00m"
sudo unsquashfs mnt/casper/filesystem.squashfs
sudo mv squashfs-root filesystem

printf "\e[01;32m\nCopying Nessessory Files to Filesystem...\n\e[00m"
sudo cp /etc/resolv.conf filesystem/etc/
sudo cp /etc/hosts filesystem/etc/
sudo cp ~/osbuilder/chrootsetup.sh filesystem/tmp/chrootsetup
sudo chmod 777 filesystem/tmp/chrootsetup

sudo mount --bind /dev/ filesystem/dev

sudo chroot filesystem "/tmp/chrootsetup"

sudo umount filesystem/dev

chmod +w extract-cd/casper/filesystem.manifest
sudo chroot filesystem dpkg-query -W --showformat='${Package} ${Version}\n' > extract-cd/casper/filesystem.manifest
sudo cp extract-cd/casper/filesystem.manifest extract-cd/casper/filesystem.manifest-desktop
sudo sed -i '/ubiquity/d' extract-cd/casper/filesystem.manifest-desktop
sudo sed -i '/casper/d' extract-cd/casper/filesystem.manifest-desktop

sudo rm extract-cd/casper/filesystem.squashfs
sudo mksquashfs filesystem extract-cd/casper/filesystem.squashfs

printf $(sudo du -sx --block-size=1 filesystem | cut -f1) > extract-cd/casper/filesystem.size

cat > extract-cd/README.diskdefines << EOF
#define DISKNAME  $os_name
#define TYPE  binary
#define TYPEbinary  1
#define ARCH  $os_processor_type
#define ARCH$os_processor_type  1
#define DISKNUM  1
#define DISKNUM1  1
#define TOTALNUM  0
#define TOTALNUM0  1
EOF

cd extract-cd
sudo rm md5sum.txt
find -type f -print0 | sudo xargs -0 md5sum | grep -v isolinux/boot.cat | sudo tee md5sum.txt

sudo mkisofs -D -r -V "$os_name" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o ../$os_name-$os_build_version-$os_processor_type.iso .

cp ../$os_name-$os_build_version-$os_processor_type.iso /var/www/
