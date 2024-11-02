#!/bin/bash

echo "ja_JP.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen

reflector --save /etc/pacman.d/mirrorlist --country Japan --protocol https --latest 5
