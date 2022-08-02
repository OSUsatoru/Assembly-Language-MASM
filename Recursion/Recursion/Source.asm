COMMENT&
Author: Satoru Yamamoto
Final Edit Data : 12 / 03 / 2020

Requirements:
1) The calculation must use the formula of combinations: cnr = c(n, r) =n!/(r!(n-r)!).The factorial calculation, like f(k) = k!, must be done recursively.
2) User's numeric input must be validated the hard way: Read the user's input as a string, convert
the string to numeric form. If the user enters non-digits, an error message should be displayed.
3) All parameters must be passed on the system stack.
4) Used registers must be saved and restored by the called procedure.
5) The stack must be “cleaned up” by the called procedure.
6) The program must be modularized into at least the following procedures:
a. main: mostly pushing parameters and calling procedures.
b. introduction: display title, programmer name, and instructions.
c. showProblem: generates the random numbers and displays the problem
     - showProblem accepts addresses of n and r.
d. getData: prompt / get the user's answer.
     - answer should be passed to getData by address (of course!).
e. combinations, factorial: do the calculations.
     - combinations accepts n and r by value and result by address.
     - combinations calls factorial (3 times) to calculate n!, r!, and (n-r)!.
     - combinations calculates cnr = c(n, r) =n!/r!(n-r)!, and stores the value in result.
f. showResults: display the student's answer, the calculated result, and a brief statement about
the student's performance
     - showResults accepts the values of n, r, answer, and result.
7) You should use a string display macro to display strings.
8) The usual requirements regarding documentation, readability, user-friendliness, etc., apply.


Optional Clallenges: 
/************************************************************************************************
1) Numbering each problem and keeping score. When the student quits, report number right/wrong, etc.
2) Computing factorials in the floating-point unit to expand the limits.
************************************************************************************************/
------------------------------------------------------------------------------------------------------&

.386; Identify this as 32 - bit program
.model flat, stdcall; Selects the program's memory model(flat)
.stack 4096; how many bytes of memory to reserve

; Assembly Language for x86 Processors Seventh Editon KIP R.IRVINE
; Chapter 3.2 p.63 - p.65

INCLUDE Irvine32.inc

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

LOWER  = 3                              ; lower bound for random num
UPPER = 12                              ; upper bound for random num

CHAR = 15                               ; number of input characters

.data

buffer    BYTE CHAR DUP(0)              ; input buffer
cnt_R     DWORD     0                   ; count correct answer
value_n   DWORD     ?                   ; value of n
value_r   DWORD     ?                   ; value of r
user_ans  DWORD     ?                   ; user input answer
answer    DWORD     1                   ; answer of problem
cnt_pro   DWORD     0                   ; count problem numbers

userInp   DWORD     0                   ; if continue userInp = 1

;/*MESSAGES*/

m_intro   BYTE "Welcome to the Combinations Calculator", 0dh, 0ah
          BYTE "Author: Satoru Yamamoto",0

m_inst    BYTE "I'll give you a combinations problem. You enter your answer, and I'll let you know if",0dh,0ah
          BYTE "you're right.",0

prob_1    BYTE "Problem #",0
prob_2    BYTE "Number of elements in the set: ",0
prob_3    BYTE "Number of elements to choose from the set: ",0

m_input   BYTE "How many ways can you choose? ",0
m_invalid BYTE "ERROR: You did not enter an unsigned number, or your number was too big.",0dh,0ah
          BYTE "Please try again: ",0

result_m1 BYTE "These are ",0
result_m2 BYTE " combinations of ",0
result_m3 BYTE " items for a set of ",0

correct_m BYTE "You are correct!",0
false_m   BYTE "You need more practice.",0


continue_m BYTE "Another problem? (y/n): ",0
invalid_m  BYTE "Invalid Input",0
quie_m1    BYTE "Correct answer: ",0
quie_m2    BYTE "Wrong answer: ",0
quie_m3    BYTE "OK ... goodbey.",0

.code

main PROC
     ; Introduction 
     push      OFFSET    m_intro
     push      OFFSET    m_inst
     call      Introduction

L1:
     ; showProblem
     push      OFFSET    cnt_pro
     push      OFFSET    prob_1
     push      OFFSET    prob_2
     push      OFFSET    prob_3
     push      OFFSET    value_n
     push      OFFSET    value_r
     call      showProblem

     ; getData
     push      OFFSET    m_input
     push      OFFSET    m_invalid
     push      LENGTHOF  buffer
     push      OFFSET    buffer
     call      getData

     mov       eax, DWORD PTR buffer
     mov       user_ans, eax
     mov       eax, user_ans

     ; conbinations

     push      value_n
     push      value_r
     push      OFFSET    answer
     call      conbinations     
     
     ; showResults
     push      OFFSET    result_m1 
     push      OFFSET    result_m2 
     push      OFFSET    result_m3
     push      OFFSET    correct_m 
     push      OFFSET    false_m
     push      value_n
     push      value_r
     push      answer
     push      user_ans
     push      OFFSET    cnt_R
     call      showResults

     ; continueGame
     push      LENGTHOF  buffer
     push      OFFSET    buffer
     push      OFFSET    userInp
     push      OFFSET    continue_m
     push      OFFSET    invalid_m
     push      OFFSET    quie_m1
     push      OFFSET    quie_m2
     push      OFFSET    quie_m3
     push      cnt_pro
     push      cnt_R
     call      continueGame

     mov  eax, userInp
     cmp  eax, 1
     je   L1
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
showProblem   PROC           ;(checked)
;*             
;*        display problem by generating 2 randome numbers
;* 
;* Receives:
;*        counter             ; number of problems
;*        ptrPrompt1          ; message for problem
;*        ptrPrompt2          ; message for value n
;*        ptrPrompt3          ; message for value r
;*        rand_n              ; random num n
;*        rand_r              ; random num r
;*
;* Returns: nothing 
;* Preconditions: nothing 
;* Register changed: nothing
;*****************************************************/

counter        EQU  [ebp + 28]                         ; number of problems
ptrPrompt1     EQU  [ebp + 24]                         ; First message
ptrPrompt2     EQU  [ebp + 20]                         ; Second message
ptrPrompt3     EQU  [ebp + 16]                         ; Third message
rand_n         EQU  [ebp + 12]                         ; random num n
rand_r         EQU  [ebp + 8]                          ; random num r
     
     ENTER 0,0
     pushad

     mDisplayString ptrPrompt1
     mov  esi, counter                                 
     mov  eax, [esi]
     inc  eax                                          ; increase counter
     mov  [esi], eax
     call WriteDec                                     ; display number of problem
     call Crlf

     ; generate random num for n
     push LOWER
     push UPPER
     push rand_n
     call generateRdm

     ; display n
     mDisplayString ptrPrompt2
     mov  edi, rand_n
     mov  eax, [edi]
     call WriteDec
     call Crlf

     ; generate random num for r
     mov  ebx, 1
     push ebx
     push [edi]
     push rand_r
     call generateRdm

     ; display r
     mDisplayString ptrPrompt3
     mov  edi, rand_r
     mov  eax, [edi]
     call WriteDec
     call Crlf
     popad
     LEAVE
     ret  20
showProblem ENDP


;/****************************************************
generateRdm   PROC           ;(checked)
;*        
;*        generates rundom number b/w lower and upper bound
;*        
;* Receives:
;         low_bound           ; lower bound
;         up_bound            ; upper bound
;         rand_num            ; random num
;* Returns: nothing 
;* Preconditions: nothing 
;* Register changed: nothing
;*****************************************************/
low_bound      EQU  [ebp + 16]                         ; lower bound
up_bound       EQU  [ebp + 12]                         ; upper bound
rand_num       EQU  [ebp + 8]                          ; random num
     
     ENTER 0,0
     pushad
     call Randomize                                    ; init random generator
     mov  edi, rand_num

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

     mov  [edi], eax

     popad
     LEAVE
     ret  12
generateRdm    ENDP


;/****************************************************
getData   PROC           ;(checked)
;*        
;*        Get user input as string 
;*        
;* Receives:
;*
;*        ptrPrompt1     ; input message
;*        ptrPrompt2     ; error message
;*        bufferSize       ; buffer length
;*        ptrBuffer      ; poniter to buffer
;*
;* Returns: nothing 
;* Preconditions: nothing 
;* Register changed: nothing
;*****************************************************/

ptrPrompt1     EQU  [ebp + 20]                         ; input message
ptrPrompt2     EQU  [ebp + 16]                         ; error message
bufferSize     EQU  [ebp + 12]                         ; buffer length
ptrBuffer      EQU  [ebp + 8]                          ; pointer to buffer
     
     ENTER 0,0
     pushad
     mDisplayString ptrPrompt1                         ; user input message


     ; this label is where it stores user input
L1:
     mov  edx, ptrBuffer                ; set buffer 
     mov  ecx, bufferSize               ; set maxChars
     call ReadString
     

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
     mDisplayString ptrPrompt2
     jmp  L1

quit:
     mov  esi, ptrBuffer
     mov  DWORD PTR [esi], ecx

     popad
     LEAVE
     ret  16
getData   ENDP

;/****************************************************
conbinations   PROC           ;(checked)
;*        
;*        calculate nCr by using factorial procedure
;*        
;* Receives:
;*
;*        ptrPrompt1     ; input message
;*        ptrPrompt2     ; error message
;*        bufferSize     ; buffer length
;*        ptrBuffer      ; poniter to buffer
;*
;* Returns: nothing 
;* Preconditions: nothing 
;* Register changed: nothing
;*****************************************************/
valueN         EQU  [ebp + 16]
valueR         EQU  [ebp + 12]
result         EQU  [ebp + 8]
     
     ENTER 0,0
     pushad

     mov  esi, result         ; set address of result
     mov  ebx, 1
     mov  [esi], ebx                         ; reset result
     ; calculate n! result into eax
     push valueN
     push esi
     call factorial
     mov  eax, [esi]
     mov  ebx, 1
     mov  [esi], ebx                         ; reset result

     ; calculate (n-r)! 
     mov  ebx, valueN
     sub  ebx, valueR
     push ebx
     push esi 
     call factorial
     mov  ebx, [esi]

     div  ebx                                ; n!/(n-r)!
     
     mov  ebx, 1
     mov  [esi], ebx                         ; reset result
     ; calculate r!
     push valueR
     push esi
     call factorial
     mov  ebx, [esi]
     div  ebx                                ; (n!/(n-r)!)/r!

     mov  [esi], eax

     popad
     LEAVE
     ret  12
conbinations   ENDP
;/****************************************************
factorial   PROC           ;(checked)
;*        
;*        calculate value!
;*        base case: value = 1 or value = 0 <- this case is when n == r
;*        1! = 0! = 1
;* Receives:
;*
;*        value          ; value 
;*        result         ; points to user input
;*
;* Returns: nothing 
;* Preconditions: nothing 
;* Register changed: nothing
;*****************************************************/
value         EQU  [ebp + 12]
result        EQU  [ebp + 8]

     ENTER 0,0
     push esi
     push eax
     push ebx

     mov  esi, result
     mov  eax, [esi]
     mov  ebx, value

     cmp  ebx, 1
     jle   basecase                    ; when value = 1 or value = 0

     ; else
     mul  ebx
     mov  [esi], eax
     dec  ebx

     push ebx
     push esi
     call factorial

     ; end recursion
basecase:
     
     pop  ebx
     pop  eax
     pop  esi
     LEAVE
     ret  8
factorial   ENDP
;/****************************************************
showResults   PROC           ;(checked)
;*        
;*             display result message and count correct answer
;*       
;* Receives:
;*
;*        ptrPrompts          ; 5 messages 
;*        value r and n       ; for display
;*        ans
;*        ans_u               ; user input and actual answer
;*        counter             ; points to count_R
;* Returns: nothing 
;* Preconditions: nothing 
;* Register changed: nothing
;*****************************************************/

ptrPrompt1     EQU  [ebp + 44]                         ; result_m1
ptrPrompt2     EQU  [ebp + 40]                         ; result_m2
ptrPrompt3     EQU  [ebp + 36]                         ; result_m3
ptrPrompt4     EQU  [ebp + 32]                         ; correct_m
ptrPrompt5     EQU  [ebp + 28]                         ; false_m
valueN         EQU  [ebp + 24]                         ; n
valueR         EQU  [ebp + 20]                         ; r
ans            EQU  [ebp + 16]                         ; answer
ans_u          EQU  [ebp + 12]                         ; user answer
counter        EQU  [ebp + 8]                          ; count correct answer

     ENTER 0,0
     pushad
     call Crlf
     ; display result messages
     mDisplayString ptrPrompt1
     mov  eax, ans
     call WriteDec
     mDisplayString ptrPrompt2
     mov  eax, valueR
     call WriteDec
     mDisplayString ptrPrompt3
     mov  eax, valueN
     call WriteDec
     mov  al,  46
     call WriteChar                     ; display '.'
     call Crlf

     mov  eax, ans
     cmp  eax, ans_u
     jne  wrong

     mDisplayString ptrPrompt4
     mov  esi, counter
     mov  eax, [esi]
     inc  eax
     mov  [esi], eax               ; count up
     jmp  quit
wrong:
     mDisplayString ptrPrompt5
quit:
     call Crlf
     call Crlf

     popad
     LEAVE
     ret  40
showResults    ENDP

;/****************************************************
continueGame   PROC           ;(checked)
;*        
;*             display result message and count correct answer
;*       
;* Receives:
;*        ans                 ; ans = 1 if continue
;*        ptrPrompts          ; 5 messages 
;*        problems            ; number of problem
;*        corrects            ; number of correct answer
;* Returns: nothing 
;* Preconditions: nothing 
;* Register changed: nothing
;*****************************************************/
bufferSize     EQU  [ebp + 44]                         ; buffer length
ptrBuffer      EQU  [ebp + 40]                          ; pointer to buffer
ans            EQU  [ebp + 36]                         ; store user input
ptrPrompt1     EQU  [ebp + 32]                         ; continue_m
ptrPrompt2     EQU  [ebp + 28]                         ; invalid_m
ptrPrompt3     EQU  [ebp + 24]                         ; quie_m1
ptrPrompt4     EQU  [ebp + 20]                         ; quie_m2
ptrPrompt5     EQU  [ebp + 16]                         ; quie_m3
problems       EQU  [ebp + 12]                         ; number of problem
corrects       EQU  [ebp + 8]                          ; number of correct answer
     
     ENTER 0,0
     pushad
    
    ; if invalid input, jmp here
L1:     
     mDisplayString ptrPrompt1
     mov  edx, ptrBuffer
     mov  ecx, bufferSize
     call ReadString
     cmp  eax, 1                                       ; eax stores the size of input
     jne  Invalid                                      ; if input size is not 1, invalid

     ;else
     cld
     mov  ecx, eax                                     ; counter for lodsb
     mov  esi, ptrBuffer

     lodsb
     cmp  al, 121                                      ; ascii 121 = 'y'
     je   continue
     
     ; do not continue
     mov  esi, ans
     mov  eax, 0         
     mov  [esi], eax                                   ; ans = 0
     
     ;display results

     mDisplayString ptrPrompt3
     mov  eax, corrects
     call WriteDec
     call Crlf
     mDisplayString ptrPrompt4
     mov  eax, problems
     sub  eax, corrects
     call WriteDec
     call Crlf

     mDisplayString ptrPrompt5
     call Crlf

     jmp  quit
Invalid:
     mDisplayString ptrPrompt2
     call Crlf
     jmp  L1
continue:
     mov  esi, ans
     mov  eax, 1
     mov  [esi], eax
quit:
     call Crlf
     popad
     LEAVE
     ret  40
continueGame   ENDP

END main