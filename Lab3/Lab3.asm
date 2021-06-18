#
# Created by: Zhang, Zeo
#	      xzhan214
#	      5 February 2019
#Assignment: Lab3: ASCII-risks
#	     CSE 12, Computer Systems and Assembly Language
#Description: This program prints a triangle with "user input" height.
# 
# Notes: This program is intended to be run from the MARS IDE
#Pseudo code:

##main:
#print sentence for input
#syscall
#get user input
#syscall
#put input into a register s0
#if smaller than 0, invalid
#if =0, exit
#set t0=s0                        #t0 as tab counter
#set t1=1                         #t1 line counter
#set t2=1	       		      #t2 number 
#
#tab:    # tab is to print tab as header of one line                    
#     if t0<=1 num           #since first to last line: tab(s0-1)to0
#     print a tab
#     syscall
#     t0-1
#     jump tab
# t3=t1                             #t3 number on line counter
#num:    #num is to print numbers on one line
#    print t2                        #print number 
#    syscall
#    t3-1                            #number of number-1
#    t2+1                            #value of number +1
#    if t3=1 jump back num
#    if t3=0 jump nln              #between 2 umber on same line there is tab*tab
#    print tab * tab
#    syscall
#    jump num
#nln:  #is to print new line and adjust new line number
#    print new line
#    syscall
#    t0=s0-t1
#    t1+1
#   if t1>s0 exit
#    jump tab
#exit:
#print program finished
#exit
#syscall
#invalid: 
#    print invalid sentence
#   syscall
#    jump back to start
.text
main: 
	li $v0, 4			#print welcome sentence
	la $a0, welcome
	syscall

	li $v0,5			#get user input
	syscall 
	move $s0, $v0

	blt $s0,1, invalid		#if input <0 print invalid

	add $t0, $s0, $zero		#store input into t0
	addi $t1,$zero, 1		#set t1=1 as line counter
	addi $t2,$zero,1		#set t2=1 as number will be printed
	add $t3, $t1,$zero		#set t3 as counter of number of numbers on one line
tab:
	beq $t0, 1, num			#if input=1 skip print tab just print number
	
	li $v0, 4			#print one tab
	la $a0, s_tab
	syscall

	addi $t0,$t0,-1			#the number of line-1
	j tab				#move back to tab to print next tab on one line
num:
	move $a0, $t2			#print the first number
	li $v0, 1
	syscall

	addi $t3, $t3,-1		#number of numbers will be print on the line-1
	addi $t2, $t2,1			#value of number +1

	beq $t3,$0,nln			#if there is no number be printed this line move to new line
	blt $t3,1, num			#if t3=1 skip print tab star tab 
	

	li $v0, 4			#print tab star tab
	la $a0, tabstar
	syscall
	
	j num				#print next number
nln:
	li $v0, 4			#print new line
	la $a0,line
	syscall

	sub $t0, $s0, $t1		#t0equals to number of lines remain (1.t0=input-1 2.t0=input-2 so on)
	addi $t1, $t1,1			#line count+1
	add $t3, $t1,$0			#number of numbers on line= which line it on (1st line 1 # 2nd line 2 #)
	blt $s0, $t1, exit		#if line counter=input finished just exit
	j tab
exit:
	li $v0, 10			#exit
	syscall
invalid:
	li $v0, 4			#print invalid 
	la $a0, s_invalid
	syscall
	j main				#jump back to welcome sentences
	

.data
welcome: .asciiz "Enter the height of the triangle (must be greater than 0): "
s_tab: .asciiz "\t"
tabstar: .asciiz "\t*\t"
line: .asciiz "\n"
s_invalid: .asciiz "Invalid entry!\n"

	
	

