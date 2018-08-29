[BITS 16]
[ORG 7C00h]

%define FIRST_STAGE_SIZE 446
%define PARTITION_ENTRY_SIZE 16
%define PARTITION_BOOTABLE 80h

; Some BIOSes use 7C00:0000 not 0000:7C00 as entry
; It clears CS and jumps to entry point
jmp 0000h:start

start:
    mov si, before_read_msg
    call print_str

    ; Search bootable partition
    ; Address of partition entries
    xor cx, cx  ; cx = 0
    mov si, 7C00h+FIRST_STAGE_SIZE 
    search_bootable_loop:
    cmp [si], PARTITION_BOOTABLE
    je found_bootable

    cmp cx, 3               ; Checked all 4 partitions yet
    je not_found_bootable
    
    inc cx
    add si, PARTITION_ENTRY_SIZE
    jmp search_bootable_loop
    
    ; si is begin of partition entry
    ; si+0x8 is first sector of partition
    found_bootable:
    mov dap_disk_start_sector, dq[si+8]
    ; Load Second Stage Bootloader
    mov ah, 42h ; INT 13h AH=42h: Extended Read Sectors From Drive
    mov dl, 80h ; Drive index, first HDD
    mov si, bootloader_dap ; Segment:Offset (DS:SI) pointer to the DAP
    int 13h
    
    ; If there is error print error string
    jc print_disk_error_str
    
    ; If not jump to second stage
    jmp 500h
    
print_disk_error_str:
    mov si, disk_read_error_msg
    call print_str
    jmp $
    
; SI is data ptr
print_str:
    mov al, [si] ; Get char
    or al, al    ; Check char
    jz print_str_end ; If NULL jump to end
    
    mov ah, 0Eh ; Function number
    mov bh, 00h ; Page
    mov bl, 07h ; Color
    int 10h     ; Write char
    
    inc si        ; Move pointer and loop
    jmp print_str
    
    print_str_end:
    ret
        
disk_read_error_msg db "Err ld SSB", 0Ah, 0Dh, 00h
before_read_msg db "Ld SSB", 0Ah, 0Dh, 00h

bootloader_dap:
    dap_size db 10h ; Size of this struct 10h (16 bytes)
    dap_unused db 0 ; Unused attribute
    dap_sec_num dw 2 ; Number of sectors to be read
    dap_data_ptr dd 00000500h ; Segment:offset pointer (0000:0500)
    dap_disk_start_sector dq 0 ; Start from sector 1 (after MBR)

times FIRST_STAGE_SIZE - ($ - $$) db 0   ; Fill the rest of MBR code sector with 0