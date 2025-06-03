# Makefile za ZeroOS sa asm kernelom

all: disk.img

boot.bin: boot.asm
	nasm -f bin boot.asm -o boot.bin

kernel.bin: kernel.asm
	nasm -f bin kernel.asm -o kernel.bin

disk.img: boot.bin kernel.bin
	dd if=/dev/zero of=disk.img bs=512 count=2880
	dd if=boot.bin of=disk.img conv=notrunc
	dd if=kernel.bin of=disk.img seek=1 conv=notrunc

run: disk.img
	qemu-system-i386 -fda disk.img

clean:
	rm -f *.bin *.o disk.img

.PHONY: all clean run
