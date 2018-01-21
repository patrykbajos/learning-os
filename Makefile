all: backup_hdd install_mbr install_second_stage

bin/first_stage.bin: src/boot/first_stage.asm
	nasm -f bin src/boot/first_stage.asm -o bin/first_stage.bin

install_mbr: bin/first_stage.bin
	dd if=bin/first_stage.bin bs=446 count=1 conv=notrunc of=hdd.raw

bin/second_stage.bin: src/boot/second_stage.asm
	nasm -f bin src/boot/second_stage.asm -o bin/second_stage.bin

install_second_stage: bin/second_stage.bin
	dd if=bin/second_stage.bin bs=512 count=2 conv=notrunc seek=1 of=hdd.raw

bin/pmode_bootloader.elf: src/boot/pmode_bootloader.c
	gcc -f elf -o pmode_bootloader.elf src/boot/pmode_bootloader.c

bin/kernel.elf: src/kernel/kernel.c
	gcc -f elf -o kernel.elf src/kernel/kernel.c

run:
	qemu-system-i386 -hda hdd.raw

run_debug:
	qemu-system-i386 -s -hda hdd.raw

run_gdb:
	gdb target remote localhost:1234

backup_hdd:
	cp hdd.raw .hdd.raw.bk

rollback_hdd:
	cp .hdd.raw.bk hdd.raw

clear:
	rm bin/*.bin