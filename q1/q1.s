. intel_syntax noprefix  #Use Intel-style assembly syntax instead of the default (AT&T syntax)
. global make_node
.global insert
.global get
.global getAtMost


.extern malloc # we will get malloc lib when we will compile with gcc , not included in this file

    # struct Node   {
    #   int val (offset 0) 
    #   Node*left (offset 8)
    #   Node*right (offset 16)
    #  total size = 24 bytes 
    #   }

    # make_node(int val) 
    # input : rdi = val
    # output : rax = pointer to new node


make_node :
push rdi #saving value in the stack bcz mallloc will overwrite register

mov rdi , 24 #size of struct node
call mallloc # calling malloc(24) , rax = allocated memory

pop rdi #restore val

#Store val (int = 4 bytes)
mov [rax] , edi #node->val = val , we use edi insted of rdi bcz , edi =  lower 32 bits of rdi Used when dealing with int (4 bytes)
                                    # Prevents memory corruption

#node->left = null
mov qword ptr [rx+8] , 0  # quad word = 8 bytes  , so  full meaning is "Memory at address (rax + 8), treat it as 8 bytes"in c Compiler already knows:
                            #left is a pointer =  8 bytes , but in assembly we need to specify . 

#node->right = null
mov qword ptr [rx+16] , 0

ret #Return pointer in rax

    #insert(struct node*root , int val) 
    # input: rdi = root , rsi = val
    # optput : rax = root
insert:
 #case:1  if root is null create new node
    #equvivalent c code
    #if (root == NULL)
    #  return make_node(val);
        cmp rdi , 0
        je insert_make_new # je = jump if equal
        #If (rdi == 0), jump to insert_make_new

mov eax , [rdi] #Load root->val , eax = 10
cmp rsi , rax #Compare val with root->val ,  7 - 10

jl insert_left #if val < root->val
jr insert_right #if val > root->val

 #case-2:- Left side 
 insert_left:

 push rdi #saving root bcz we need it during recursion , back tracking
 mov rdi , [rdi+8] #Node*temp = root->left , rsi alraedy has val
 call insert #it will return rax which is a   new left child 
 pop rdi #restoring orginal root

 mov [rdi+8] , rax #root->left = returned node
 mov rax,rdi  

 ret
 #right case :
 insert_right :
 push rdi #saving root bcz we need it during recursion , back tracking
 mov rdi ,[rdi+16] #Node*temp = root->right , rsi alraedy has val
 call insert #it will return rax which is a   new right child 
pop rdi #restoring orginal root

mov [rdi+16] , rax ##root->right = returned node
mov rax , rdi  #return pointer = root , basically return the root of the bst 

#create new node
insert_make_new:
#calling make_node(val)
mov rdi , rsi #this function needs only one argument val. Its input must be in rdi so Pass val as argument to make_node.
call make_node #Calls the function make_node
ret # returns  new node

#get(struct*Node root , int val):
#input : rdi = root , rsi = val 
#output : rax = pointer to node or null if that node does  not exits 

get:
#If root == NULL , return null
cmp rdi , 0 
je get_not_found

#Loading root->val 

mov eax , [rdi] 

cmp rsi , rax
je get_found  
#if smaller go to left side
jl get_left

#if bigger go to left side
jg get_right 

get_left :
mov rdi , [rdi + 8]
call get
ret

get_right:
mov rdi , [rdi+16] 
call get
ret

get_found:
mov rax , rdi
ret

get_not_found:
mov rax , 0 
ret

#Get At Most(int val , struct*Node root)
input: rdi = val , rsi = root
output: rax = result or -1

get_at_most:
#rdi = val , rsi = root
mov rax , -1 #default ans -1

get_at_most_loop:
#while(root != Null) 
cmp rsi , 0 
je get_at_most_done

#Loading root->val
mov edx , [rsi]

#if root->val = val 
cmp edx , edi 
jle update_answere

#otherwise go left 
mov rsi , [rsi+8]
jmp get_at_most_loop

update_answere:
#update_answere = root->val
mov eax , edx


#go right to fine larger vals
mov rsi , [rsi+16]
jmp get_at_most_loop

get_at_most_done:
ret















