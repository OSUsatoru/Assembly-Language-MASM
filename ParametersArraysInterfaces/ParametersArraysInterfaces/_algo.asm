

; core algorithm procedures for Source.asm

INCLUDE Irvine32.inc
INCLUDE core_alg.inc

.code

;/****************************************************
Fill_array     PROC            ;(checked)
;*
;* Generate request random integers in the range [64, 1024] -- [lo, hi],
;* storing them in consecutive elements of an array
;* 
;* Receives:
;*        low_bound           ; lower bound
;*        up_bound            ; upper bound
;*        arraySize           ; number of random num   
;*        ptrArray            ; pointer to array 
;* Returns: 
;* Register changed:
;*****************************************************/ 
low_bound      EQU  [ebp + 20]
up_bound       EQU  [ebp + 16]
arraySize      EQU  [ebp + 12]
ptrArray       EQU  [ebp + 8]


     ENTER 0,0
     push eax
     push ecx
     push esi
     
     call Randomize                               ; init random generator
     mov  esi, ptrArray
     mov  ecx, arraySize                          ; set ecx for a loop


     ; loop until arraySize
L1:
     ;*************************
     ; Generate random number
     ; range = hi - lo + 1
     ; mov eax, range
     ; call RandomRange
     ; add eax, lo
     ;****************************
     mov  eax, up_bound
     sub  eax, low_bound
     inc  eax
     call RandomRange
     add  eax, low_bound

     ; store generated random number into array
     mov  [esi], eax
     add  esi, 4
     loop L1

     pop  esi
     pop  ecx
     pop  eax
     leave
     ret  16

Fill_array     ENDP


;/****************************************************
Sort_list PROC           ;(checked)
;* The idea of this Procedure is from textbook (Assemble Language For x86 PROCESSORS 7th)
;* Sort the list in descending order by using Bubble sort
;*
;* Receives: 
;*        arraySize           ; number of random num   
;*        ptrArray            ; pointer to array 
;* Returns: nothing
;* Register changed: nothing
;*****************************************************/ 
arraySize      EQU  [ebp + 12]
ptrArray       EQU  [ebp + 8]


comment!
**********Pseudocode**********************
i = n - 1
for( i > 0)
     j = i
     for( j > 0)
          k = 0
          if(arr[k] < arr[k+1])
               swap(arr[k], arr[k+1])
          ++k
          --j
     --i
************************************************!
     ENTER 0,0

     push esi
     push eax
     push ecx

     mov  ecx, arraySize
     dec  ecx                                ; i = n - 1

     ; outer loop
L1:
     push ecx                                ; save outer loop counter
     mov  esi, ptrArray                      ; point to first element. [esi] = arr[k]
     
     ; inner loop
L2:
     mov  eax, [esi]
     cmp  eax, [esi+4]                       ; compare arr[k], arr[k+1]
     jae  L3                                 ; if (arr[k] => arr[k+1]), no exchange
     
     xchg eax, [esi+4]                       ; else exchange: temp = esi, (esi+4 = temp, temp = esi+4)
     mov  [esi], eax                         ; esi = esi+4, 

L3:
     add  esi, 4                             ; ++k
     loop L2                                 ; --j

     pop  ecx                                
     loop L1                                 ; --i and loop

     pop  ecx
     pop  eax
     pop  esi

     LEAVE
     ret  8

Sort_list ENDP

END