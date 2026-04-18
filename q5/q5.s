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
.globl _start
_start:
    # open("input.txt", O_RDONLY)
    # Use openat(dirfd=AT_FDCWD, pathname, flags=0, mode=0)
    li a0, -100        # AT_FDCWD
    la a1, filename
    li a2, 0           # O_RDONLY
    li a3, 0
    li a7, 56          # sys_openat
    ecall
    mv s0, a0          # fd

    # lseek(fd, 0, SEEK_END)
    mv a0, s0
    li a1, 0
    li a2, 2           # SEEK_END
    li a7, 62          # sys_lseek
    ecall
    mv s1, a0          # size

    # Strip trailing newline if it exists
    # if size <= 0 jump
    blez s1, is_palindrome

    # check last character
    addi t0, s1, -1    # offset = size - 1
    mv a0, s0
    mv a1, t0
    li a2, 0           # SEEK_SET
    li a7, 62          # lseek
    ecall

    li a0, 63          # read
    mv a0, s0
    la a1, c1
    li a2, 1
    li a7, 63          # sys_read
    ecall

    la t5, c1
    lb t1, 0(t5)
    li t2, 10          # newline
    bne t1, t2, set_indices
    addi s1, s1, -1    # ignore newline in size

set_indices:
    li s2, 0           # left = 0
    mv s3, s1
    addi s3, s3, -1    # right = size - 1

loop_start:
    bge s2, s3, is_palindrome

    # --- read left char ---
    mv a0, s0
    mv a1, s2
    li a2, 0           # SEEK_SET
    li a7, 62          # lseek
    ecall

    mv a0, s0
    la a1, c1
    li a2, 1
    li a7, 63          # read
    ecall

    # --- read right char ---
    mv a0, s0
    mv a1, s3
    li a2, 0           # SEEK_SET
    li a7, 62          # lseek
    ecall

    mv a0, s0
    la a1, c2
    li a2, 1
    li a7, 63          # read
    ecall

    # compare
    la t5, c1
    lb t3, 0(t5)
    la t6, c2
    lb t4, 0(t6)
    bne t3, t4, not_palindrome

    addi s2, s2, 1
    addi s3, s3, -1
    j loop_start

not_palindrome:
    li a0, 1
    la a1, no_msg
    li a2, no_len
    li a7, 64          # write
    ecall
    j exit

is_palindrome:
    li a0, 1           # stdout
    la a1, yes_msg
    li a2, yes_len
    li a7, 64          # write
    ecall

exit:
    # close fd
    mv a0, s0
    li a7, 57          # sys_close
    ecall

    li a0, 0
    li a7, 93          # exit
    ecall
