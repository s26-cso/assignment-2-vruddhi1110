.intel_syntax noprefix
.global main 
.extern printf
.extern atoi

.section .rodata 
fmt: .asciz "%d "
newline: .asciz "\n"

.section .text

main:
    push rbp 
    mov rbp, rsp 

    # Save command-line arguments (argc, argv) in callee-saved registers
    push r12
    push r13
    push r14
    push r15
    push rbx

    mov r12, rdi      # r12 = argc
    mov r13, rsi      # r13 = argv

    # n = argc - 1
    mov r14, r12
    dec r14           # r14 = n

    cmp r14, 0
    jle end_program

    # Allocate memory on stack
    # arr[n], result[n], stack[n]
    # each int = 4 bytes, total = 12 * n
    mov rax, r14 
    imul rax, 12      # Total size in bytes (12 * n)
    # Align stack to 16 bytes
    add rax, 15
    and rax, -16
    sub rsp, rax 

    mov r15, rsp      # Base pointer for our arrays

    mov rbx, r15      # arr base

    mov rcx, r14 
    imul rcx, 4
    lea r8, [r15 + rcx]       # result base = r15 + 4*n
    lea r9, [r8 + rcx]        # stack base = result_base + 4*n (which is r15 + 8*n)

    xor r10, r10      # i = 0 

fill_arr:
    cmp r10, r14 
    jge fill_done 

    # We access argv[i+1] => r13 + 8*(r10+1)
    # Since atoi uses C ABI, it can clobber rcx, r8, r9, r10, r11.
    # So we MUST save r8, r9, r10 across the atoi/printf calls!
    push r10
    push r8
    push r9
    push r10          # Push again for 16-byte stack alignment
    
    mov rdi, QWORD PTR [r13 + 8*r10 + 8]
    call atoi
    
    pop r10
    pop r9
    pop r8
    pop r10

    mov DWORD PTR [rbx + 4*r10], eax 
    inc r10
    jmp fill_arr

fill_done:
    xor r10, r10      # i = 0

init_result:
    cmp r10, r14 
    jge init_done

    mov DWORD PTR [r8 + 4*r10], -1  # result[i] = -1
    inc r10 
    jmp init_result 

init_done: 
    mov r11, -1       # r11 = stack top index (-1 means empty)
    mov r10, r14 
    dec r10           # r10 = n - 1 (loop from right to left)

main_loop:
    cmp r10, -1 
    je process_done

while_loop:
    cmp r11, -1       # while stack is not empty
    je while_end

    # stack[top]
    movsxd rdx, DWORD PTR [r9 + 4*r11] 
    
    # arr[stack[top]]
    mov eax, DWORD PTR [rbx + 4*rdx] 
    
    # arr[i]
    mov ecx, DWORD PTR [rbx + 4*r10] 

    cmp eax, ecx 
    jg while_end      # if arr[stack[top]] > arr[i], break while

    dec r11           # stack.pop()
    jmp while_loop

while_end:
    cmp r11, -1
    je no_greater 

    # result[i] = stack[top]
    mov eax, DWORD PTR [r9 + 4*r11] 
    mov DWORD PTR [r8 + 4*r10], eax
    jmp after_assign 

no_greater:
    mov DWORD PTR [r8 + 4*r10], -1

after_assign:
    # stack.push(i)
    inc r11 
    mov DWORD PTR [r9 + 4*r11], r10d

    dec r10
    jmp main_loop

process_done:
    xor r10, r10      # i = 0 

print_loop:
    cmp r10, r14 
    jge print_done 

    push r10
    push r8
    push r9
    push r10          # Padding for stack alignment

    # printf("%d ", result[i])
    lea rdi, [fmt]
    mov esi, DWORD PTR [r8 + 4*r10]
    xor eax, eax
    call printf

    pop r10
    pop r9
    pop r8
    pop r10

    inc r10
    jmp print_loop

print_done:
    lea rdi, [newline]
    xor eax, eax
    call printf

end_program:
    # Stack restore
    lea rsp, [rbp - 40]
    
    # Restore callee-saved registers
    pop rbx
    pop r15
    pop r14
    pop r13
    pop r12

    mov rsp, rbp
    pop rbp
    # return 0
    xor eax, eax
    ret
