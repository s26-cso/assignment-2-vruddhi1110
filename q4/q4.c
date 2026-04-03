#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<dlfcn.h>

int main() {
    char op[6] ;  //operation name
    int a ; //first operand
    int b ; //second operand    

    while(1) {
        if(scanf("%5s %d %d", op, &a, &b) != 3){
            break; // Exit the loop if input is not in the expected format
        }

        char libname[20] ; 
        snprintf(libname , sizeof(libname) , "lib%s.so", op) ; // Construct the library name based on the operation
        void *handle = dlopen(libname , RTLD_LAZY) ; // Load the shared
        if(!handle) {
            fprintf(stderr , "Error: Could not open %s\n", libname) ;
            continue; // Skip to the next iteration if the library cannot be loaded
        }
        dlerror() ; // Clear any existing errors

        int (*func)(int , int) ; 
        *(void **)(&func) = dlsym(handle, op);

        char *error = dlerror() ;
        if(error != NULL){
            fprintf(stderr, "Error: Could not find function %s\n", op);
            dlclose(handle);
            continue;
        }

        int result = func(a, b) ; // Call the function with the provided operands
        printf("%d\n", result) ; // Print the result
        dlclose(handle) ; // Close the library handle
    }

    return 0;
}