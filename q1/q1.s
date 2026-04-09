.intel_syntax noprefix
.global make_node
.global insert
.global get
.global getAtMost

.extern malloc

# struct Node {
#   int val;            // offset 0 (4 bytes)
#   struct Node* left;  // offset 8 (8 bytes)
#   struct Node* right; // offset 16 (8 bytes)
#   Total size: 24 bytes
# }

# struct Node* make_node(int val)
# input: edi = val
# output: rax = pointer to new node
make_node:
    push rdi             # save val + align stack to 16 bytes (since call pushed 8 bytes)
    mov rdi, 24          # size of struct Node
    call malloc          # allocate memory
    pop rdi              # restore val
    
    mov DWORD PTR [rax], edi       # node->val = val
    mov QWORD PTR [rax+8], 0       # node->left = NULL
    mov QWORD PTR [rax+16], 0      # node->right = NULL
    ret

# struct Node* insert(struct Node* root, int val)
# input: rdi = root, esi = val
# output: rax = root
insert:
    cmp rdi, 0           # if root is NULL
    je insert_make_new

    mov eax, DWORD PTR [rdi]  # load root->val
    cmp esi, eax              # compare val with root->val
    jl insert_left            # if val < root->val
    jg insert_right           # if val > root->val

    # If equal, just return root
    mov rax, rdi
    ret

insert_left:
    push rdi                  # save root
    mov rdi, QWORD PTR [rdi+8] # rdi = root->left
    # esi already has val
    call insert               # insert(root->left, val)
    pop rdi                   # restore root
    mov QWORD PTR [rdi+8], rax # root->left = returned node
    mov rax, rdi              # return root
    ret

insert_right:
    push rdi                  # save root
    mov rdi, QWORD PTR [rdi+16] # rdi = root->right
    # esi already has val
    call insert               # insert(root->right, val)
    pop rdi                   # restore root
    mov QWORD PTR [rdi+16], rax # root->right = returned node
    mov rax, rdi              # return root
    ret

insert_make_new:
    mov rdi, rsi              # pass val to make_node
    # We must align the stack before calling make_node, just in case!
    # However, replacing 'call make_node' with a standard jump works
    # identically and saves stack manipulation.
    jmp make_node             # jump to make_node directly

# struct Node* get(struct Node* root, int val)
# input: rdi = root, esi = val
# output: rax = pointer to node or NULL
get:
    cmp rdi, 0                # if root == NULL
    je get_not_found

    mov eax, DWORD PTR [rdi]  # load root->val
    cmp esi, eax
    je get_found              # if val == root->val
    jl get_left               # if val < root->val
    jg get_right              # if val > root->val

get_left:
    mov rdi, QWORD PTR [rdi+8] # root = root->left
    jmp get

get_right:
    mov rdi, QWORD PTR [rdi+16] # root = root->right
    jmp get

get_found:
    mov rax, rdi
    ret

get_not_found:
    mov rax, 0
    ret

# int getAtMost(int val, struct Node* root)
# input: edi = val, rsi = root
# output: eax = result or -1
getAtMost:
    mov eax, -1               # default answer = -1
get_at_most_loop:
    cmp rsi, 0                # while(root != NULL)
    je get_at_most_done

    mov edx, DWORD PTR [rsi]  # load root->val
    cmp edi, edx              # cmp val, root->val
    jge update_answer         # if val >= root->val, go right

    # go left
    mov rsi, QWORD PTR [rsi+8]
    jmp get_at_most_loop

update_answer:
    mov eax, edx              # update answer = root->val
    # go right to find larger valid values
    mov rsi, QWORD PTR [rsi+16]
    jmp get_at_most_loop

get_at_most_done:
    ret
