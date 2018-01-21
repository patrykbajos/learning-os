[BITS 16]
[ORG 500h]
; Second Stage is placed in first two 512b sectors of EXT2 volume
; After Second Stage is placed EXT2 1024b Superblock 

%define SECOND_STAGE_SIZE 1024
%define STACK_SIZE 64

entry:
    mov si, after_load_msg
    call print_str

    ; Set SP to the last element
    mov ax, stack
    add ax, STACK_SIZE-1
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
    resb 64 

; Output size is 1024b (2 sectors)
times SECOND_STAGE_SIZE - ($ - $$) db 0