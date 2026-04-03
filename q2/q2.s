.intel_syntax noprefix #Use Intel-style assembly syntax instead of the default (AT&T syntax)
.global main 
.extern printf
.extern atoi #atoi converts a null-terminated ASCII string into its equivalent integer representation.


.section .data 
fmt : .asciz "%d "
newline : .asciz "\n"

.section .txt

main:
push rbp 
mov rbp , rsp 

mov r12 , rdi #r12 = argc
mov r13 , rsi  #r13 = argv

#n = argc - 1
    mov r14, r12
    dec r14  #r14 = n

cmp r14 , 0
jle end_program

#Allocate memory on stack
# arr[n], result[n], stack[n]
#each int = 4 bytes ,  total = 12*n

mov rax , r14 
imul rax , r12  #performs signed multiplication, preserving the sign of the product
sub rsp , rax 

mov r15 , rsp #base pointer

mov rbx , r15 #arr base
#result base = r15 + 4*n

mov rcx , r14 
imul rcx , 4
lea  r8 , [r15 + rcx] # Load Effective Address , Unlike MOV, which accesses the data stored at a memory address, LEA only calculates the address itself and never reads from or writes to that memory location.

lea r9 , [r8+rcx] #stack base = r15 + 8*n
mov r10 , 0  #i = 0 

fill_arr:
cmp , r10 , r14 
jge fill_done  #Jump if Greater or Equal , basically checking whether arr[s[top]] <= arr[i] 
mov rdi, [r13 + 8*(r10+1)]  #we access argv[i+1]
call atoi #atoi converts string to int , bcz we need int since we are comparing 

mov [rbx + 4*r10 ] , eax 
inc r10 #i++
jmp fill_arr

mov r10 , 0 

init_result:
cmp r10,r14 
jge init_done

mov dword ptr [r8 + 4*r10] , -1 #intilizing result arr with -1
inc r10 
jmp init_result 

init_done: 
mov r11 , -1 # stack top = -1 
mov r10 , r14 
dec r10 

main_loop:
cmp r10 , -1 #Stack empty case for right most ele of arr 
je process_done

while_loop:
cmp r11 , -1
je while_end

#stack top 
mov eax , [r9 + 4*r11] 
mov edx , eax 

#arr[stack[top]]
mov eax , [rbx+4*rdx] 
#arr[i]
mov ecx , [rbx+4*r10] 

cmp eax , ecx 
jg while_end 

dec r11 
jmp while_loop

while_end:
cmp r11 , -1
je no_greater 

#result[i] = stack[top]
mov eax , [r9+4*r11] 
mov [r8 + 4*r10], eax
jmp after_assign 

no_greater:
mov dword ptr [r8 + 4*r10], -1 #Double Word refers to a 32-bit

after_assign:
#push i 
inc r11 
mov [r9 + 4*r11], r10d
dec r10
jmp main_loop

process_done:
mov r10 , 0 
#print result 
print_loop:
cmp r10,r14 
jge print_done 
mov rdi, offset fmt mov esi, [r8 + 4*r10]
mov eax, 0
call printf
inc r10
jmp print_loop

print_done:
    mov rdi, offset newline
   mov  eax, 0
    call printf

end_program:
    mov rsp, rbp
    pop rbp
    ret







