[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/d5nOy1eX)



### Overview of Solutions:

- **q1/**: Contains `q1.s` which implements the required Binary Search Tree operations (insert, get, getAtMost) in RISC-V assembly. 

- **q2/**: Contains `q2.s`. This solves the "next greater element" problem in an array in O(n) time and O(n) space by simulating a stack in assembly.

- **q3/**: 
  - **Part A:** `payload.txt` contains the correct password found via reverse engineering the binary (`strings` check into the `.rodata` section).
  - **Part B:** The `payload` binary file exploits a buffer overflow vulnerabilty. 

- **q4/**: Contains `q4.c`. It's a calculator app that dynamically loads user-provided `.so` shared libraries using `<dlfcn.h>` (`dlopen`/`dlsym`) so it fits within the strict 2GB memory footprint constraint.

- **q5/**: Contains `q5.s`, which reads a file in an arbitrarily long stream and checks if the string is a palindrome in O(n) time and O(1) space utilizing two pointers (one at the beginning and one at the end of the file).

### How to test
All codes have been tested successfully on the required architecture. You can compile the `.c` files and assemble the `.s` files the standard way (e.g. `gcc`). The payload for q3a uses standard input (`< payload.txt`) and q3b uses the binary payload (`< payload`).
