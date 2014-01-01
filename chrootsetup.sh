#!/bin/bash

# Mounting Files
printf "\e[01;32mMounting...\n\e[00m"
mount none -t proc /proc
mount none -t sysfs /sys
mount none -t devpts /dev/pts
export HOME=/root
export LC_ALL=C

rm /etc/apt/sources.list

cat > /etc/apt/sources.list << EOF
deb http://us.archive.ubuntu.com/ubuntu/ precise main restricted
deb-src http://us.archive.ubuntu.com/ubuntu/ precise main restricted

deb http://us.archive.ubuntu.com/ubuntu/ precise-updates main restricted
deb-src http://us.archive.ubuntu.com/ubuntu/ precise-updates main restricted

deb http://us.archive.ubuntu.com/ubuntu/ precise universe
deb-src http://us.archive.ubuntu.com/ubuntu/ precise universe
deb http://us.archive.ubuntu.com/ubuntu/ precise-updates universe
deb-src http://us.archive.ubuntu.com/ubuntu/ precise-updates universe


deb http://us.archive.ubuntu.com/ubuntu/ precise multiverse
deb-src http://us.archive.ubuntu.com/ubuntu/ precise multiverse
deb http://us.archive.ubuntu.com/ubuntu/ precise-updates multiverse
deb-src http://us.archive.ubuntu.com/ubuntu/ precise-updates multiverse


deb http://security.ubuntu.com/ubuntu precise-security main restricted
deb-src http://security.ubuntu.com/ubuntu precise-security main restricted
deb http://security.ubuntu.com/ubuntu precise-security universe
deb-src http://security.ubuntu.com/ubuntu precise-security universe
deb http://security.ubuntu.com/ubuntu precise-security multiverse
deb-src http://security.ubuntu.com/ubuntu precise-security multiverse

deb http://extras.ubuntu.com/ubuntu precise main
deb-src http://extras.ubuntu.com/ubuntu precise main
EOF


# Update Sources List
printf "\e[01;32mUpdating Current Programs...\n\e[00m"
apt-get update

# Upgrade Programs
printf "\e[01;32mUpgrading Current Packages...\n\e[00m"
apt-get upgrade --yes

# Installing Programs
printf "e[01;32mInstalling Chromium Browser\ne[00m"
apt-get install --yes chromium-browser preload bleachbit ufw apparmor apparmor-profiles psad wine
apt-get purge --yes ubuntuone-* firefox gnome-online-accounts gnome-user-guide ubuntu-docs

rm /var/lib/dbus/machine-id

rm /sbin/initctl

apt-get autoremove --yes
apt-get clean

rm -rf /tmp/*
rm -rf /root/*

rm /etc/hosts
rm -rf /tmp/* ~/.bash_history
rm /etc/resolv.conf
rm /var/lib/dbus/machine-id
rm /sbin/initctl
dpkg-divert --rename --remove /sbin/initctl

umount -lf /proc
umount -lf /sys
umount -lf /dev/pts
exit
