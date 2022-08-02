COMMENT&
Author: Satoru Yamamoto
Final Edit Data : 11 / 21 / 2020

Requirements:
1) User’s numeric input must be validated the hard way: Read the user's input as a string and convert
the string to numeric form. If the user enters non-digits or the number is too large for 32-bit
registers, an error message should be displayed, and the number should be discarded.
2) Conversion routines must appropriately use the lodsb and/or stosb operators.
3) All procedure parameters must be passed on the system stack.
4) Addresses of prompts, identifying strings, and other memory locations should be passed by
address to the macros.
5) Used registers must be saved and restored by the called procedures and macros.
6) The stack must be “cleaned up” by the called procedure.
7) The usual requirements regarding documentation, readability, user-friendliness, etc., apply.


Optional Clallenges: 
/************************************************************************************************
1) Number each line of user input and display a running subtotal of the user’s numbers.
2) Handle signed integers.
3) Make your ReadVal and WriteVal procedures recursive.
4) Implement procedures ReadVal and WriteVal for floating point values, using the FPU.
************************************************************************************************/
------------------------------------------------------------------------------------------------------&

.386; Identify this as 32 - bit program
.model flat, stdcall; Selects the program's memory model(flat)
.stack 4096; how many bytes of memory to reserve

; Assembly Language for x86 Processors Seventh Editon KIP R.IRVINE
; Chapter 3.2 p.63 - p.65

INCLUDE Irvine32.inc


;/****************************************************************
mGetStirng MACRO         bufferPtr, maxChars
;*
;*   Read from standart input into a buffer
;*   do no pass EDX into maxChars
;*   *EAX holds the count of input characters*
;*   In this program, no need to return count of input characters
;*   Idea from: Macro2.asm
;******************************************************************/
     push eax
     push ecx
     push edx

     mov  edx, bufferPtr           ;; point to the buffer
     mov  ecx, maxChars            ;; specify max characters
     call ReadString

     pop  edx
     pop  ecx
     pop  eax

ENDM


;/****************
mDisplayString MACRO     buffer
;*
;*  Display received buffer
;*  Idea from: Macro2.asm
;*************************/

     push edx
     mov  edx, buffer
     call WriteString
     pop edx

ENDM

;/**********************
;* Constant numbers
;***********************/
.const


INPUTNUM = 8                            ; number of input strings
CHAR = 15                               ; number of input characters

.data

array     DWORD INPUTNUM DUP(?)         ; store input values
buffer    BYTE CHAR DUP(0)              ; input buffer

average   DWORD ?
sum       DWORD ?

row_cnt   DWORD 1                       ; count rows

;/*MESSAGES*/

m_intro   BYTE "Author: Satoru Yamamoto", 0dh, 0ah
          BYTE "Sorting Random Integers",0

m_inst    BYTE "Please provide 8 unsigned decimal integers.",0dh,0ah
          BYTE "Each number needs to be small enough to fit inside a 32-bit register.",0dh,0ah
          BYTE "After you have finished inputting the raw numbers, I will display a list of the ",0dh,0ah
          BYTE "integers, their sum, and their average value.",0

input_M   BYTE "Please enter an unsigned number: ",0
error_M   BYTE "ERROR: You did not enter an unsigned number, or your number was too big.",0dh,0ah
          BYTE "  Please try again: ",0

result_M  BYTE "You entered the following numbers:",0
sum_M     BYTE "The sum of these numbers is: ",0
average_M BYTE "The average is: ",0

quit_M    BYTE "Thanks for playing!",0

.code

main PROC
     ; Introduction 
     push      OFFSET    m_intro
     push      OFFSET    m_inst
     call      Introduction

     ;/*****************************************************
     ;* loop of ReadVal: Read user input, and fill in array
     ;***************************************************/
     mov  ecx, INPUTNUM                 ; set loop counter
     mov  esi, OFFSET array             ; set array pointer

Input:
     push      OFFSET    input_M
     push      OFFSET    error_M
     push      OFFSET    row_cnt
     push      LENGTHOF  buffer            
     push      OFFSET    buffer
     call      ReadVal

     mov       eax, DWORD PTR buffer
     
     mov       [esi], eax
     add       esi, 4

     loop      Input
     call Crlf
     
     ;/********************************************************
     ;* WriteVal: Display all elements of array as string
     ;*********************************************************/
     
     push      OFFSET    result_M
     push      OFFSET    buffer
     push      LENGTHOF  array            
     push      OFFSET    array
     call      WriteVal
     
     call Crlf     
     call Crlf
     ;/********************************************************
     ;* AveAndSum: Display average and sum of elements
     ;*********************************************************/

     push      OFFSET    sum_M
     push      OFFSET    average_M
     push      OFFSET    buffer
     push      LENGTHOF array            
     push      OFFSET array 
     call AveAndSum

     call Crlf
     ;/********************************************************
     ;* farewell: Display message to say goodbey
     ;*********************************************************/

     push      OFFSET    quit_M
     call      farewell            
     call Crlf

   exit
main ENDP


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
     push eax
     push edx

     mDisplayString ptrPrompt1                         ; First display message
     call Crlf
     call Crlf


     mDisplayString ptrPrompt2                         ; Second display message
     call Crlf
     call Crlf

     pop  edx
     pop  eax
     leave                                             ; mov esp,ebp and pop ebp

     ret  8
Introduction   ENDP

;/****************************************************
ReadVal   PROC           ;(checked)
;*        
;*        Get user input as a string and store information
;*        into buffer as integer.
;* 
;* Receives:
;*        ptrPrompt1          ; input message
;*        ptrPrompt2          ; error message
;*        counter             ; counter of row        
;*        bufferSize          ; Buffer length
;*        ptrBuffer           ; pointer to Buffer
;* Returns: nothing 
;* Preconditions: nothing 
;* Register changed: nothing
;*****************************************************/

ptrPrompt1     EQU  [ebp + 24]
ptrPrompt2     EQU  [ebp + 20]
counter        EQU  [ebp + 16]
bufferSize     EQU  [ebp + 12]
ptrBuffer      EQU  [ebp + 8]     

     ENTER 0,0
     pushad

     mov esi, counter                   ; esi holds pointer of rowcounter

     mov  eax, [esi]                    ; display current row number
     call WriteDec
     inc  eax                           ; increase one
     mov  [esi], eax 
     mov  al,  46
     call WriteChar                     ; display '.'
     
     mDisplayString ptrPrompt1

     ; this label is where it stores user input
L1:
     mov  edx, ptrBuffer                ; set buffer 
     mov  ecx, bufferSize               ; set maxChars
     mGetStirng     edx, ecx            ; get user input 

     mov  esi, edx                      ; set esi for LODSB
     mov  ebx, 10                       ; for multiplication
     mov  ecx, 0                        ; ecx holds actual value

     ; this loop checks each user's input elements by using LODSB
     ; if ax is not b/w 48 to 57, invalid input
     ; if carry flag is set during loop, invalid
     ; if ax is 0, loop ends
L2:
     mov  eax, 0                        ; clean up eax for LODSB
     LODSB                              ; load ESI into ax
     
     cmp  ax, 0                         ; if 0, end loop
     je   quit

     cmp  ax,  48                       ; lower bound
     jb   Invalid                       ; ax < 48 
     cmp  ax,  57                       ; upper bound
     ja   Invalid                       ; ax > 57

     ; else if valid input
     sub  ax,  48                       ; get integer
     xchg eax, ecx                      ; get current value into eax
     mul  ebx                           ; *10
     jc   Invalid                       ; if carry flag set, invalid 

     ; else, add eax and ecx and store result into ecx. jmp L2
     add  ecx, eax
     jmp  L2

     ; process of invalid input
     ; display error message and jmp L1
Invalid:
     
     mov esi, counter                   ; esi holds pointer of rowcounter

     mov  eax, [esi]                    ; display current row number
     call WriteDec
     inc  eax                           ; increase one
     mov  [esi], eax 
     mov  al,  46
     call WriteChar                     ; display '.'

     mDisplayString ptrPrompt2

     jmp  L1

quit:
     mov  esi, ptrBuffer
     mov  DWORD PTR [esi], ecx

     popad
     leave
     ret  20

ReadVal   ENDP

;/********************************************************
WriteVal   PROC               ;(checked)
;*
;*        Display all emements of received array as string
;* Receives: 
;*        ptrPrompt1               ; display message
;*        ptrBuffer                ; store stirng info
;*        sizeArray                ; length of array
;*        ptrArray                 ; points to array
;* Returns: nothing 
;* Preconditions: nothing 
;* Register changed: nothing
;*********************************************************/

ptrPrompt1     EQU  [ebp + 20]
ptrBuffer      EQU  [ebp + 16]
sizeArray      EQU  [ebp + 12]
ptrArray       EQU  [ebp + 8]

     ENTER 0,0
     pushad

     mDisplayString ptrPrompt1                         ; display message for elements
     call Crlf                     

     mov  esi, ptrArray                                ; set pointer
     mov  ecx, sizeArray                               ; set loop counter 

     ; loop for display all elements of array
Display:
     push [esi]                                        ; push integer
     push ptrBuffer                                    ; push ptrBuffer
     call IntToStr                                     ; ptrBuffer holds string 
     mDisplayString ptrBuffer                          ; display string
     
     cmp  ecx, 1                                       ; if ecx = 1, last element
     je   LaseEle

     add  esi, 4                                       ; next element

     mov  al,  44
     call WriteChar                                    ; display ',' 
     mov  al,  32
     call WriteChar                                    ; display ' ' 

LaseEle:
     loop Display                            

     popad
     LEAVE
     ret  12
WriteVal  ENDP


;/***************************************************************************
IntToStr   PROC               ;(checked)
;*
;*        Receive int and buffer. convert int to string and store into buffer
;* Receives: 
;*        value                         ; integer 
;*        strBuffer                     ; points buffer holds result string
;*
;* Returns: nothing 
;* Preconditions: nothing 
;* Register changed: nothing
;*******************************************************************************/

value          EQU  [ebp + 12]
strBuffer      EQU  [ebp + 8]

     ENTER 0,0
     pushad
     
     mov  eax, value
     mov  ebx, 10
     mov  ecx, 0                             ; count digits
     mov  edi, strBuffer                     ; edi points buffer

     ; Divide eax until eax = 0
     ; push edx, and increase ecx
Divide:
     cdq
     div  ebx
     push edx
     inc  ecx
     cmp  eax, 0                             ; loop until eax = 0
     jne  Divide
     
     ; pop int, add 48 and stosb until counter = 0 

StrChar:
     pop  ebx                                ; ebx holds int
     mov  al, bl
     add  al, 48
     stosb                                   ; store int as character of num
     loop StrChar                            ; ecx holds number of digits

     mov  al, 0                              ; '\0'
     stosb

     popad
     LEAVE
     ret  8
IntToStr  ENDP


;/*****************************************************************************************
AveAndSum   PROC    
;*
;*        Receive array, size of it. Display sum and average of elements of array as string
;* Receives: 
;*
;*        ptrPrompt1                         ; sum message
;*        ptrPrompt2                         ; average message
;*        ptrbuffer                          ; holds string info
;*        sizeArray                          ; length of array
;*        ptrArray                           ; points array
;*          
;* Returns: nothing 
;* Preconditions: nothing 
;* Register changed: nothing
;******************************************************************************************/
ptrPrompt1     EQU  [ebp + 24]
ptrPrompt2     EQU  [ebp + 20]
ptrbuffer      EQU  [ebp + 16]
sizeArray      EQU  [ebp + 12]
ptrArray       EQU  [ebp + 8]

     ENTER 0,0
     pushad

     mDisplayString ptrPrompt1               ; diplay sum message

     mov  esi, ptrArray                      ; set pointer of array
     mov  ecx, sizeArray                     ; set counter for loop

     mov  eax, 0                             ; clean up eax
SumElem:
     add  eax, [esi]                         ; add element into eax
     add  esi, 4                             ; next element
     loop SumElem

     push eax                                ; push sum value
     push ptrbuffer                          ; push buffer
     call IntToStr                           ; ptrbuffer holds string of number
     mDisplayString ptrbuffer                ; display sum as string
     call Crlf


     ; average = sum/sizeArray

     mDisplayString ptrPrompt2               ; diplay average message
     
     cdq
     mov  ebx, sizeArray
     div  ebx

     ; round up if (edx * 10 >= arraySize * 5)  
     imul edx, 10
     imul ebx, 5

     cmp  edx, ebx
     jb   AveElem                                 ; if (edx * 10 < arraySize * 5), jmp AveElem
     
     inc  eax                                     ; else increase eax

AveElem:
     push eax                                ; push average value
     push ptrbuffer                          ; push buffer
     call IntToStr                           ; ptrbuffer holds string of number
     mDisplayString ptrbuffer                ; display average as string
     call Crlf

     popad
     LEAVE
     ret  16
AveAndSum ENDP


;/****************************************************
farewell   PROC           ;(checked)
;*
;* Display 2 Messages to say goodbey
;*
;* Receives: 
;*   ptrPrompt1          ; offset of prompt string
;* Returns: nothing 
;* Preconditions: nothing 
;* Register changed: nothing
;*****************************************************/
ptrPrompt1     EQU  [ebp + 8]

     ENTER 0,0

     mDisplayString ptrPrompt1

     LEAVE
     ret 4
farewell  ENDP

END main