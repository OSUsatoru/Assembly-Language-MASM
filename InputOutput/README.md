## Objectives:
1. Introduction to MASM assembly language
2. Defining variables (integer and string)
3. Using library procedures for I/O
4. Integer arithmetic
## Description:
Write and test a MASM program to perform the following tasks:
1. Display your name and program title on the output screen.
2. Display instructions for the user.
3. Prompt the user to enter two numbers.
4. Calculate the sum, difference, product, (integer) quotient and remainder of the numbers.
5. Display a terminating message.
## Requirements:
1. The main procedure must be divided into sections:
    * introduction
    * get the data
    * calculate the required values
    * display the results
    * say goodbye
2. The results of calculations must be stored in named variables before being displayed.
3. The program must be fully documented.  This includes a complete header block for identification,
description, etc., and a comment outline to explain each section of code.

## Example execution (user input is in italics):
```
Elementary Arithmetic
by Wile E. Coyote

Enter 2 numbers, and I'll show you the sum, difference,
product, quotient, and remainder.

First number: 37
Second number: 5

37 + 5 = 42
37 - 5 = 32
37 x 5 = 185
37 ÷ 5 = 7 remainder 2

Impressed?  Bye!
 ```