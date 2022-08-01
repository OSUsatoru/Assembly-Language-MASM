COMMENT!
Author: Satoru Yamamoto
Final Edit Data : 10 / 18 / 2020

Description:
Write and test a MASM program to perform the following tasks:
1. Display the program title and programmer’s name.
2. Get the user’s name, and greet the user.
3. Display instructions for the user.
4. Repeatedly prompt the user to enter a number. Validate the user input to be in [-100, -1] (inclusive).
Count and accumulate the valid user numbers until a non-negative number is entered. (The nonnegative number is discarded.)
5. Calculate the (rounded integer) average of the negative numbers.
6. Display:
i. the number of negative numbers entered (Note: if no negative numbers were entered, display
a special message and skip to iv.)
ii. the sum of negative numbers entered
iii. the average, rounded to the nearest integer (e.g. -20.5 rounds to -21; 20.5 rounds to 21)
iv. a parting message (with the user’s name)


Optional Clallenges:
/*****************************************************
* 1. Number the lines during user input
*******************************************************/
!

.386; Identify this as 32 - bit program
.model flat, stdcall; Selects the program's memory model(flat)
.stack 4096; how many bytes of memory to reserve

; Assembly Language for x86 Processors Seventh Editon KIP R.IRVINE
; Chapter 3.2 p.63 - p.65

INCLUDE Irvine32.inc

;/**********************
;* Constant numbers
;***********************/
.const

N_MAX = 64                                        ; max size of user name
UPPER = -1                                        ; upper bound
LOWER = -100                                      ; lower bound

.data

userName       BYTE      N_MAX + 1   DUP(0)       ;store user name
name_length    DWORD     ?                        ;store user name length
counter        DWORD     ?                        ;store number of use input

sum_input      SDWORD    ?                        ;store sum of negative numbers
average        SDWORD    ?                        ;store average
rem            SDWORD    ?                        ;store reminder


;/*MESSAGES*/

introName      BYTE "Author: Satoru Yamamoto", 0
introProject   BYTE "Welcome to the Integer Accumulator", 0
name_q         BYTE "What is your name? ",0
Hello          BYTE "Hello, ",0


instruction    BYTE "Please enter numbers in [",0
instruction2   BYTE "Enter a non-negative number when you are finished to see results",0
errorInput     BYTE "Out of range.  ",0
inputMes       BYTE "Enter number: ",0

cnt_message1   BYTE "You entered ",0
cnt_message2   BYTE " valid numbers.",0

sum_message1   BYTE "The sum of your valid numbers is ",0

ave_message1   BYTE "The rounded average is ",0

GoodBey1       BYTE "Thank you for playing Integer Accumulator!",0
GoodBey2       BYTE "It's been a pleasure to meet you, ",0


.code

main PROC

     ;Display introduction
     mov edx, OFFSET introProject                    ; set up for call to WriteString
     call WriteString
     call CrLf                                       ; '\n'

     mov edx, OFFSET introName
     call WriteString
     call CrLf
     call CrLf

     ;Input user name and display
     mov edx, OFFSET name_q
     call WriteString

     mov ecx,  N_MAX                              ; max = 64
     mov edx,  OFFSET userName                    ; point to the userName
     call ReadString                              ; input the string, and it must be less than 64 characters
     mov  name_length, eax                        ; store length of user name 

     mov edx, OFFSET Hello                        ;"Hello"
     call WriteString
     mov edx, OFFSET userName                     ;"User name""   
     call WriteString                          
     mov al, 46                                   ;Ascii 46 = '.'
     call WriteChar
     call CrLf
     call CrLf

     ;Instruction of this program
     
     mov edx, OFFSET instruction                           
     call WriteString
     mov eax, LOWER                               ;lower num
     call WriteInt
     mov al, 44                                   ;Ascii 44 = ','
     call WriteChar
     mov eax, UPPER                               ;upper num
     call WriteInt
     mov al, 93                                   ;Ascii 93 = ']'
     call WriteChar
     call CrLf

     mov edx, OFFSET instruction2
     call WriteString
     call CrLf



;/****************************************************
;* Set up valiables for Input and calculation process
;******************************************************
Setup:
     mov counter, 0                               ;counter starts from 0
     mov sum_input, 0                             ;sum of input starts from 0
;/******************************************
;* Display message for user Input.
;* Check if input is valid.
;* if input is possitive, jump to Result
;* if input is less than -100, jump to Invalid
;* else loop Input 
;*******************************************/
Input:
     ;Display message and input userInput
     mov eax, counter
     inc eax                                      ;Display Number of input
     call WriteDec
     mov al, 46                                   ;Ascii 46 = '.'
     call WriteChar
     mov al, 32                                   ;Ascii 32 = ' '
     call WriteChar   
     
     mov edx, OFFSET inputMes                     ; "Enter number"
     call WriteString
     call readInt
     
     ; check the user input
     cmp  eax, UPPER                              ;compare input and upper bound
     jg   Result                                  ;if(input > upper), user input is positive and jump to Result
     cmp  eax, LOWER                              ;compare input and lower bound
     jl   Invarid                                 ;if(input < lower), out of range  

     inc  counter                                 ;varid input, so increase counter
     add  sum_input, eax                          ;add user input into it
     jmp  Input                                   ;if lower <= input <= upper

;/**************************************************
;* Display error message and jump to Input process
;**************************************************/
Invarid:
     mov edx, OFFSET errorInput                   ; error message
     call WriteString
     call Crlf
     jmp Input                                    ; go back to Input

;/**********************************************************
;* Display result.
;* 1. count 2. sum 3. Rounded average
;**********************************************************/
Result:
     
     ;Display the number of valid numbers
     mov edx, OFFSET cnt_message1
     call WriteString
     mov eax, counter
     call writeDec
     mov edx, OFFSET cnt_message2
     call WriteString
     call Crlf

     cmp eax, 0                                   ;check if there is input
     je   Quit

     ;Display the sum of inputs
     mov edx, OFFSET sum_message1
     call WriteString
     mov eax, sum_input
     call WriteInt
     call CrLf
     
     ;Caluculate and Display the rounded average
     mov edx, OFFSET ave_message1
     call WriteString

     mov  eax, sum_input
     cdq                                          ;extend the sign bit of eax into edx
     mov  ebx, counter
     idiv ebx                                     ;signed divide. quotient EAX, rem EDX
     mov  average, eax
     mov  rem, edx
     
     ; process to round average
     
     mov eax, rem
     mov ebx, -10
     imul  ebx

     mov ebx, counter
     idiv ebx                                     ; remainder*10/counter
     cmp  eax, 5                                  ; if this result >= 5, average - 1
     
     jl   UnChange                                ; result < 5
     dec  average                                 ; decrease average to round to the nearest integer

;/***************************************** 
;* (rem*(-10) / counter) >= 5, average-1.
;* otherwise unchange
;******************************************/
UnChange:
     mov eax, average
     call WriteInt
     call Crlf


                                                  COMMENT!
                                                       /******************
                                                       * tried to use FPU
                                                       ********************/
     

                                                       fild  sum_input                              ;push int into ST
                                                       fidiv counter                                ;Float/int
                                                       FRNDINT
                                                       call WriteFloat                              ;Display ST(0)
                                                  !
     
     
     
     
;/************************
;* Farewell part
;* Display message to end
;*************************/
Quit:
     
     call CrLf
     mov edx, OFFSET GoodBey1
     call WriteString
     call CrLf
     mov edx, OFFSET GoodBey2
     call WriteString
     mov edx, OFFSET userName
     call WriteString
     mov al, 46                                   ;Ascii 46 = '.'
     call WriteChar
     call CrLf
     exit                                              ;exit to operating system

     main ENDP
END main