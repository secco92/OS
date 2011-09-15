#!/bin/sh

# This script assembles the MikeOS bootloader, kernel and programs
# with NASM, and then creates floppy and CD images (on Linux)

# Only the root user can mount the floppy disk image as a virtual
# drive (loopback mounting), in order to copy across the files

# (If you need to blank the floppy image: 'mkdosfs disk_images/mikeos.flp')


#if [ ! -e disk_images/mikeos.flp ]
#then
#	echo ">>> Creating new MikeOS floppy image..."
#	mkdosfs -C disk_images/mikeos.flp 1440 || exit
#fi


echo ">>> Assembling bootloader..."

nasm -f bin -o bootload.bin bootload.asm || exit


echo ">>> Assembling MikeOS kernel..."

nasm -f bin -o kernel.bin kernel.asm || exit

echo ">>> Adding bootloader to floppy image..."
cat bootload.bin > os.img
dd status=noxfer conv=notrunc if=os.img of=/dev/fd0 || exit

sleep 0.2

echo '>>> Done!'

