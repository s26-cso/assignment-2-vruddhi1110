.section .text
.globl make_node
.globl insert
.globl get
.globl getAtMost

.extern malloc

# struct Node {
#   int val;            // offset 0 (4 bytes)
#   struct Node* left;  // offset 8 (8 bytes)
#   struct Node* right; // offset 16 (8 bytes)
#   Total size: 24 bytes
# }

# struct Node* make_node(int val)
# input: a0 = val
# output: a0 = pointer to new node
make_node:
    # Prologue: allocate stack frame and save ra, s0
    addi sp, sp, -32
    sd ra, 24(sp)
    sd s0, 16(sp)
    mv s0, sp

    mv t0, a0          # t0 = val (save across malloc)
    li a0, 24          # size of struct Node
    call malloc        # malloc(size) -> returns ptr in a0

    # Initialize node fields
    # store 32-bit val at offset 0
    sw t0, 0(a0)
    # set left and right pointers to NULL
    sd x0, 8(a0)
    sd x0, 16(a0)

    # Epilogue: restore and return
    ld ra, 24(sp)
    ld s0, 16(sp)
    addi sp, sp, 32
    jr ra

# struct Node* insert(struct Node* root, int val)
# input: a0 = root, a1 = val
# output: a0 = root (possibly newly created node pointer)
insert:
    # Prologue: save ra and callee-saved registers s0,s1
    addi sp, sp, -48
    sd ra, 40(sp)
    sd s0, 32(sp)
    sd s1, 24(sp)
    mv s0, sp

    mv s1, a0          # s1 = root (save across recursive calls)

    beq a0, x0, insert_make_new  # if root == NULL

    lw t0, 0(a0)       # t0 = root->val
    beq a1, t0, insert_return_root
    blt a1, t0, insert_left

    # insert_right:
    # load root->right into a0 and call insert
    ld a0, 16(s1)      # a0 = root->right
    # a1 already has val
    call insert
    # a0 = returned node pointer (new right child)
    sd a0, 16(s1)      # root->right = returned node
    mv a0, s1          # return root
    j insert_epilogue

insert_left:
    # load root->left into a0 and call insert
    ld a0, 8(s1)       # a0 = root->left
    # a1 already has val
    call insert
    # a0 = returned node pointer (new left child)
    sd a0, 8(s1)       # root->left = returned node
    mv a0, s1
    j insert_epilogue

insert_return_root:
    mv a0, s1
    j insert_epilogue

insert_make_new:
    # create a new node with value = a1
    mv a0, a1          # move val into a0 for make_node
    call make_node     # returns new node ptr in a0
    j insert_epilogue  # return from function (a0 already set)

insert_epilogue:
    # Epilogue: restore registers and return
    ld ra, 40(sp)
    ld s0, 32(sp)
    ld s1, 24(sp)
    addi sp, sp, 48
    jr ra

# struct Node* get(struct Node* root, int val)
# input: a0 = root, a1 = val
# output: a0 = pointer to node or NULL
get:
    # Iterative implementation
get_loop:
    beq a0, x0, get_not_found
    lw t0, 0(a0)       # t0 = root->val
    beq a1, t0, get_found
    blt a1, t0, get_left
    # go right
    ld a0, 16(a0)
    j get_loop

get_left:
    ld a0, 8(a0)
    j get_loop

get_found:
    # a0 currently points to the found node
    ret

get_not_found:
    li a0, 0
    ret


# struct Node* getAtMost(struct Node* root, int val)
# Return pointer to node with largest value <= val, or NULL
# input: a0 = root, a1 = val
# output: a0 = pointer to node or NULL
getAtMost:
    # ans stored in t0 (initialize to NULL)
    li t0, 0
getAtMost_loop:
    beq a0, x0, getAtMost_done
    lw t1, 0(a0)       # t1 = node->val
    blt a1, t1, getAtMost_go_left  # if val < node->val -> go left
    # node->val <= val -> update ans, go right
    mv t0, a0          # ans = current node
    ld a0, 16(a0)      # go right
    j getAtMost_loop

getAtMost_go_left:
    ld a0, 8(a0)       # go left
    j getAtMost_loop

getAtMost_done:
beq t0, x0, return_minus1   # if ans == NULL
lw a0, 0(t0)                # load ans->val
    ret

return_minus1:
    li a0, -1
    ret
