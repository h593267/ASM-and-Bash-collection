;  ======================================================
;     A  S  S  E  M  B  L  Y    T  E  M  P  L  A  T  E
;  ======================================================
;
;  This is the program you are supposed to complete and make equivalent to
;  the existing Java program.





;  H E L P E R  M A C R O S
;  ========================
;
;  These macros illustrate how assembly uses the stack for passing values around,
;  in particular passing arguments to "functions".
;  Note that the macros are expanded before the actual assembler begins, you
;  could as well do that manuall.

; Reference the 32-bit value that has been `push`ed nth-most recently.
%define w32FrStck(n) [esp + 4 * (n)]

; Invoke a function with two arguments passed via the stack.
%macro call2 3
  push dword %3  ; second argument
  push dword %2  ; first argument
  call %1
  add esp, 2*4   ; clean up stack
%endmacro

; Read the two arguments in a function call.
%macro funargs2 2
  mov %1, w32FrStck(1)
  mov %2, w32FrStck(2)
%endmacro

; Read the three arguments in a function call.
%macro funargs3 3
  mov %1, w32FrStck(1)
  mov %2, w32FrStck(2)
  mov %3, w32FrStck(3)
%endmacro

; Invoke a function with one 32-bit value returned,
; and three arguments passed via the stack.
%macro call3_1 5
  push dword 0   ; result
  push dword %5  ; third argument
  push dword %4  ; second argument
  push dword %3  ; first argument
  call %2
  add esp, 3*4   ; clean up arguments from stack
  pop %1         ; retrieve result
%endmacro

; Read the three arguments in a function call.
%macro funret3_1 1
  mov w32FrStck(4), %1
  ret
%endmacro

section .data
   l equ 300
   n equ 50
   m equ 500
   STDIN equ 0
   STDOUT equ 1
   SYS_READ equ 3
   SYS_WRITE equ 4
   LINE_SHIFT equ 10

section .bss
   inNumber resb 4
   matrixA resb 4*l*n
   matrixB resb 4*n*m
   matrixC resb 4*l*m
   digest resb 4

%macro setupMatrixIndexing 4
   mov eax, %3      ; y
   mov ebx, %2      ; w
   mul ebx          ; eax <- y*w   {ebx*eax}
   mov ebx, %4      ; x
   add eax, ebx     ; eax <- y*w + x  {linear index into matrix}
   mov ebx, 4
   mul ebx          ; 32-bit
   mov ebx, %1      ; m
   add ebx, eax     ; ebx <- &m + 4*(y*w + x)  {absolute address of matrix element}
%endmacro

%macro readoutMatrix 5
   setupMatrixIndexing %2, %3, %4, %5
   mov %1, [ebx] ; m[y][x]
%endmacro

%macro writeToMatrix 5
   setupMatrixIndexing %2, %3, %4, %5
   mov [ebx], %1 ; m[y][x]
%endmacro




;  M A I N  E N T R Y  P O I N T
;  =============================
section .text
global _start
_start:

   ; Read matrices from stdin
   call2 readBinaryData, matrixA, 4*l*n
   call2 readBinaryData, matrixB, 4*n*m

   call matmul

   call3_1 eax, jumpTrace, matrixC, l, m

   ;readoutMatrix eax, matrixA, n, 40, 29
   mov edx,0  ; div requires initial high half zero
   mov ebx,26
   div ebx    ; edx <- eax%ebx
   push edx

   ; Print a number as characterId-in-alphabet
   mov edx, 'a'
   pop ecx
   add edx, ecx

   mov eax,SYS_WRITE
   mov ebx,STDOUT
   mov ecx,digest
   mov [ecx], edx
   add ecx, 1
   mov [ecx], byte LINE_SHIFT
   mov ecx,digest
   mov edx,2
   int 80h

   mov ebx,0
   mov eax,1       ;; sys_exit
   int 80h

; D A T A  I N P U T
; ==================
; void readBinaryData(tgtAddress, nBytes)
readBinaryData:

; SUBTASK 2 START
   mov eax,SYS_READ        ; Moving the value 3 into eax register (ID)  meaning a read data system call  

   mov ebx,STDIN           ; Moving the value 0 into ebx register, exit status is 0, standard input       

   mov ecx, w32FrStck(1)   ; Moving the content of the top of the stack (the allocated memory space for the current Matrix) into ecx
                           ; This is to specify where we want to read the bytes.

   mov edx, 8*4            ; Specifying the length of bytes (32 aka 8 * 32-bit integers) we want to read from standard input.           

   int 80h                 ; performing the system call (system read)            

   mov eax, 8*4            ; Moving the value 32 into eax register, in order to temporarily store value in a register for future operations.
   
   mov ecx, w32FrStck(1)   ; Repeating line 152. This is redundant, but probably for clarification purposes.           
   
   add ecx, eax            ; Adding the value 32 into ecx-register containing the address value, this is to proceed to the next 8 slots in our dedicated memory.           
   
   mov w32FrStck(1), ecx   ; Moving the updated address value back into the stack.          
   
   mov edx, w32FrStck(2)   ; Moving the next content from the stack (a number representing the remaining bytes to read)            
   
   sub edx, eax            ; Subtracting 32 from remaining integers left to be read, as 8 more numbers have been read.            
   
   mov w32FrStck(2), edx   ; Moving the updated number of integers left to be read into the stack slot.            
   
   cmp edx, 0              ; Comparing edx value to the number 0.             
   
   jg readBinaryData       ; If edx value is greater than 0, we run readBinaryData over again, because we have more content in matrix to read.  
   
   ret                     ; Returns when edx is 0, then size is 0 and the routine is finished. If the remaining number of integers left to read is 0, we're done.

   ; Question 1:
   ; The routine will run for any matrix size, however: 
   ; The routine works with the A- and B matrices we are using because we have declared 
   ; specific sizes for our matrices in the data section. Using these specific constant declarations,
   ; the routine would not work as desired with matrices of unsimilar sizes.
   ; For example, a larger matrix would start overwriting the dedicated space of the other matrix, and vice versa.
   ; The desired result would thus not be achieved.

   ; Question 2:
   ; To make it work with matrices of any size, we'd have to define the specified "variables" l, n, m depending on the 
   ; given matrices. This could be done through giving the values through standard input.
   ; Drawbacks:
   ; The asm-file would have to be rewritten. The user would also have to know the specific matrix dimensions.
; SUBTASK 1 END

; P S E U D O  H A S H  F U N C T I O N
; =====================================
; char jumpTrace(matrixAddr, height, width)
jumpTrace:
   funargs3 edx, ecx, ebx ; m, h, w
   push edx               ; m             ; #7
   mov eax, ebx           ; eax <- w
   mul ecx                ; eax <- w*h  {eax*ecx} {iterations}
   push eax               ; matrix size   ; #6
   push ebx               ; w             ; #5
   push ecx               ; h             ; #4
   push dword 0           ; x             ; #3
   push dword 0           ; y             ; #2
   push dword 1           ; acc           ; #1
   push eax               ; iterations    ; #0

jTLoop:
   readoutMatrix eax, w32FrStck(7), w32FrStck(5), w32FrStck(2), w32FrStck(3)
                    ;     m       ,     w       ,     y       ,     x
   mov ecx, w32FrStck(1)  ; acc
   mul ecx                ; eax <- acc*m[y][x]
   inc eax                
   mov ebx, w32FrStck(6)  ; w*h
   mov edx, 0             
   div ebx                ; edx <- (acc*m[y][x] + 1) % (w*h)
   mov w32FrStck(1), edx  ; acc
   mov ebx, w32FrStck(4)  ; h
   mov eax, edx           ; acc
   mov edx, 0             
   div ebx                ; edx <- acc % h
   mov w32FrStck(2), edx  ; y <- acc%h
   readoutMatrix eax, w32FrStck(7), w32FrStck(5), w32FrStck(2), w32FrStck(3)
                          ; m     ,     w       ,     y       ,     x
   
   ; Start of subtask 2
   ; the following 6 lines are an assembly conversion of line 50 in MatMulASCII,java (x = (acc*m[y][x]) % w;)

   mov ecx, w32FrStck(1)    ; Move the acc to the ecx register
   mul ecx                  ; Multiply it by m[y][x] contained in the eax register. readoutMatrix eax, w32FrStck(7), w32FrStck(5), w32FrStck(2), w32FrStck(3)
                            ; gives eax the value of m[y][x] for us 
   mov ebx, w32FrStck(5)    ; Move w into the ebx register
   mov edx, 0               ; Put 0 in the edx register (for rest division/modulo purposes) ; this line might(?) be redundant
   div ebx                  ; divide eax (which now contains acc*m[y][x]) by ebx register (% w), rest goes to the edx register
   mov w32FrStck(3), edx    ; x = rest after acc*m[y][x] % w
   
   ; End of subtask 2

   mov ecx, w32FrStck(0)  ; iterations
   dec ecx                ; --iterations
   mov w32FrStck(0), ecx  ; iterations
   cmp ecx, 0             ; iterations > 0 
   jg jTLoop

   pop edx                ; iterations  ; #0
   pop eax                ; acc         ; #1
   pop edx                ; y           ; #2
   pop edx                ; x           ; #3
   pop edx                ; h           ; #4
   pop edx                ; w           ; #5
   pop edx                ; matrix size ; #6
   pop edx                ; m           ; #7

   funret3_1 eax

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

