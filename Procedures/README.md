## Objectives:
1) Designing and implementing procedures
2) Designing and implementing loops
3) Writing nested loops
4) Understanding data validation

## Problem Definition:
Write a program to calculate composite numbers.  First, the user is instructed to enter the number of
composites to be displayed, and is prompted to enter an integer in the range [1 .. 400].  The user
enters a number, n, and the program verifies that 1 ≤ n ≤ 400.  If n is out of range, the user is re-
prompted until s/he enters a value in the specified range.  The program then calculates and displays
all of the composite numbers up to and including the nth composite.  The results should be displayed
8 composites per line with at least 3 spaces between the numbers.

## Requirements:
1) The programmer’s name must appear in the output.
2) The counting loop (1 to n) must be implemented using the MASM loop instruction.
3) The main procedure must consist (mostly) of procedure calls. It should be a readable “list” of
what the program will do.
4) Each procedure will implement a section of the program logic, i.e., each procedure will specify
how the logic of its section is implemented.  The program must be modularized into at least the
following procedures and sub-procedures :
    * introduction
    * getUserData
        - validate
    * showComposites
        - isComposite
    * farewell
5) The upper limit should be defined and used as a constant.
6) Data validation is required.  If the user enters a number outside the range [1 .. 400] an error message should be displayed and the user should be prompted to re-enter the number of composites.
7) The usual requirements regarding documentation, readability, user-friendliness, etc., apply.

## Example (user input in italics):
```
Composite Numbers     Programmed by Euclid

Enter the number of composite numbers you would like to see.
I’ll accept orders for up to 400 composites.  Enter the number of composites to display [1, 400]:501
Out of range.  Try again.
Enter the number of composites to display [1, 400]: 0
Out of range.  Try again.
Enter the number of composites to display [1, 400]: 31

4    6    8    9    10   12   14   15
16   18   20   21   22   24   25   26
27   28   30   32   33   34   35   36
38   39   40   42   44   45   46

Results certified by Euclid.  Goodbye.
```