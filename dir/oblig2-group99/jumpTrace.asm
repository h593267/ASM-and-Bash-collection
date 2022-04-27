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