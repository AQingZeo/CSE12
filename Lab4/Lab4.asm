#Zeo Zhang
#Lab 4:Syntax checker
#Winter 2020 CSE 12
#description: thtis program will print out number of pairs a file has with program argument input. If will also print out mismtach 
#if there is a mimatch paris and it will also print on stack on matched opening braces. 
################################
#PsedoCode:
#load program argument in temporary register t0
#load first byte of the argument into t1
#print the welcome sentence and file name
#check if the ascii code in t1 smaller than A, if do invalid
#check if the ascii code in t1 larger than z, if do invalid
#check if the ascii code in t1 smaller than Z, if do check length
#check if the ascii code in t1 greater than a, if do check length
#invalid
#check length:
#load the 20th byte of t0
#check if the byte contain 0(null), if not invalid
#open the file with syscall 13
#set a1 and a2 to 0 (read mode)
#set a0 with address of the file
#put v0’s value to t2(t2 holds the file descriptor)
#set t3 index counter to 0
#read:
#read the file with syscall 14
#set a0 to t2 (file descriptor)
#set a1 to buffer
#set a2 to 128 byte
#store v0’s value(number of byte read) in t2
#set t7 as the number of byte will be read to 0
#
#store and read value:
#see if t7=t2(number of byte read from buffer) if do, jump back to read
#sp-4
#store the first stack address to s2
#load byte from a1 to s0 
#jump to check if byte=open brace go back here
#store byte s0 to sp
#store the index t3 to sp-4
#if check not brace go back here
#t3+1(index+1)
#a1+1(byte read+1)
#t7+1(number of byte counter +1)
#see if t2<128byte if do, jump to summarize(last)
#jump back to store and read value
#
#check:
#check if s0=(,yes, jump to ra
#check if s0=[,yes, jump to ra
#check if s0=},yes, jump to ra
#check if s0=),yes, jump to pop1
#check if s0=],yes, jump to pop2
#check if s0=},yes, jump to pop3
#jump to (if check not brace go back here)
##
#pop1:
#see if sp+8=(,not, j errorm
#s1+1(s1=pair counter)
#j (if check not brace go back here)
#pop2:
#see if sp+8=[,not, j errorm
#s1+1(s1=pair counter)
#j (if check not brace go back here)
#pop3:
#see if sp+8={,not, j errorm
#s1+1(s1=pair counter)
#j (if check not brace go back here)
#if sp=s2 success
#print still on stack
#set t0=8
#print:
#sp+=t0
#print sp
#t0+8
#see if sp=s2, yes, exit
#j print
#

#success:
#print success 
#print s1
#exit
#errorm:
#print mismatch
#print sp+8 
#print at index
#print sp+4
#print s0
#print at index
#print t3+1





.text
.globl main
main:
li $t3,0			#t3=index number
li $s1,0			#s2=pair counter

lw $t0,($a1) 			#load the filename to t0
lb $t1,($t0)			#load firsts charactor of filename to t1

li $v0,4			#print welcome sentence"you entered"
la $a0,welcome
syscall
li $v0,4			#print the argument
move $a0,$t0
syscall

#check first charactor
blt $t1,'A',invalid		#check if the first charactor is a letter
bgt $t1,'z',invalid
ble $t1,'Z',valid
bge $t1,'a',valid
j invalid
lw $t4,($t0)
li $t7,0
valid:				#check length			
lb $t4,($t0)			#load the char into t4
addi $t7,$t7,1			#t7 as a characters counter
addi $t0,$t0,1
bge $t7,21,invalid		#since the last null will also be stored, t7>20 will lead to invalid
beq $t4,0,open
beq $t4,'.',valid
beq $t4,'_',valid
blt $t4,'0',invalid
bgt $t4,'z',invalid
ble $t4,'9',valid
blt $t4,'A',invalid
ble $t4,'Z',valid
bge $t4,'a',valid		#check if the filename just include 0-9 a-z A-Z .and_


open:				#open the file entered
sub $t0,$t0,$t7			#change t0 to start of the file
li $v0,13
move $a0,$t0			#t0 hold the address of the file
add $a1,$0,$0			#set to read mode
add $a2,$0,$0
syscall
add $t5,$v0,$0			#t2 = file discriptor (return value of v0)


read:
li $v0,14			#read the file
add $a0,$t5,$0			#a0=file discriptor
la $a1,buffer			#a1 holds the buffer address
addi $a2,$a2,128		#set read range to 128
syscall
add $t2,$v0,$0			#t2 stores the number of byte read
ble $t2,0,last
add $t7,$0,$0			#set number of byte counter to 0
addi $sp,$sp,-4
la $s2,($sp)			#s2 contain the first stack address
store:
lb $s0,($a1)			#load the first byte
jal check
sb $s0,($sp)			#store the brace to first stack place
addi $sp,$sp,-4	
sb $t3,($sp)			#store index to the next one
addi $sp,$sp,-4	
counter:
addi $t3,$t3,1			#index+1
addi $a1,$a1,1			#buffer read next byte	
addi $t7,$t7,1
bgt $t7,$t2,read		#reach end of buffer jump to read another 128 bytes
j store

exit:				#exit the program
li $v0,10
syscall

invalid:			#print invalid filename sentence
li $v0,4
la $a0,inval
syscall
j exit


jump:
jr $ra

check:				#check the byte is a brace
beq $s0,0,last			#if the byte is null, reach the end , go to summarize(last)
beq $s0,'(',jump
beq $s0,'[',jump
beq $s0,'{',jump		#if it is opening ones, jump back to store the brace and index
beq $s0,')',popy
beq $s0,']',popf
beq $s0,'}',popd		#is it is a closing brace, jump to pop(one each type of brace)
j counter			#if all chek fail, just go back to counter Xstore

popy:				#to check if this byte is a )
lb $t1, 8($sp)
bne $t1,'(',errorm
addi $s1,$s1,1
addi $sp,$sp,8
j counter

popf:				#to check if this byte is a ]
lb $t1, 8($sp)
bne $t1,'[',errorm
addi $s1,$s1,1
addi $sp,$sp,8
j counter

popd:				#to check if this byte is a }
lb $t1, 8($sp)
bne $t1,'{',errorm
addi $s1,$s1,1
addi $sp,$sp,8
j counter

last:				#summarize
beq $sp,$s2,success		#nothing on stack then success
li $v0,4
la $a0,stack
syscall 
print:				#if not, print opening brace on stack
addi $sp,$sp,8
li $v0,4
la $a0,($sp)
syscall

bne $sp,$s2,print
li $v0,4
la $a0,newl
syscall
j exit

success:			#print success sentence
li $v0, 4
la $a0,yeah
syscall
li $v0,1
addi $a0,$s1,0			#s1, counter of pairs
syscall
li $v0, 4
la $a0,yeah0
syscall
j exit

errorm:				#print mismatch
li $v0,4
la $a0,mismatch
syscall

beq $sp,$s2,end			#if nothing on stack, only print mismatch of a close one
la $a0,8($sp)			#get the open brace
li $v0,4
syscall

li $v0,4
la $a0,atindex
syscall

lb $t1,4($sp)			#get the index of open brace
li $v0,1
move $a0,$t1
syscall
li $v0,4
la $a0,sps
syscall
end:
li $v0,4
la $a0,($a1)			#print the current close brace
syscall

li $v0,4
la $a0,atindex
syscall
#addi $t3,$t3,1			#index of this mismatch closing one is index counter+1
li $v0,1
move $a0,$t3
syscall
li $v0,4
la $a0,newl
syscall
j exit





.data 
buffer:.space 128
welcome:.asciiz "You entered the file:\n"
inval:.asciiz "\n\nERROR: Invalid program argument.\n"
stack:.asciiz "\n\nERROR - Brace(s) still on stack: "
yeah:.asciiz "\n\nSUCCESS: There are "
yeah0:.asciiz " pairs of braces.\n"
newl:.asciiz "\n"
mismatch:.asciiz "\n\nERROR - There is a brace mismatch: "
atindex: .asciiz " at index "
sps: .asciiz " "
