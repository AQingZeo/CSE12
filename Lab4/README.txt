Zeo Zhang
xzhan214
CSE12 Winter 2020

Lab 4: Syntax Checker

Description: 
In this program, it requires a program argument containing a text file to read from and will output numbers of pairs of braces the file has. If there is a mismatch or wrong numbers of opening or closing braces, the program will output an information about the mismatches. 

Files in the directory:
Lab4.asm
test1.txt
test2.txt
test3.txt

Instructions:
1.Program argument:
	the program argument should contain the name of the text file, for example, test.txt. Meanwhile, the target file should be in the same folder as MARs.jar
2.File name
	The file name should contain only 0-9 a-z, A-Z, underscore and period. The first letter can only be letter and the name cannot exceed 20 characters, or there would be an error called “invalid program argument”
3.EERORs:
	There are other 2 types of errors. 1. mismatch: If there is a pair of braces with different opening and closing one (for example (]), there would be a mismatch error showing the mismatch pair and their index in text. 2. On stack: Since the program is designed to check from left to right, if there are still opening braces on stack not paired with closing ones, the error message will printout all the opening ones on stack backward.	