#Zeo Zhang 
#xzhan214
#CSE 12 Winter20 
#Lab 5: function and graphics
#objective: draw on bitmap

# Macro that stores the value in %reg on the stack 
#  and moves the stack pointer.

#move down sp by 4 byte
#store in sp
.macro push(%reg)
	subi $sp,$sp,4
	sw %reg, 0($sp)	
.end_macro 

# Macro takes the value on the top of the stack and 
#  loads it into %reg then moves the stack pointer.

#pop out the word current sp has
#move up the sp by 4
.macro pop(%reg)
	lw %reg,0($sp)
	addi $sp,$sp,4
.end_macro

# Macro that takes as input coordinates in the format
# (0x00XX00YY) and returns 0x000000XX in %x and 
# returns 0x000000YY in %y

#shift right input so xx is on the first 2 positions
#AND input with 0x000000FF to get what is YY

.macro getCoordinates(%input %x %y)
	srl %x, %input,16
	and %y,%input,255
.end_macro

# Macro that takes Coordinates in (%x,%y) where
# %x = 0x000000XX and %y= 0x000000YY and
# returns %output = (0x00XX00YY)

#shift left 4 to make X on 0x00XX0000
#put Y on first 2 position by OR 
.macro formatCoordinates(%output %x %y)
	sll %x,%x,16
	or %output,%x,%y
.end_macro 

#macro that compare two reg, if s<b
#output=1 
#output=0 set it to -1
.macro compare(%out %s %b)
	sle %out %s %b 
	beq %out, 1,correct
	li %out,-1
correct:
.end_macro 

.data
originAddress: .word 0xFFFF0000

.text
j done
    
    done: nop
    li $v0 10 
    syscall

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  Subroutines defined below
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#*****************************************************
# clear_bitmap:
#  Given a clor in $a0, sets all pixels in the display to
#  that color.	
#-----------------------------------------------------
# $a0 =  color of pixel
#*****************************************************
#store originAddress to t1
#for loop: 
#store coloer to t1
#t1+4 
#back to for if t1<=last position
clear_bitmap: nop
	lw $t1, originAddress
for:	sw $a0,($t1)
	addi $t1,$t1,4
	ble $t1,0xFFFFFFFC,for
	jr $ra
	
#*****************************************************
# draw_pixel:
#  Given a coordinate in $a0, sets corresponding value
#  in memory to the color given by $a1
#  [(row * row_size) + column] to locate the correct pixel to color
#-----------------------------------------------------
# $a0 = coordinates of pixel in format (0x00XX00YY)
# $a1 = color of pixel
#*****************************************************
# get the x and y position from a0
# (y*128 + x)*4+originAddress to locate the location of tehe coordinate
#store the color into that position
draw_pixel: nop
	lw $t3, originAddress
	getCoordinates($a0 $t0 $t1)
	sll $t2,$t1,7
	add $t2,$t2,$t0
	sll $t2,$t2,2
	add $t2,$t2,$t3
	sw  $a1,($t2)
	jr $ra
#*****************************************************
# get_pixel:
#  Given a coordinate, returns the color of that pixel	
#-----------------------------------------------------
# $a0 = coordinates of pixel in format (0x00XX00YY)
# returns pixel color in $v0	
#*****************************************************
# get x ad y from a0
# (y*128 +x)*4 +originAddress to get location of that pixel
# load the value of color from that pixel
get_pixel: nop
	lw $t3, originAddress
	getCoordinates($a0,$t0,$t1)
	sll $t2,$t1,7
	add $t2,$t2,$t0
	sll $t2,$t2,2
	add $t2,$t2,$t3
	lw $v0, ($t2)
	jr $ra
	

#***********************************************
# draw_line:
#  Given two coordinates, draws a line between them 
#  using Bresenham's incremental error line algorithm	
#-----------------------------------------------------
# 	Bresenham's line algorithm (incremental error)
# plotLine(int x0, int y0, int x1, int y1)
#    dx =  abs(x1-x0);
#    sx = x0<x1 ? 1 : -1;
#    dy = -abs(y1-y0);
#    sy = y0<y1 ? 1 : -1;
#    err = dx+dy;  /* error value e_xy */
#    while (true)   /* loop */
#        plot(x0, y0);
#        if (x0==x1 && y0==y1) break;
#        e2 = 2*err;
#        if (e2 >= dy) 
#           err += dy; /* e_xy+e_x > 0 */
#           x0 += sx;
#        end if
#        if (e2 <= dx) /* e_xy+e_y < 0 */
#           err += dx;
#           y0 += sy;
#        end if
#   end while
#-----------------------------------------------------
# $a0 = first coordinate (x0,y0) format: (0x00XX00YY)
# $a1 = second coordinate (x1,y1) format: (0x00XX00YY)
# $a2 = color of line format: (0x00RRGGBB)
#***************************************************
#Pseudo Code was given
#points to be careful: color in a2 draw pixel's color is in a1
#do not overwrite everyone they are all useful
draw_line: nop
	push($s0)
	getCoordinates($a0,$t0,$t1)			#t0=x0 t1=y0
	getCoordinates($a1,$t2,$t3)			#t2=x1 t3=y1
	move $a1,$a2
	compare($t4,$t0,$t2)					#if x1<x0 t4=-1
	sub $t5,$t2,$t0					#t5=x1-x0
	mul $t5,$t5,$t4				#if x1<x0 t5*-1(abs)
	compare($t7,$t1,$t3)					#if y0<y1 t7=1
	sub $t6,$t3,$t1					#t6=y1-y0
	mul $t6,$t6,$t7				#if y0<y1 t6>0 so *-1
	mul $t6,$t6,-1
	add $s0,$t5,$t6					#s0=error
	push($ra)
draw:   
	push($t1)
	push($t2)
	push($t3)
	formatCoordinates($a0,$t0,$t1)
	jal draw_pixel
	pop($t3)
	pop($t2)
	pop($t1)
	bne $t0,$t2,next
	beq $t1,$t3,end
next:	mul $t8,$s0,2					#e2=e*2
	blt $t8,$t6,if					#e2<dy then next if
	add $s0,$s0,$t6
	add $t0,$t0,$t4
	j draw
if: 	bgt $t8,$t5,end					#e2>dx end
	add $s0,$s0,$t5
	add $t1,$t1,$t7
	j draw
end:	pop($ra)
	pop($s0)
	jr $ra
	
#*****************************************************
# draw_rectangle:
#  Given two coordinates for the upper left and lower 
#  right coordinate, draws a solid rectangle	
#-----------------------------------------------------
# $a0 = first coordinate (x0,y0) format: (0x00XX00YY)
# $a1 = second coordinate (x1,y1) format: (0x00XX00YY)
# $a2 = color of line format: (0x00RRGGBB)
#***************************************************
#get x0y0 x1y1 from a0 and a1
#for(y0<=y1){
#x0y0 to x1y0
#y0+1
#}
draw_rectangle: nop
	push($ra)
	getCoordinates($a0,$t0,$t1)
	getCoordinates($a1,$t2,$t3)
draw_rec:
	push($t0)
	push($t2)
	push($t3)
	push($t1)
	formatCoordinates($a0,$t0,$t1)
	formatCoordinates($a1,$t2,$t1)
	pop($t1)
	add $t1,$t1,1
	push($t1)
	jal draw_line
	pop($t1)
	pop($t3)
	pop($t2)
	pop($t0)
	bgt $t1,$t3,end_rec
	j draw_rec
	
end_rec:
	pop($ra)
	jr $ra
	
#*****************************************************
#Given three coordinates, draws a triangle
#-----------------------------------------------------
# $a0 = coordinate of point A (x0,y0) format: (0x00XX00YY)
# $a1 = coordinate of point B (x1,y1) format: (0x00XX00YY)
# $a2 = coordinate of traingle point C (x2, y2) format: (0x00XX00YY)
# $a3 = color of line format: (0x00RRGGBB)
#-----------------------------------------------------
# Traingle should look like:
#               B
#             /   \
#            A --  C
#***************************************************	
#a0-a1 a0-a2 a1-a2
# store(push all the value into stack)
#drawline color in a2 move a3 to a2
#pop C's value A still on a0 a0-a2
#pop C's value to a1 B's value to a0

draw_triangle: nop
	push($ra)
	push($a1)			#3 B's place
	push($a0)
	push($a2)			#1 C's place
	move $a2,$a3			# a2=color
	jal draw_line			#A--B
	pop($a1)			#1 a1=C's place
	pop($a0)
	push($a1)			#2 store C's place again
	jal draw_line			#A--C
	pop($a1)			#2 a1=C's place
	pop($a0)			#3 B's place
	jal draw_line			#B--C
	pop($a3)
	pop($ra)
	jr $ra	
	
	
	
