.intel_syntax noprefix
.global _start

.section .data
filename: .asciz "input.txt"
yes_msg: .asciz "Yes\n"
yes_len = . - yes_msg
no_msg: .asciz "No\n"
no_len = . - no_msg

.section .bss
c1: .space 1
c2: .space 1

.section .text
_start:
    # open("input.txt", O_RDONLY)
    mov rax, 2         # sys_open
    lea rdi, [filename]
    mov rsi, 0         # O_RDONLY
    mov rdx, 0
    syscall
    mov r12, rax       # fd

    # lseek(fd, 0, SEEK_END)
    mov rax, 8         # sys_lseek
    mov rdi, r12
    mov rsi, 0
    mov rdx, 2         # SEEK_END
    syscall
    mov r13, rax       # size

    # Strip trailing newline if it exists
    cmp r13, 0
    jle is_palindrome

    # check last character
    mov rax, 8         # lseek
    mov rdi, r12
    mov rsi, r13
    dec rsi
    mov rdx, 0         # SEEK_SET
    syscall

    mov rax, 0         # read
    mov rdi, r12
    lea rsi, [c1]
    mov rdx, 1
    syscall

    mov al, BYTE PTR [c1]
    cmp al, 10         # newline
    jne set_indices
    dec r13            # ignore newline in size

set_indices:
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
    lea rsi, [c1]
    mov rdx, 1
    syscall

    # --- read right char ---
    mov rax, 8         # lseek
    mov rdi, r12
    mov rsi, r15
    mov rdx, 0         # SEEK_SET
    syscall

    mov rax, 0         # read
    mov rdi, r12
    lea rsi, [c2]
    mov rdx, 1
    syscall

    # compare
    mov al, BYTE PTR [c1]
    mov bl, BYTE PTR [c2]
    cmp al, bl
    jne not_palindrome

    inc r14
    dec r15
    jmp loop_start

not_palindrome:
    mov rax, 1         # write
    mov rdi, 1
    lea rsi, [no_msg]
    mov rdx, no_len
    syscall
    jmp exit

is_palindrome:
    mov rax, 1         # write
    mov rdi, 1         # stdout
    lea rsi, [yes_msg]
    mov rdx, yes_len
    syscall

exit:
    # close fd
    mov rax, 3         # sys_close
    mov rdi, r12
    syscall

    mov rax, 60        # exit
    xor rdi, rdi
    syscall
