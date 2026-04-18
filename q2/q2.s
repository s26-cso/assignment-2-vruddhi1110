.section .rodata
fmt: .asciz "%d "
newline: .asciz "\n"

.section .text
.globl main
.extern printf
.extern atoi

# main(argc, argv): read integers from argv[1..argc-1], compute from

main:
    # a0 = argc, a1 = argv

    # Compute n = argc - 1
    addi s0, a0, -1     # s0 = n
    blez s0, end_program # if n <= 0, end

    # Compute bytes_needed = 12 * n (arr + result + stack, each 4*n)
    slli t0, s0, 2      # t0 = 4*n
    li t1, 3
    mul t2, t0, t1      # t2 = 12 * n  (3 * 4*n)

    # Align bytes_needed up to multiple of 16: (t2 + 15) & ~15
    addi t3, t2, 15
    li t4, -16
    and t3, t3, t4      # t3 = aligned size

    # Reserve saved area (ra + s0-s4) = 48 bytes (multiple of 16)
    li t5, 48

    # total_alloc = t3 + t5
    add t6, t3, t5

    # Allocate stack frame: sp = sp - total_alloc
    sub sp, sp, t6

    # t7 = new sp; arrays base = sp
    mv s1, sp           # s1 = arr base (sp)

    # result_base = sp + 4*n
    add s2, s1, t0      # s2 = result base

    # stack_base = result_base + 4*n = sp + 8*n
    add s3, s2, t0      # s3 = stack base

    # saved_area_ptr = sp + t3  (point where saved registers will be stored)
    add s5, s1, t3      # s5 = saved area pointer

    # Save callee-saved registers and ra into saved area
    sd ra, 0(s5)
    sd s0, 8(s5)
    sd s1, 16(s5)
    sd s2, 24(s5)
    sd s3, 32(s5)

    # Now fill arr from argv
    li t0, 0            # i = 0
fill_arr:
    bge t0, s0, fill_done

    # Compute address of argv[i+1]  -> offset = 8*(i+1)
    slli t1, t0, 3      # t1 = 8*i
    addi t1, t1, 8      # t1 = 8*(i+1)
    add t1, a1, t1      # t1 = &argv[i+1]
    ld a0, 0(t1)        # a0 = argv[i+1] (pointer to string)
    call atoi           # atoi(a0) -> returns int in a0

    # store into arr[i] (arr base in s1)
    slli t2, t0, 2      # t2 = 4*i
    add t2, s1, t2      # t2 = &arr[i]
    sw a0, 0(t2)

    addi t0, t0, 1
    j fill_arr

fill_done:
    # initialized result[i] = -1 for i in [0..n-1]
    li t0, 0
    li t1, -1
init_result:
    bge t0, s0, init_done
    slli t2, t0, 2
    add t2, s2, t2      # t2 = &result[i]
    sw t1, 0(t2)
    addi t0, t0, 1
    j init_result

init_done:
    # stack_top = -1 (use s4 to hold top index)
    li s4, -1

    # i = n - 1
    addi t0, s0, -1     # t0 = i

main_loop:
    blt t0, zero, process_done

    # while stack not empty and arr[stack[top]] <= arr[i]: pop
while_loop:
    li t1, -1
    beq s4, t1, while_end

    # load index = stack[top]
    slli t2, s4, 2
    add t2, s3, t2      # t2 = &stack[top]
    lw t3, 0(t2)        # t3 = stack[top]

    # arr[stack[top]]
    slli t4, t3, 2
    add t4, s1, t4
    lw t5, 0(t4)

    # arr[i]
    slli t6, t0, 2
    add t6, s1, t6
    lw t2, 0(t6)

    # if arr[stack[top]] > arr[i] -> break
    blt t2, t5, while_end

    # else pop: stack_top--
    addi s4, s4, -1
    j while_loop

while_end:
    li t1, -1
    beq s4, t1, no_greater

    # result[i] = stack[top]
    slli t2, s4, 2
    add t2, s3, t2
    lw t3, 0(t2)
    slli t4, t0, 2
    add t4, s2, t4
    sw t3, 0(t4)
    j after_assign

no_greater:
    slli t4, t0, 2
    add t4, s2, t4
    sw t1, 0(t4)

after_assign:
    # push i onto stack
    addi s4, s4, 1
    slli t2, s4, 2
    add t2, s3, t2
    sw t0, 0(t2)

    addi t0, t0, -1
    j main_loop

process_done:
    # print results: for i = 0..n-1 printf("%d ", result[i])
    li t0, 0
print_loop:
    bge t0, s0, print_done

    slli t1, t0, 2
    add t1, s2, t1
    lw a1, 0(t1)        # a1 = result[i]
    la a0, fmt
    call printf

    addi t0, t0, 1
    j print_loop

print_done:
    la a0, newline
    call printf

end_program:
    # Restore saved callee-saved registers and ra
    ld ra, 0(s5)
    ld s0, 8(s5)
    ld s1, 16(s5)
    ld s2, 24(s5)
    ld s3, 32(s5)

    # Restore sp to original (sp = sp + total_alloc)
    add sp, sp, t6

    # return 0
    li a0, 0
    ret
