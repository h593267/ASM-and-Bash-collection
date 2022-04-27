; M A T R I X  M U L T I P L I C A T I O N
; ========================================
; Perform multiplication on the global matrices A and B, storing the result in C.
matmul:
   ; Start of subtask 3  

   ; Thoroughly tested and correct according to the java program, we tried to do an as true to
   ; the original "method" according to the 3 loops in main in MatMulASCII.java. All tested matrix
   ; combinations were the same as the java program e.g (A1.mat B1.mat | ./toBinary | ./MatMulBinary -> b)

   ; Whe chose to not push any of the matrix addresses, n, m or l to the stack, due to
   ; the matmul function being ivoked without any parameters/arguments, in contrast
   ; to the jumptrace routine that uses the stack for every variable. Here we just refer directly
   ; to the section .data l, n and m and section .bss matrixA, matrixB and matrixC.
   ; This subtask was extremely hard to debug and test, but after a while it all started working.

   ; loop variables
   push dword 0      ;  #3   i   
   push dword 0      ;  #2   j
   push dword 0      ;  #1   k

   ; accumulator
   push dword 0      ;  #0  acc

loop1:

   mov eax, 0
   mov w32FrStck(2), eax   ; j = 0, reset inner loop

loop2:
   mov eax, 0
   mov w32FrStck(0), eax   ; acc = 0
   mov eax, 0
   mov w32FrStck(1), eax   ; k = 0, reset innermost loop
   
loop3:
   
   readoutMatrix ecx, matrixA, n, w32FrStck(3), w32FrStck(1)   ; A[i][k] -> ecx                                                          
   readoutMatrix edx, matrixB, m, w32FrStck(1), w32FrStck(2)   ; B[k][j] -> edx  
   mov eax, ecx                  
   mul edx                 ; A[i][k] * B[k][j] -> eax

   mov ebx, w32FrStck(0)   ; acc -> ebx
   add ebx, eax            ; acc += A[i][k] * B[k][j]
   mov w32FrStck(0), ebx   ; acc back to stack

   mov eax, w32FrStck(1)
   inc eax                 
   mov w32FrStck(1), eax   ; k++
   cmp eax, n   
   jl loop3                ; k < n loop

   ; end of loop3

   mov ecx, w32FrStck(0)   ; acc -> ecx (critical section, this didnt work for any other registers than ecx)
   writeToMatrix ecx, matrixC, m, w32FrStck(3), w32FrStck(2) ; C[i][j] = acc;  

   mov eax, w32FrStck(2)
   inc eax 
   mov w32FrStck(2), eax   ; j++
   cmp eax, m  
   jl loop2                ; j < m loop

   ; end of loop2

   mov eax, w32FrStck(3)
   inc eax 
   mov w32FrStck(3), eax   ; i++
   cmp eax, l              
   jl loop1                ; j < l

   ; end of loop1
      
   pop edx                 ; pop 4 values pushed to stack        
   pop edx              
   pop edx                
   pop edx 
              
   ; End of subtask 3                                 
   ret
