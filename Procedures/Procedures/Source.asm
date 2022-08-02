COMMENT&
Author: Satoru Yamamoto
Final Edit Data : 10 / 23 / 2020

Description:
1) The programmer’s name must appear in the output.
2) The counting loop (1 to n) must be implemented using the MASM loop instruction.
3) The main procedure must consist (mostly) of procedure calls. It should be a readable “list” of
what the program will do.
4) Each procedure will implement a section of the program logic, i.e., each procedure will specify
how the logic of its section is implemented. The program must be modularized into at least the
following procedures and sub-procedures :
• introduction
• getUserData
• validate
• showComposites
• isComposite
• farewell
5) The upper limit should be defined and used as a constant.
6) Data validation is required. If the user enters a number outside the range [1 .. 400] an error
message should be displayed and the user should be prompted to re-enter the number of
composites.
7) The usual requirements regarding documentation, readability, user-friendliness, etc., apply.

Optional Clallenges: !I did every thing!
/************************************************************************************************
* 1.  Align the output columns
* 2.  Display more composites, but show them one page at a time. The user can “Press any key to
*     continue …” to view the next page. Since length of the numbers will increase, it’s OK to
*     display fewer numbers per line. 
* 3.  Store every prime numbers I found into array. !!!MY CODE IS FASTER THAN OTHERS!!! (I think)
************************************************************************************************/
&

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

TRUE = 1                                            
FALSE = 0                                            


UPPER = 400                                         ; upper bound
LOWER = 1                                           ; lower bound
SPACE = 6                                           ; space between num
COL  =  48                                          ; this is space * numbers per line
ROW = 30                                            ; this depends on the size of win

;PRIME     DWORD    2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97,101,103,107,109,113,127,131,137,139,149,151,157,163,167,173                      ;40 prime numbers 
          ;DWORD    179,181,191,193,197,199,211,223,227,229,233,239,241,251,257,263,269,271,277,281,283,293,307,311,313,317,331,337,347,349,353,359,367,373,379,383,389,397 ;38 prime numbers 

;NUM_PRIME = ($ - PRIME) / 4                      ; prime number in array ( esi should be less than it )

.data

Prime          DWORD 100 DUP(0)                   ; store every prime numbers I found
isPrime        BYTE      ?                        ; true if prime
max_prime      DWORD     ?                        ; maximum prime number in array
prime_cnt      DWORD     ?                        ; number of prime numbers in array
counter        DWORD     ?                        ; used as counting things
input          DWORD     ?                        ; store user input


cnt_col        BYTE      0                        ; count col
cnt_row        BYTE      0                        ; count row     

display_row    BYTE      1                        ; count display row

;/*MESSAGES*/

introName      BYTE "Author: Satoru Yamamoto", 0
introProject   BYTE "Composite Numbers", 0

instruction    BYTE "Enter the number of composite numbers you would like to see.",0
instruction2   BYTE "I'll accept orders for up to 400 composites.",0
errorInput     BYTE "Out of range. Try again.",0
inputMes       BYTE "Enter the number of composites to display [1, 400]: ",0

GoodBey1       BYTE "Results certified by Satoru. Goodbey.",0


.code

main PROC
     call Intro                                        ;Display starting messages
     call getUserData                                  ;For User valid Input.
     call showComposites                               ;Display composite numbers
                                           
     call farewell                                     ;Display message for end
     
     exit                                              ;exit to operating system
     main ENDP

;/******************************************************
;* Intro (cehcked) (using 6 lines)
;* 
;* Display Introduction and Instruction messages.
;* Receives: nothing
;* Returns: nothing
;* Registers changed: edx
;****************************************************/
Intro PROC
     ;Display introduction
     mov edx, OFFSET introProject                    ; set up for call to WriteString
     call WriteString
     call CrLf                                       ; '\n'

     mov edx, OFFSET introName
     call WriteString
     call CrLf
     call CrLf

     ;Instruction of this program
     mov edx, OFFSET instruction
     call WriteString
     call Crlf
     mov edx, OFFSET instruction2
     call WriteString
     call Crlf
     call Crlf
     
     add  cnt_row,  6
     RET

Intro ENDP

;/****************************************************
;* getUserData (checked) 
;*
;* Get inupt for user and call validate procedure
;* Receives: nothing
;* Returns: glocal input = EAX = valid user input
;* Register changed: eax, edx 
;*****************************************************/
getUserData PROC
     mov edx, OFFSET inputMes
     call WriteString
     call ReadDec

     inc  cnt_row                                 ; counting row

     call validate
     mov  input, eax                              ; store valid data into input

     RET
getUserData ENDP

;/***********************************************************
;* validate (sub-procedure of getUserData) (checked) 
;*
;* Check if EAX is between 1 to 400 
;* Receives: EAX = user input
;* Returns: EAX = valid user input [1 to 400]
;* Registers changed: eax, edx
;***********************************************************/
validate PROC
     cmp  eax, UPPER
     ja   Invarid                                 ; if input is above to UPPER
     cmp  eax, LOWER
     jb   Invarid                                 ; if input is below to LOWER
    
     RET
Invarid:
     mov edx, OFFSET errorInput                   ; display error message
     call WriteString
     call Crlf

     inc  cnt_row                                 ; counting row

     call getUserData
     RET
validate ENDP

;/********************************************************************
;* showComposites (checked)
;*
;* Display composite numbers if IsPrime is FALSE
;* Receives: global variable: input, isPrime
;* Preconditions: LOWER <= input <=UPPER
;* Returns: nothing
;* Registers changed: eax, ecx
;********************************************************************/
showComposites PROC
     ; set up
     
     mov  max_prime, 0                    
     mov  prime_cnt, 0 
     mov  ecx, input                                   ; set loop counter
     mov  eax, 0
     call Crlf

     inc  cnt_row                                      ; counting row
     
     ;/*************************************
     ;* Loop isComposite 1 to input
     ;* Check isPrime and Display if FALSE
     ;**************************************/
L1:
     mov  isPrime,  TRUE                              ; reset isPrime everytimes 
     inc  eax                                         ; check if eax is composite number
     call isComposite
     
     cmp  isPrime,  TRUE
     je   L1                                           ; do not decrease ecx

     ;/**************************************************
     ;* Align the output columns
     ;* cnt_col is current col. cnt_row is current row
     ;***************************************************/
     mov  edx, 0
     mov  dl,  cnt_col
     mov  dh,  cnt_row
     call gotoxy                                       ; move (cnt_col, con_row)

     call WriteDec                                     ; display number

     add  cnt_col,  SPACE                              ; cnt_col + SPACE
     
     cmp  cnt_col,  COL                                ; if(cnt_col < COL) no need new line
     jb   no_newLine

     mov  cnt_col, 0                                   ; reset cnt
     inc  cnt_row
     inc  display_row                                  ; count display row
     cmp  display_row,   ROW                           ; if(display_row < ROW) no need wait message
     jb   no_wait
     call crlf
     inc  cnt_row
     call WaitMsg
     mov  display_row,   1
no_wait:
no_newLine:
     
     loop L1

     call Crlf
     call Crlf
     RET
showComposites ENDP

;/******************************************************************************************
;* is Composite (sub-procedure of showComposites) (checked)
;*
;* Check number. If composite, isPrime is FALSE and RET, else store prime number and 
;* isPrime is TRUE
;* Receives: EAX: check this number. grobal vairables: counter, isPrime, max_prime, prime_cnt
;* Returns: in anycases, return the reveiced EAX value. grobal variable: isPrime = true or false.
;*******************************************************************************************/
isComposite PROC
     
     push ecx                                          ; push ecx(outer loop counter) in stack
     
     ;/*************************
     ;* Base case 
     ;* if eax = 1 quit
     ;* if eax = 2 L3
     ;**************************/
     cmp  eax, 1
     je   Quit
     cmp  eax, 2
     je  L3

     ;/*****************************************************
     ;* This LOOP uses prime numbers to check number.  (cheched moved)
     ;* check if (eax % Prime[counter* TYPE Prime]) == 0
     ;*****************************************************/
     cmp  prime_cnt, 0                                 ; if there is no stored prime number
     je   L1_end                                       ; skip L1 process
     mov  ecx, prime_cnt                               ; ecx counter for L1 loop

L1:
     
     push eax
     mov  eax, prime_cnt
     sub  eax, ecx                                     
     mov  counter, eax                                 ; This counter is [0, prime_cnt)
     pop  eax

     imul esi, counter,  TYPE Prime                    ; esi is itr for array
     
     
     
   
     ;check one: if(eax <= Prime[itr])
     cmp  eax, Prime[esi]                              
     jbe  L1c1                                         ; This number is stored Prime number
     
     ;check two if(eax%Prime[itr] == 0)
     push eax                                          ; store eax into stack
     mov  ebx, Prime[esi]
     cdq
     div  ebx
     pop  eax                                          ; pop eax value
     cmp  edx, 0                                       ; if(rem == 0)               
     je   L1c2                                         ; composite number

     cmp  ecx, 1                                       ; do not want to loop when ecx = 0
     loopne L1                                         ; loop if not equal
                                                       ; end of L1 loop
     jmp  L1_end

     ;Loop1 check1
L1c1:
     mov  isPrime,  TRUE
     jmp  Quit                                         ; jump to Quit
     ;Loop1 check2
L1c2:
     mov  isPrime,  FALSE
     jmp  Quit                                         ; jump to Quit

L1_end:



     ;/*****************************************************
     ;* This LOOP check [max(2,max_prime+1) to (counter)^2 <= EAX]
     ;* if eax is diviable, prime = false and jmp to Quit
     ;*****************************************************/
     

     cmp  max_prime, 2
     ja  L2s1
     
     mov  counter,  2
     jmp  L2

     ;L2 setup 1
L2s1:
     mov  ebx, max_prime
     mov  counter, ebx
     inc  counter

L2:
     
     ;(if(eax%counter==0))
     push eax                                          ; push eax
     mov  edx, 0
     mov  ebx, counter
     cdq
     div  ebx
     pop  eax                                          ; pop eax
     cmp  edx, 0                                       ; eax is composite number
     je   L2c1                                         ; this case no need to loop anymore
     
     ; check if need to loop
     push eax
     mov  eax, counter
     mov  ebx, counter
     mul  ebx
     mov  ebx, eax
     pop  eax
     
     inc  counter                                      ; increase counter for next loop
     
     cmp  ebx, eax
     jbe  L2                                           ; if(counter^2 <= eax) loop2

     jmp  L3                                           ; end of L2 loop

L2c1:
     mov isPrime,   FALSE
     jmp  Quit

L3:
     cmp  isPrime,  FALSE
     je   Quit                                         ; If number is composite, jump to Quit
     
     ;/********************************************************** 
     ;* If number is Prime:
     ;* 1. add number into array, 2. ++cnt, 3. max_prime = number
     ;* Register changed: esi
     ;************************************************************/
     imul esi, prime_cnt, TYPE Prime                   ; esi = prime_cnt * TYPE Prime

     mov  Prime[esi],    eax                           ; Add new prime number into array
     inc  prime_cnt                                    ; increase counter
     mov  max_prime,     eax                           ; Updata max_prime information


Quit:
     pop ecx                                           ; pop ecx counter for outer loop
     RET
isComposite ENDP


;/****************************************************
;* farewell (checked) (using 2 lines)
;*
;* Display message to end program
;* Receives: nothing
;* Returns: nothing
;* Register changed: edx
;*****************************************************/
farewell PROC
     call WaitMsg                                      ; Wait user input
     call Crlf
     call CrLf
     mov edx, OFFSET GoodBey1
     call WriteString
     call CrLf
     RET
farewell ENDP

END main