[BITS 16]
[ORG 500h]
; We have apx. 30 KB (30 464 byts) from 0x500 to 0x7BFF
; but we will use only 24 KiB (24 * 1024 bytes)

jmp start

start:
    mov si, after_load_msg
    call print_str

    mov ax, stack ; Set stack pointer
    add ax, 4095  ; Index 4095 is 4096th element
    mov sp, ax
   
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

after_load_msg db "Loaded second stage...", 0Ah, 0Dh, 00h
data db 0, 0Ah, 0Dh, 0

stack:
    resb 4096 

; Output size is 24 KiB (48 sectors)
times 24576 - ($ - $$) db 0