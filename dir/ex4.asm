global _start

section .text
_start:
    mov ebx, 1      ; start ebx at 1
    mov ecx, 4      ; number of iterations
label:
    add ebx, ebx    ; ebx += ebx
    dec ecx         ; ecx -= 1
    cmp ecx, 0      ; compare ecx to 0
    jg label        ; jump to label if 0
    mov eax, 1      ; sys:_exit call
    int 0x80
