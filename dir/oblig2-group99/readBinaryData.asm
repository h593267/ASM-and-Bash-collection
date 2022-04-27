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