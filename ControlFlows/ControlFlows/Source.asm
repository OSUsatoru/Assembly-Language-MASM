COMMENT!
Author: Satoru Yamamoto
Final Edit Data : 10 / 10 / 2020

Description:
Write a program to calculate Fibonacci numbers.
• Display the program titleand programmer’s name.
• Then get the user’s nameand greet the user.
• Prompt the user to enter the number of Fibonacci terms to be displayed.Advise the user to enter an integer
in the range[1, 46].
• Getand validate the user input(n).
• Calculateand display all of the Fibonacci numbers up toand including the nth term.The results should be
displayed 4 terms per line with at least 4 spaces between terms.
• Display a parting message that includes the user’s name.
• Terminate the program.

Optional Clallenges:
/*****************************************************
* 1.My program can be chenged upper bound and lower bound
*   If you change num of them, this program 
*   display an instruction for changed num
* 2.you can change desine of output by changing COLUMN.
*   COLUMN is the maximum number of output in each row
*******************************************************/
!

.386; Identify this as 32 - bit program
.model flat, stdcall; Selects the program's memory model(flat)
.stack 4096; how many bytes of memory to reserve

; Assembly Language for x86 Processors Seventh Editon KIP R.IRVINE
; Chapter 3.2 p.63 - p.65

INCLUDE Irvine32.inc

;/************
;* Constant
;**************/

N_MAX = 64                                        ; max size of user name
UPPER = 46                                        ; upper bound
LOWER = 1                                         ; lower bound
COLUMN= 4                                         ; number of output in each row
TAB_NUM = 9                                       ; if row is less than or equal to TAB_NUM, the row has extra tab output

.data

userName       BYTE      N_MAX + 1   DUP(0)       ;store user name
name_length    DWORD     ?                        ;store user name length
counter        DWORD     ?                        ;store number of Fib terms

currentNum     DWORD     ?                        ;store current Feb num
preNum         DWORD     ?                        ;store previous Feb num
position       DWORD     ?                        ;count numbers in a row
rows           DWORD     ?                        ;count current row number.

;/*MESSAGES*/

introName      BYTE "Author: Satoru Yamamoto", 0
introProject   BYTE "Programming Assignment 2: Fibonacci Numbers", 0
name_q         BYTE "What is your name? ",0
Hello          BYTE "Hello, ",0
dot            BYTE '.',0

instruction    BYTE "Enter the number of Fibonacci terms to be displayed.",0
instruction2   BYTE "It should be an integer in the range [",0

howmany        BYTE "How many Fibonacci terms do you want? ",0
errorInput     BYTE "Out of range.  ",0

inputMes       BYTE "Enter a number in [",0
comma          BYTE ", ",0
square_block2  BYTE "]",0

GoodBey1       BYTE "Results certified by Satoru Yamamoto",0
GoodBey2       BYTE "Goodbey, ",0


.code

main PROC

     ;Display introduction
     mov edx, OFFSET introName                    ; set up for call to WriteString
     call WriteString
     call CrLf                                    ; '\n'

     mov edx, OFFSET introProject
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
     mov edx, OFFSET dot                          ; '.'
     call WriteString
     call CrLf
     call CrLf

     ;Instruction of this program
     mov edx, OFFSET instruction
     call WriteString
     call CrLf
     mov edx, OFFSET instruction2                           
     call WriteString
     mov eax, LOWER                               ;lower num
     call WriteDec
     mov edx, OFFSET comma                        ;, 
     call WriteString
     mov eax, UPPER                               ;upper num
     call WriteDec
     mov edx, OFFSET square_block2                ; ]
     call WriteString
     call CrLf
     

     ;Input user number and check if it is valid
     mov edx, OFFSET howmany
     call WriteString
     call ReadInt
     

     cmp  eax, UPPER                              ;compare input and upper bound
     ja   Input1                                  ;if(input > upper)
     cmp  eax, LOWER                              ;compare input and lower bound
     jb   Input1                                  ;if(input < lower)
     mov  counter, eax
     jmp  FebSetUp                                ;if lower <= input <= upper




;/************************************************
;* display error message and loop for user input
;* until (lower <= input <= upper)
;* post test loop
;**************************************************/

Input1:
     ;error message
     mov edx, OFFSET errorInput
     call WriteString

     mov edx, OFFSET inputMes
     call WriteString
     mov eax, LOWER
     call WriteDec
     mov edx, OFFSET comma
     call WriteString
     mov eax, UPPER
     call WriteDec
     mov edx, OFFSET square_block2
     call WriteString
     call CrLf

     ;ask user input
     mov edx, OFFSET howmany
     call WriteString
     call ReadInt
     
     cmp  eax, UPPER                                  ;compare input and upper bound
     ja   Input1                                      ;if(input > upper)
     cmp  eax, LOWER                                  ;compare input and lower bound
     jb   Input1                                      ;if(input < lower)
     
     mov counter, eax
;/*******************************
;* set up variables for Feb
;********************************/
FebSetUp:
     ;set up for Feb loop
     mov ecx,        counter                           ;this controles loop times
     mov currentNum, 0
     mov preNum,     1                                 
     mov position,   1                                 ;set position
     mov rows,       1                                 ;current row number is 1

;/******************************************
;* Fibs algorithm
;* Calculate and display Fibonacci numbers
;* each *COLUMN* numbers, change row
;* counted loop
;*******************************************/
Feb:
     ;Caluculate and Display Feb num
     mov  ebx, currentNum                              ;store currentNum in ebx     
     mov  eax, currentNum                               
     add  eax, preNum                                  ;add pre_number
     call WriteDec                                     ;display eax that is Feb num
     mov  currentNum, eax                              ;the result of past_num+current_num
     mov  preNum,  ebx                                 ;use ebx to hold old number and copy to past_num

     ;make output aligned clean
     mov  al, 9                                        ;this is TAB charactor
     cmp  rows,  TAB_NUM                               ;compare number of row and TAB_NUM to decide if it needs extra tab
     ja   TABS                                          ;if(rows > TAB)
     call WriteChar
TABS:
     call WriteChar
     call WriteChar

     cmp  position, COLUMN
     jae  newR                                         ;if(position >= COLUMN)
     inc  position                                     ;++position
     loop Feb                                          ;loop until ecx==0
     jmp  Quit                                         ;jump to quit

;/********************************************
;* This chenges row.  
;********************************************/
newR:
     call CrLf                                         ;change row
     inc  rows                                         ;increase rows
     mov  position, 1                                  ;updata position
     loop Feb                                          ;loop until ecx==0


;/************************
;* Farewell part
;* Display message to end
;*************************/
Quit:
     
     call CrLf
     call CrLf
     mov edx, OFFSET GoodBey1
     call WriteString
     call CrLf
     mov edx, OFFSET GoodBey2
     call WriteString
     mov edx, OFFSET userName
     call WriteString
     mov edx, OFFSET dot
     call WriteString

     exit                                              ;exit to operating system

     main ENDP
END main