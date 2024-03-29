#!/bin/bash -e

##**************************************************************************
## Simple Update
##
## MIT License
##
## Copyright (C) Sergey Kovalenko <seryoga.engineering@gmail.com>
##
## Permission is hereby granted, free of charge, to any person obtaining a copy
## of this software and associated documentation files (the "Software"), to deal
## in the Software without restriction, including without limitation the rights
## to use, copy, modify, merge, publish, distribute, sub-license, and/or sell
## copies of the Software, and to permit persons to whom the Software is
## furnished to do so, subject to the following conditions:
##
## The above copyright notice and this permission notice shall be included in all
## copies or substantial portions of the Software.
##
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
## IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
## FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
## AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
## LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
## OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
## SOFTWARE.
##**************************************************************************

# Update Flatpak
if which flatpak >/dev/null 2>&1; then
    flatpak update --noninteractive
fi

# Update Snap
if which snap >/dev/null 2>&1; then
    sudo snap refresh
fi

# Ubuntu/Debian
if which apt >/dev/null 2>&1; then
   sudo apt update
   sudo apt dist-upgrade -y
   sudo apt autoremove --purge -y
   sudo apt clean
   exit
fi

# Arch Linux
if which pacman >/dev/null 2>&1; then
    if [[ -f /etc/pacman.d/mirrorlist ]]; then
        if grep -q archlinux /etc/pacman.d/mirrorlist; then
            # Update mirrorlist for clear Arch Linux
            curl -s "https://archlinux.org/mirrorlist/?country=US&protocol=https&use_mirror_status=on" \
                | sed -e 's/^#Server/Server/' -e '/^#/d' \
                | rankmirrors -n 5 - \
                | sudo tee /etc/pacman.d/mirrorlist
        elif grep -q manjaro /etc/pacman.d/mirrorlist; then
            # Update mirrorlist for Manjaro
            sudo pacman-mirrors --fasttrack 5
        fi
    fi

    if which yay >/dev/null 2>&1; then
        yay -Syyu --noconfirm --needed --removemake --editmenu=false --diffmenu=false --cleanmenu=false
        yay -Yc --noconfirm
    else
        sudo pacman -Syyu --noconfirm
    fi

    exit
fi

echo "Unsupported package manager"
exit 1
