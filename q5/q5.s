section.data
       filename db "input.txt"  , 0 
       yes_msg db "Yes" ,10
       yes_len equ $ - yes_msg 
       no_msg db "No", 10
       no_len equ $ - no_msg

section.bss
c1 resb 1
c2 resb 1

section.txt
global_start

_start:
#open("input.txt", O_RDONLY)
mov rax , 2
mov rdi, filename
    mov rsi, 0         # O_RDONLY
    mov rdx, 0
    syscall
    mov r12, rax

    fd

   # lseek(fd, 0, SEEK_END)
    mov rax, 8         # sys_lseek
    mov rdi, r12
    mov rsi, 0
    mov rdx, 2         # SEEK_END
    syscall
    mov r13, rax       # size

    mov r14, 0         # left = 0
    mov r15, r13
    dec r15            # right = size - 1

loop_start:
    cmp r14, r15
    jge is_palindrome

   # --- read left char ---
    mov rax, 8         # lseek
    mov rdi, r12
    mov rsi, r14
    mov rdx, 0         # SEEK_SET
    syscall

    mov rax, 0         # read
    mov rdi, r12
    mov rsi, c1
    mov rdx, 1
    syscall

   # --- read right char ---
    mov rax, 8
    mov rdi, r12
    mov rsi, r15
    mov rdx, 0
    syscall

    mov rax, 0
    mov rdi, r12
    mov rsi, c2
    mov rdx, 1
    syscall

   # compare
    mov al, [c1]
    mov bl, [c2]not_palindrome:
    mov rax, 1
    mov rdi, 1
    mov rsi, no_msg
    mov rdx, no_len
    syscall

exit:
    mov rax, 60         ; exit
    xor rdi, rdi
    syscall
    cmp al, bl
    jne not_palindrome

    inc r14
    dec r15
    jmp loop_start

is_palindrome:
    mov rax, 1         # write
    mov rdi, 1         # stdout
    mov rsi, yes_msg
    mov rdx, yes_len
    syscall
    jmp exit