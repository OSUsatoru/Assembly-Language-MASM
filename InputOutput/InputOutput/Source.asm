COMMENT!

Author: Satoru Yamamoto
Final Edit Data: 10/05/2020

Description:
Write and test a MASM program to perform the following tasks:
1. Display your name and program title on the output screen.
2. Display instructions for the user.
3. Prompt the user to enter two numbers.
4. Calculate the sum, difference, product, (integer) quotient and remainder of the numbers.
5. Display a terminating message.

Optional Challenges:
1. Repeat until the user chooses to quit.
2. Validate the second number to be less than the first.
3. Calculate and display the quotient as a floating-point number, rounded to the nearest .001

//!

.386                               ;Identify this as 32-bit program
.model flat,stdcall                ;Selects the program's memory model(flat)
.stack 4096                        ;how many bytes of memory to reserve

;Assembly Language for x86 Processors Seventh Editon KIP R.IRVINE
;Chapter 3.2 p.63 - p.65

INCLUDE Irvine32.inc

.data

input1         DWORD ?             ; first input
input2         DWORD ?             ; second input


resSum         DWORD ?             ; result of each cases
resDif         DWORD ?
resPro         DWORD ?
resQuo         DWORD ?
resRem         DWORD ?
resFlo         DWORD ?
                                   ;floatNum       REAL4 ?             ; 4byte short real

THOUSAND      DWORD 1000           ;Used for float number

;*Messages*

introName      BYTE "Author: Satoru Yamamoto",0
introProject   BYTE "Programming Assignment 1: Integer arithmetic",0
instruction    BYTE "Enter 2 positive numbers, and I will show you the sum, difference, product, quotient, and remainder",0
OCinstruction1 BYTE "*This program verifies the second number to be less than the first*",0
OCinstruction2 BYTE "*This program calculates and display the quotient as a floating point number*",0
OCinstruction3 BYTE "*This program continues until the user EXIT*",0
invalid_M      BYTE "The second number is bigger than the first number!",0
last_M         BYTE "GOODBYE!",0

prompt1        BYTE "First Number: ",0
prompt2        BYTE "Second Number: ",0
prompt3        BYTE "CONTINUE: 1",0
prompt4        BYTE "EXIT: 0    : ",0

equal_S        BYTE ' = ',0
sum_S          BYTE ' + ',0
dif_S          BYTE ' - ',0
pro_S          BYTE ' * ',0
quo_S          BYTE ' / ',0
rem_S          BYTE ' Remainder ',0

SCIENTIFIC     BYTE "e-3",0             


.code

main PROC

;Display introduction
     mov edx, OFFSET introName                    ;set up for call to WriteString
     call WriteString
     call CrLf                                    ;'\n'

     mov edx, OFFSET introProject
     call WriteString
     call CrLf

     mov edx, OFFSET instruction
     call WriteString
     call CrLf

     mov edx, OFFSET OCinstruction1
     call WriteString
     call CrLf

     mov edx, OFFSET OCinstruction2
     call WriteString
     call CrLf

     mov edx, OFFSET OCinstruction3
     call WriteString
     call CrLf
    

;Get player inputs and *verifies them*

top: 
     
     call CrLf

     ;Get first input
     mov  edx, OFFSET prompt1
     call WriteString
     call ReadInt                                      ;store user input into eax as integer
     mov  input1, eax

     ;Get second input
     mov  edx, OFFSET prompt2
     call WriteString
     call ReadInt
     mov  input2, eax
     call CrLf

     ;if(first < second) invaid else valid
     mov eax, input1
     cmp eax, input2                                   ;compare input1 and input2 

     jae      Cal                                      ; Jump if (first >= second) input is unsigned
     jb       Invalid                                  ; Jump if (first <  second)

;Caluculate and display result
Cal:
     ;Caluculation
     ;sum
     mov  eax,      input1
     add  eax,      input2
     mov  resSum,    eax                               ;store result in resSum

     ;difference
     mov  eax,      input1
     sub  eax,      input2
     mov  resDif,   eax

     ;Get idea from p256-p257
     ;product 
     mov  eax,      input1
     mov  ebx,      input2
     mul  ebx
     mov  resPro,   eax
     
     
     ;quotient
     mov  edx,      0
     mov  eax,      input1
     cdq                                                ;(convert doubleword to quadword)
     mov  ebx,      input2
     cdq
     div  ebx
     mov  resQuo,   eax
     mov  resRem,   edx
     
     
     ;floating-point
     fld       input1                                  ;load floating-point value into ST(0)
     fdiv      input2                                  ;divide ST(0) by input2
     fimul     THOUSAND                                ;ST(0) * 1000
     frndint                                           ;rounds ST(0) to the nearest integer value
     fist      resFlo                                  ;store result as *Integer*

                                                       ;fstp     floatNum       ;store ST(0) to floatNum, and pop
     


     ;Display results

     ;Display sum
     mov  eax,      input1                             ;set up for call to WriteDec
     call WriteDec
     mov  edx,      OFFSET sum_S                       ; ' + '
     call WriteString
     mov  eax,       input2
     call WriteDec
     mov  edx,      OFFSET equal_S                     ; ' = '
     call WriteString
     mov  eax,      resSum
     call WriteDec
     call CrLf

     ;Display difference
     mov  eax,      input1
     call WriteDec
     mov  edx,      OFFSET dif_S
     call WriteString
     mov  eax,       input2
     call WriteDec
     mov  edx,      OFFSET equal_S
     call WriteString
     mov  eax,      resDif
     call WriteDec
     call CrLf

     ;Display product
     mov  eax,      input1
     call WriteDec
     mov  edx,      OFFSET pro_S
     call WriteString
     mov  eax,       input2
     call WriteDec
     mov  edx,      OFFSET equal_S
     call WriteString
     mov  eax,      resPro
     call WriteDec
     call CrLf

     ;Display quotient and remainder
     mov  eax,      input1
     call WriteDec
     mov  edx,      OFFSET quo_S
     call WriteString
     mov  eax,       input2
     call WriteDec
     mov  edx,      OFFSET equal_S
     call WriteString
     mov  eax,      resQuo
     call WriteDec
     mov  edx,      OFFSET rem_s
     call WriteString
     mov  eax,      resRem
     call WriteDec
     call CrLf
     

     ;Display floating-point value
     mov  eax,      input1
     call WriteDec
     mov  edx,      OFFSET quo_S
     call WriteString
     mov  eax,       input2
     call WriteDec
     mov  edx,      OFFSET equal_S
     call WriteString
     mov  eax,      resFlo
     call WriteDec
     mov  edx,      OFFSET SCIENTIFIC
     call WriteString
     call CrLf
     call CrLf

     jmp       Continue

;User input was invalid
Invalid:
     mov edx, OFFSET invalid_M
     call WriteString
     call CrLf
     call CrLf

;Ask user to continue
Continue:
     
     mov  edx, OFFSET prompt3
     call WriteString
     call CrLf
     mov  edx, OFFSET prompt4
     call WriteString 
     call ReadInt
     
     ; if input is 1, jump to top
     cmp  eax,1                                        ;compare user input and 1
     je   top                                          ;eax == 1, jump to top

     ; else say Goodbey
     call CrLf
     mov  edx, OFFSET last_M
     call WriteString
     call CrLf


     exit                                              ;exit to operating system

     main ENDP
END main