

; input and output procedures for Source.asm

INCLUDE Irvine32.inc
INCLUDE io.inc

.code


;/****************************************************
Introduction   PROC           ;(checked)
;*
;* Display 2 Messages that are passed by refference
;* Note: pushed strings are deleted after execution
;*
;* Receives: 
;*   ptrPrompt1          ; offset of prompt string
;*   ptrPrompt2          ; offset of prompt string
;* Returns: nothing 
;* Preconditions: nothing 
;* Register changed: nothing
;*****************************************************/

ptrPrompt1     EQU  [ebp + 12]                         ; First message
ptrPrompt2     EQU  [ebp + 8]                          ; Second message

     ENTER     0,0                                     ; push ebp and mov ebp, esp

     push      edx

     mov  edx, ptrPrompt1
     call WriteString                                  ; First display message
     call Crlf
     call Crlf

     mov  edx, ptrPrompt2
     call WriteString                                  ; Second display message
     call Crlf
     call Crlf

     pop  edx
     leave                                             ; mov esp,ebp and pop ebp

     ret  8
Introduction   ENDP


;/****************************************************
Get_data  PROC                ;(checked)
;*
;* Get a user request in the range[16, 256] -- [min, max]
;* 
;* Receives: 
;*        ptrPrompt1          ; input message
;*        ptrPrompt2          ; valid message
;*        ptrPrompt3          ; error message
;*        low_bound           ; lower bound
;*        up_bound            ; upper bound
;*        input               ; pointer to request
;* Returns:  nothing
;* Preconditions: nothing 
;* Register changed: nothing
;*****************************************************/   
ptrPrompt1     EQU  [ebp + 28]
ptrPrompt2     EQU  [ebp + 24]
ptrPrompt3     EQU  [ebp + 20]
low_bound      EQU  [ebp + 16]
up_bound       EQU  [ebp + 12]
input          EQU  [ebp + 8]

     ENTER 0,0                                    ; push ebp, mov ebp, esp
     push eax
     push edx
     push esi

     ;loop for user input 
L1: 
     mov  edx, ptrPrompt1
     call WriteString
     call ReadDec

     cmp  eax, low_bound                          
     jb   L2                                      ; if(input < low_bound)
     cmp  eax, up_bound
     ja   L2                                      ; if(input > up_bound)
     jmp  L3
     
     ;Display error message and jmp L1
L2:
     mov  edx, ptrPrompt3                         ; display message for invalid input
     call WriteString
     call Crlf
     jmp L1
     
     ;if input is valid, store value into request
L3:
     mov  edx, ptrPrompt2                         ; display message for valid input
     call WriteString                           
     call Crlf
     call Crlf

     mov  esi, input
     mov  [esi], eax

     pop  esi
     pop  edx
     pop  eax

     leave
     ret  24                                      ; delete all pushed values
Get_data  ENDP




;/****************************************************
Display_median PROC
;*
;* Calculate and display the median value, rounded to the nearest integer
;*
;* Receives: 
;*        ptrPrompt1          ; display message
;*        arraySize           ; number of random num   
;*        ptrArray            ; pointer to array 
;* Returns: nothing
;* Register changed: nothing 
;*****************************************************/ 
ptrPrompt1     EQU  [ebp + 16]
arraySize      EQU  [ebp + 12]
ptrArray       EQU  [ebp + 8]

     ENTER 0,0
     push esi
     push eax
     push ebx
     push edx
     
     mov  edx, ptrPrompt1
     call WriteString

     mov  esi, ptrArray    
     mov  eax, arraySize
     mov  ebx, 2
     cdq
     div  ebx

     cmp  edx, 0                                       ; if(arrSize%2 == 0)
     je   L2

     ; Odd elements

L1:
     mov  ebx, eax
     dec  ebx
     imul ebx, 4
     mov  eax, [esi + ebx]                             ; middle one 
     jmp  L3

     ; even elements
L2:
     mov  ebx, eax
     dec  ebx
     imul ebx, 4
     mov  eax, [esi + ebx]                             ; middle one
     add  ebx, 4
     add  eax, [esi + ebx]                             ; next one


     mov  ebx, 2
     cdq
     div  ebx

     ; round up if (edx * 10 >= 2 * 5)  
     imul edx, 10
     imul ebx, 5

     cmp  edx, ebx
     jb   L3                                      ; if (edx * 10 < 2 * 5), jmp L3
     
     inc  eax                                     ; else increase eax 
     ; display and exit
L3:
     call WriteDec
     mov  eax, 0
     mov  al,  46                             ; DOT
     call WriteChar
     call Crlf

     pop  edx
     pop  ebx
     pop  eax
     pop  esi

     LEAVE
     ret  12

Display_median ENDP


;/****************************************************
Display_average     PROC
;*
;* Calculate and display the average value, rounded to the nearest integer
;* 
;* Receives: 
;*        ptrPrompt1          ; display message
;*        arraySize           ; number of random num   
;*        ptrArray            ; pointer to array 
;* Returns: nothing
;* Register changed: nothing
;*****************************************************/ 
ptrPrompt1     EQU  [ebp + 16]
arraySize      EQU  [ebp + 12]
ptrArray       EQU  [ebp + 8]

     ENTER 0,0
     push esi
     push eax
     push ebx
     push ecx
     push edx

     mov  eax, 0
     mov  ecx, arraySize
     mov  esi, ptrArray
     
     mov  edx, ptrPrompt1                    ; display message 
     call WriteString

     ; loop to calculate sum of array elements
L1:
     add  eax, [esi]
     add  esi, 4
     loop L1

     ; calculate average

     mov  ebx, arraySize
     cdq
     div  ebx
     
     ; round up if (edx * 10 >= arraySize * 5)  
     imul edx, 10
     imul ebx, 5

     cmp  edx, ebx
     jb   L2                                      ; if (edx * 10 < arraySize * 5), jmp L2
     
     inc  eax                                     ; else increase eax 

L2:
     call WriteDec
     mov  eax, 0
     mov  al,  46                             ; DOT
     call WriteChar
     
     call Crlf
     call Crlf
     call Crlf

     pop  edx
     pop  ecx
     pop  ebx
     pop  eax
     pop  esi

     LEAVE
     ret  12

Display_average     ENDP


;/****************************************************
Display_list   PROC           ;(checked)
;* 
;* Display the list of integers before sorting, 5 numbers per line.
;* Receives: 
;*   ptrPrompt1          ; message
;*   arraySize           ; number of random num   
;*   ptrArray            ; pointer to array 
;* Returns: nothing
;* Register changed: nothing
;*****************************************************/
ptrPrompt1     EQU  [ebp + 16]
arraySize      EQU  [ebp + 12]
ptrArray       EQU  [ebp + 8]

     ENTER 0,0
     push eax
     push ebx
     push ecx
     push esi
     push edx


     mov  edx, ptrPrompt1                    ; display message
     call WriteString
     call Crlf
     mov  ebx, 0                             ; count number of display
     mov  ecx, arraySize                     ; set ecx for a loop
     mov  esi, ptrArray                     

     ; loop for display array elements
L1:
     mov  eax, [esi]
     call WriteDec

     
     inc  ebx                                ; count up
     cmp  ebx, 5                             ; when count is 5, next row
     jb   L2                                 ; if(count < 5) jump to L2
     call Crlf                               ; else next row
     mov  ebx, 0
     jmp  L3
L2:
     mov  al,  9                             ; TAB
     call WriteChar

L3:
     add  esi, 4                             ; move to next element
     loop L1
     
     call Crlf
     call Crlf
     call Crlf

     pop  edx
     pop  esi
     pop  ecx
     pop  ebx
     pop  eax
     LEAVE
     
     ret  12
Display_list   ENDP

END