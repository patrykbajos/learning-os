int main()
{
	__asm__("\
    mov ax, stack ; Set stack pointer\
    add ax, 4095  ; Index 4095 is 4096th element\
    mov sp, ax");
	
	return 0;
}

char after_load_msg[] = "Loaded second stage...\r\n";

char stack[4096];