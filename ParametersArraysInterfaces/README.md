## Objectives:
1. using register indirect addressing
2. passing parameters
3. generating “random” numbers
4. working with arrays
5. understanding interface design

## Description:
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

## Requirements:
1. The title, programmer's name, and brief instructions must be displayed on the screen.

2. The program must validate the user’s request.

3. min, max, lo, and hi must be declared and used as global constants.

4. Strings must be passed by reference.

5. In a lower level, the program must be constructed using procedures. At least the following procedures
are required:
    - main
    - introduction
    - get data {parameters: request (reference)}
    - fill array {parameters: request (value), array (reference)}
    - sort list {parameters: array (reference), request (value)}
        - exchange elements (for most sorting algorithms): {parameters: array[i] (reference),
        array[j] (reference), where i and j are the indexes of elements to be exchanged}
    - display median {parameters: array (reference), request (value)}
    - display average {parameters: array (reference), request (value)}
    - display list {parameters: array (reference), request (value), title (reference)}

6. In a higher level, the program must be constructed using modules. At least the following modules of
interfaces are required:
    - I/O
    - Core algorithms
7. Parameters must be passed by value or by reference on the system stack as noted above.

8. There must be just one procedure to display the list. This procedure must be called twice: once to
display the unsorted list, and once to display the sorted list.

9. Procedures (except main) should not reference .data segment variables by name. request, array, and
titles for the sorted/unsorted lists should be declared in the .data segment, but procedures must use them
as parameters.  Procedures may use local variables when appropriate.  Global constants are OK.

10. The program must use register indirect addressing for array elements.

11. The two lists must be identified when they are displayed (use the title parameter for the display
procedure).

12. The program must be fully documented. This includes a complete header block for the program and
for each procedure, and a comment outline to explain each section of code.

13. The code and the output must be well-formatted.

## Example (user input in italics): Sorting Random Integers
```
Programmed by Road Runner

This program generates random numbers in the range [64, 1024], displays the original
list, sorts the list, and calculates the median value and the average value. Finally,
it displays the list sorted in descending order.

How many numbers should be generated? [16, 256]: 9
Invalid input
How many numbers should be generated? [16, 256]: 16
OK!

The unsorted random numbers:
680 329 279 846 123
101 427 913 255 736
431 545 984 391 626
803

The median is 488.
The average is 529.

The sorted list:
984 913 846 803 736
680 626 545 431 427
391 329 279 255 123
101
```