COMMENT&
Author: Satoru Yamamoto
Final Edit Data : 11 / 7 / 2020

Description:
Write and test a MASM program to perform the following tasks:
1. Introduce the program.
2. Get a user request in the range [16, 256] -- [min, max].
3. Generate request random integers in the range [64, 1024] -- [lo, hi], storing them in consecutive
elements of an array.
4. Display the list of integers before sorting, 5 numbers per line.
5. Sort the list in descending order (i.e., largest first).
6. Calculate and display the median value, rounded to the nearest integer.
7. Calculate and display the average value, rounded to the nearest integer.
8. Display the sorted list, 5 numbers per line.

Optional Clallenges: XD
/************************************************************************************************
1. Display the numbers ordered by column instead of by row.
2. Use a recursive sorting algorithm (e.g., Merge Sort, Quick Sort, Heap Sort, etc.).
3. Implement the program using floating-point numbers and the floating-point processor.
4. Generate the numbers into a file; then read the file into the array. 
************************************************************************************************/
&

.386; Identify this as 32 - bit program
.model flat, stdcall; Selects the program's memory model(flat)
.stack 4096; how many bytes of memory to reserve

; Assembly Language for x86 Processors Seventh Editon KIP R.IRVINE
; Chapter 3.2 p.63 - p.65

INCLUDE Irvine32.inc
INCLUDE io.inc
INCLUDE core_alg.inc

;/**********************
;* Constant numbers
;***********************/
.const

min = 16
max = 256

lo = 64
hi = 1024


.data

array     DWORD max DUP(0)                
request   DWORD ?    

;/*MESSAGES*/

m_intro   BYTE "Author: Satoru Yamamoto", 0dh, 0ah
          BYTE "Sorting Random Integers",0

m_inst    BYTE "This program generates random numbers in the range [64, 1024], displays the original",0dh,0ah
          BYTE "list, sorts the list, and calculates the median value and the average value. Finally",0dh,0ah
          BYTE "it displays the list sorted in descending order.",0

input_M   BYTE "How many numbers should be generated? [16, 256]: ",0
valid_M   BYTE "OK!",0
error_M   BYTE "Invalid input",0
unsort_M  BYTE "The unsorted random numbers:",0
sort_M    BYTE "The sorted list:",0
median_M  BYTE "The median is ",0
ave_M     BYTE "The average is ",0

.code

main PROC
     
     ; Introduction 
     push      OFFSET m_intro
     push      OFFSET m_inst
     call      Introduction

     ; Get_data 
     push      OFFSET input_M
     push      OFFSET valid_M
     push      OFFSET error_M
     push      min
     push      max
     push      OFFSET request
     call      Get_data
     
     ; Fill_array
     push      lo
     push      hi
     push      request
     push      OFFSET array
     call      Fill_array

     
     ; Display_list unsorted
     push      OFFSET unsort_M
     push      request
     push      OFFSET array
     call      Display_list

     ; Sort_list
     push      request
     push      OFFSET array
     call      Sort_list


     ;Display_median
     push      OFFSET median_M
     push      request
     push      OFFSET array
     call      Display_median
     
     ;Display_average
     push      OFFSET ave_M
     push      request
     push      OFFSET array
     call      Display_average
     
     ; Display_list sorted
     push      OFFSET sort_M
     push      request
     push      OFFSET array
     call      Display_list
     
     
     exit                                              ;exit to operating system
main ENDP

END main