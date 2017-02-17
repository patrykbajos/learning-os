all: install_mbr install_second_stage

bin/mbr.bin: src/boot/mbr.asm
	nasm -f bin src/boot/mbr.asm -o bin/mbr.bin

install_mbr: bin/mbr.bin
	dd if=bin/mbr.bin bs=446 count=1 conv=notrunc of=hdd.raw

bin/second_stage.bin: src/boot/second_stage.asm
	nasm -f bin src/boot/second_stage.asm -o bin/second_stage.bin

install_second_stage: bin/second_stage.bin
	dd if=bin/second_stage.bin bs=512 count=48 conv=notrunc seek=1 of=hdd.raw

run:
	qemu-system-i386 -hda hdd.raw

run_debug:
	qemu-system-i386 -s -hda hdd.raw

run_gdb:
	gdb target remote localhost:1234

backup_hdd:
	cp hdd.raw .hdd.raw.old

clear:
	rm bin/*.bin