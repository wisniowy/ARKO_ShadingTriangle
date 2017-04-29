		.data
		.align 4
size:		.space 4	# file size (in bytes)
width:		.space 4	# width 
height:		.space 4	# height 
offset:		.space 4	# offset 
bufor:		.space 4	
x1:		.space 4
y1:		.space 4
padding:	.space 4
descriptor:	.space 4
beginning:	.space 4
zeropadding:	.space 4
tmpred:		.space 1
tmpgreen:	.space 1
tmpblue:	.space 1
red1:		.space 1
green1:		.space 1
blue1:		.space 1
red2:		.space 1
green2:		.space 1
blue2:		.space 1

file:		.asciiz "in.bmp"
output:		.asciiz "out.bmp"
error:		.asciiz "Blad otwarcia pliku\n"
promptX:	.asciiz "Podaj wspolrzedna x (domyslnie 1-400):\n"	
promptY:	.asciiz "Podaj wspolrzedna y (domyslnie 1-400):\n"	
promptR:	.asciiz "Podaj R:\n"	
promptG:	.asciiz "Podaj G:\n"	
promptB:	.asciiz "Podaj B:\n"	
spacja:		.asciiz " "
		.text
		.globl main

			### loading coordinates and colors of vertices (x,y) ###			
main:
			### loading the file ###
				
wczytywanie_pliku:
	li $v0, 13		# opening a file, loading file descriptor to v0
	la $a0, file		# file's name
	li $a1, 0		# flaga, 0 - read-only, 1 - write-only
	li $a2, 0
	syscall
	
	move $t5, $v0		#t 5 = file descriptor
	bltz $t5, open_failure 
	
	##################################
	
	li $v0, 14		# loading from file
	move $a0, $t5		# loading 2 first bytes
	la $a1, bufor
	li $a2, 2		# loading 2 bytes
	syscall			
	
	li $v0, 14
	move $a0, $t5
	la $a1, size
	li $a2, 4		# loading 4 bytes
	syscall			# loading file size to size
	lw $s4, size		# s4 = size
	
	li $v0, 9
	move $a0, $s4		# copying file size to a0 register
	syscall			# allocation memory for bitmap
	move $s5, $v0		# copying addres of allocated memory to s5 register 
	
	li $v0, 14
	move $a0, $t5		# shifting 4 reserved bytes 
	la $a1, bufor
	li $a2, 4
	syscall
	
	li $v0, 14
	move $a0, $t5
	la $a1, offset
	li $a2, 4		# loading 4 offset bytes 
	syscall
	
	li $v0, 14
	move $a0, $t5		# shifting 4 bytes of DIB header 
	la $a1, bufor
	li $a2, 4		# loading 4 bytes 
	syscall
	
	li $v0, 14		# loading from a file 
	move $a0, $t5		# copying file descriptor to a0 
	la $a1, width
	li $a2, 4		# loding 4 bytes 
	syscall
	
	lw $t6, width
	
	li $v0, 14
	move $a0, $t5		# copying file descriptor to a0 
	la $a1, height
	li $a2, 4		# loding 4 bytes 
	syscall
	
	lw $s6, height
	
	move $a0, $t5		# copying file descriptor to a0 
	li $v0, 16		# closing a file 
	syscall			# we are closing a file to set reading pointer on the beginning
	
kopiowanie_pliku_do_pamieci:
	li $v0, 13		# opening a file 
	la $a0, file
	li $a1, 0		# opening flag is 0 to read from a file
	li $a2, 0
	syscall			# v0 contains file desctriptor 
	
	move $t5, $v0		# copying descriptor to t5 register 
		
	bltz $t5, open_failure 	# jump to open_failure if loading has not succeed
	
	li $v0, 14
	move $a0, $t5
	la $a1, ($s5)		# allocated memory address adres 
	sw $s5, descriptor
	la $a2, ($s4)		# loading that much bytes that we have in file size 
	syscall
	
	move $a0, $t5
	li $v0, 16		# closing a file 
	syscall
	
				# Setting t9 pointer to the beggining of pixels array.
	lw $t9, offset		# s5 contains address of the bmp file beggining
	addu $t9, $s5, $t9	# and offset shifts t9 pointer to beggining of pixels array 
	mul $t8, $t6, 0x3
	li $s4, 0x4
	div $t8, $s4
	mfhi $t8		# t8 = padding (in bytes)
	beqz $t8, zerowy_padding
	li $s4, 4
	sub $t8, $s4, $t8

zerowy_padding:
	mul $t6, $t6, 0x3	# s6 = width * 3
	add $t6, $t6, $t8	# plus padding => t6 = number of bytes in one line 
	sw $t6, zeropadding
	
drawing:	
	li $t3, 0		#counter2 = 0
	
			### load (x1,y1) and (x2,y2) to temporary variables ###
			
	li $v0, 4
	la $a0, promptX
	syscall
	li $v0, 5
	syscall
 	move $t1, $v0		
	sw $t1, x1		#store x1
	
	li $v0, 4
	la $a0, promptY
	syscall
	li $v0, 5
	syscall
	move $s1, $v0		
	sw $s1, y1		#store y1 
	
	li $v0, 4
	la $a0, promptR
	syscall
	li $v0, 5
	syscall
	sb $v0, red1		
	sb $v0, tmpred
	
	li $v0, 4
	la $a0, promptG
	syscall
	li $v0, 5
	syscall
	sb $v0, green1
	sb $v0,	tmpgreen
	
	li $v0, 4
	la $a0, promptB
	syscall
	li $v0, 5
	syscall
	sb $v0, blue1
	sb $v0, tmpblue
	
	li $v0, 4
	la $a0, promptX
	syscall
	li $v0, 5
	syscall
	move $t2, $v0	
	
	li $v0, 4
	la $a0, promptY
	syscall
	li $v0, 5
	syscall
	move $s2, $v0		
	
	li $v0, 4
	la $a0, promptR
	syscall
	li $v0, 5
	syscall
	sb $v0, red2		
	
	li $v0, 4
	la $a0, promptG
	syscall
	li $v0, 5
	syscall
	sb $v0, green2
	
	li $v0, 4
	la $a0, promptB
	syscall
	li $v0, 5
	syscall
	sb $v0, blue2
			
			### setting t9 on (x1, y1) position ###
			
	subi $t5, $s1, 1	#t5 = roznica y1 - 1 
	mul $s4, $t6, $t5
	add $t9, $t9, $s4
	subi $s4, $t1, 1	#x1 - 1
	mul $s4, $s4, 3		#...razy 3
	add $t9, $t9, $s4	#t9 = pixel (x1, y1)	

loop3:
			### calculating |XiXj| length ###
			
	lw $t6, zeropadding
	move $s5, $t2
	sub $t4, $t2, $t1  	# x2-x1
	sub $s3, $s2, $s1  	# y2-y1
	
	mul $t4, $t4, $t4 	# (x2-x1)^2
	mul $s3, $s3, $s3  	# (y2-y1)^2

	add $t4, $t4, $s3  	# (x2-x1)^2 + (y2-y1)^2
	
	sll $t4, $t4, 4
   			
   			### sqrt of (x2-x1)^2 + (y2-y1)^2 ###
   			
  	move $s3, $t4 		# x
	li $t7, 0 		# i
   	sra $s4, $t4, 1 	# t2 = n/2
	bge $t7, $s4, sqrtend
	
sqrtloop:
    	sll $t0, $t4, 4
    	div $t0, $t0, $s3
   	add $s3, $s3, $t0
  	sra $s3, $s3, 1
   	
   	addi $t7, $t7,  16
  	blt $t7, $s4, sqrtloop
  
sqrtend:

    	sra $s3, $s3, 4		# s3 = |XiYi| - length
    
  			### The Bresenham Line-Drawing Algorithm ###
  			
	 #  if (x1 <= x2) #
	ble $t1, $t2, then1      
	li $s6, -3		# if (x1 <= x2)(else case) kx = -3 (shift pixel left)
	b endif1
then1:
	li $s6, 3		# if (x1 <= x2)(then case) kx = 3 (shift pixel right)
	
endif1:
	#  if (y1 <= y2) #
	ble $s1, $s2, then2      
	sub $s7, $zero, $t6	# if (y1 <= y2)(else case) ky = -zero_padding (shift pixel down)
	b endif2
then2:
	add $s7, $zero, $t6	# if (y1 <= y2)(then case) ky = zero_padding (shift pixel up)

endif2:

	sub $t5, $t2, $t1	# dx = x2 - x1
	abs $t5, $t5		# |dx|
	
	sub $s0, $s2, $s1	# dy = y2 - y1
	abs $s0, $s0 		# |dy|
	

	li $t7, 0 		# counter = 0
	
	# if(dx<dy) #
	blt $t5, $s0, then5   
	
	# if(dx<dy)(else case) loop1
	move $t0, $t1		# actual y
	div $t4, $s6, $s6
	srl $s4, $t5, 1		# e = dx/2 
	
	
	# do-while loop1 condition
	bge $t7, $t5, end_loops

loop1:	
	# do
	li $t8, 1
	add $t9, $t9, $s6        # p + kx 
	add $t0, $t0, $t4
	sub $s4, $s4, $s0        # e - dy 
	
	# if(e>=0) #
	bgez $s4, then6	 
	# if(e>=0)(else case)
	add $t9, $t9, $s7        # p + ky
	add $s4, $s4, $t5        # e + dx
	
	
then6:	#(then case)
	sub $t2, $t1, $t0	# xi - actual
	abs $t2, $t2 		# |xi - actual|
	sll $t2, $t2, 8
	div $t2, $t2, $t5 	# |xi - actual|/dx
	sll $s3, $s3, 8
	mul $t2, $t2, $s3	# |xi - actual|/dx  * |XiYi|
	sra $s3, $s3, 8
	sra $t2, $t2, 16
	
	sll $t2, $t2, 8
	div $t2, $t2, $s3	# t = |Xi actualpoint| / |XiYi|
	sll $t8, $t8 , 8
	sub $t8, $t8, $t2	# 1-t 
	
	
			### Interpolation Pij = Pi * t + Pj ( 1 - t ) for each color ###
	# blue
	lbu $t6, blue2
	sll $t6, $t6, 8
	mul $t6, $t2, $t6
	sra $t6, $t6, 16
	lbu $s1, blue1	
	sll $s1, $s1, 8
	mul $s1, $t8, $s1
	sra $s1, $s1, 16
	add $t6, $t6, $s1
	sb $t6, ($t9)		
	addi $t9, $t9, 1	
	
	# green
	lbu $t6, green2
	sll $t6, $t6, 8
	mul $t6, $t2, $t6
	sra $t6, $t6, 16
	lbu $s1, green1	
	sll $s1, $s1, 8
	mul $s1, $t8, $s1
	sra $s1, $s1, 16
	add $t6, $t6, $s1
	sb $t6, ($t9)	
	addi $t9, $t9, 1
	
	# red 
	lbu $t6, red2
	sll $t6, $t6, 8
	mul $t6, $t2, $t6
	sra $t6, $t6, 16
	lbu $s1, red1	
	sll $s1, $s1, 8
	mul $s1, $t8, $s1
	sra $s1, $s1, 16
	add $t6, $t6, $s1
	sb $t6, ($t9)	
	subi $t9, $t9, 2	
        
        addi $t7, $t7, 1	# counter++
        
        # while
        blt $t7, $t5, loop1	# if(counter<dx)(then case) jump to loop1
        b end_loops		# if(counter<dx)(else case) end loop1
        
then5:	# if(dx<dy)(then case) loop2
	move $t0, $t2		# actual x
	div $t4, $s7, $s7
	srl $s4, $s0, 1		# e = dy/2 
	
	# do-while loop2 condition
	
	bge $t7, $s0, end_loops
loop2:
	#do
	li $t8, 1
	add $t9, $t9, $s7       # p + ky
	add $t0, $t0, $t4
	sub $s4, $s4, $t5       # e - dx
	
	# if(e>=0)
	bgez $s4, then7
	# if(e>=0)(else case)
	add $t9, $t9, $s6 	# p + kx 
	add $s4, $s4, $s0       # e + dy
	
then7:	# if(e>=0)(then case)
	sub $t1, $t2, $t0	# yi - actual
	abs $t1, $t1 		# |yi - actual|
	sll $t1, $t1, 8
	div $t1, $t1, $s0 	# |yi - actual|/dy
	sll $s3, $s3, 8
	mul $t1, $t1, $s3	# |yi - actual|/yx  * |XiYi|
	sra $s3, $s3, 8
	sra $t1, $t1, 16	# |Xi actualpoint|
	
	sll $t1, $t1, 8
	div $t1, $t1, $s3	# t = |Xi actualpoint| / |XiYi|
	sll $t8, $t8 , 8
	sub $t8, $t8, $t1	# 1-t 
	
			### Interpolation Pij = Pi * t + Pj ( 1 - t ) for each color ###
	
	#blue
	lbu $t6, blue2
	sll $t6, $t6, 8
	mul $t6, $t1, $t6
	sra $t6, $t6, 16
	lbu $s1, blue1	
	sll $s1, $s1, 8
	mul $s1, $t8, $s1
	sra $s1, $s1, 16
	add $t6, $t6, $s1
	sb $t6, ($t9)		
	addi $t9, $t9, 1	
	
	#green
	lbu $t6, green2
	sll $t6, $t6, 8
	mul $t6, $t1, $t6
	sra $t6, $t6, 16
	lbu $s1, green1	
	sll $s1, $s1, 8
	mul $s1, $t8, $s1
	sra $s1, $s1, 16
	add $t6, $t6, $s1
	sb $t6, ($t9)		
	addi $t9, $t9, 1
	
	#red
	lbu $t6, red2
	sll $t6, $t6, 8
	mul $t6, $t1, $t6
	sra $t6, $t6, 16
	lbu $s1, red1	
	sll $s1, $s1, 8
	mul $s1, $t8, $s1
	sra $s1, $s1, 16
	add $t6, $t6, $s1
	sb $t6, ($t9)	
	subi $t9, $t9, 2	
        addi $t7, $t7, 1	# counter++
        
        # while
      
        blt $t7, $s0, loop2	# if(counter<dy)(then case) jump to loop2
       				# if(counter<dy)(else case) end loop2
        
        
end_loops: 

	addi $t3, $t3, 1
	
	# if (counter2!=1) #
	bne $t3, 1, then8
	# if (counter2!=1)(else case)
	
			### load (x2,y2) and (x3,y3) to temporary variables ###
	lbu $t1, red2
	sb $t1, red1
	lbu $t1, green2
	sb $t1, green1
	lbu $t1, blue2
	sb $t1, blue1
		
	move $t1, $s5
	move $s1, $s2
	li $v0, 4
	la $a0, promptX
	syscall
	li $v0, 5
	syscall
 	move $t2, $v0		
	
	li $v0, 4
	la $a0, promptY
	syscall
	li $v0, 5
	syscall
	move $s2, $v0	
	
	li $v0, 4
	la $a0, promptR
	syscall
	li $v0, 5
	syscall
	sb $v0, red2		
	
	li $v0, 4
	la $a0, promptG
	syscall
	li $v0, 5
	syscall
	sb $v0, green2
	
	li $v0, 4
	la $a0, promptB
	syscall
	li $v0, 5
	syscall
	sb $v0, blue2
	
	b loop3
	
then8:	#if (counter2!=1)(then case)

 	#if (counter2!=2) #
 	bne $t3, 2, then9
	#if (counter2!=2)(else case)
	
	
			### load (x3,y3) and (x1,y1) to temporary variables ###
	lbu $t1, red2
	sb $t1, red1
	lbu $t1, green2
	sb $t1, green1
	lbu $t1, blue2
	sb $t1, blue1 
	
	lbu $t1, tmpred
	sb $t1, red2
	lbu $t1, tmpgreen
	sb $t1, green2
	lbu $t1, tmpblue
	sb $t1, blue2 
	
	move $t1, $s5
	move $s1, $s2
	
	lw $t2, x1
	lw $s2, y1
	
	b loop3
	
then9:	#if (counter2!=2)(then case) end loop3 
	
				### filling a triangle ###
	
	lw $s5, descriptor
	lw $t1, width
	lw $t6, zeropadding
	lw $t9, offset
	addu $t9, $t9, $s5
	li $s0, 0 
	li $t5, 0
	sw $t9, beginning
	
	# do-while loop8 condition
	bge $s0, $t1, end_of_line

loop8:	
	
	lbu $s1, ($t9)		
	addiu $t9, $t9, 1
	lbu $s2, ($t9)		
	addiu $t9, $t9, 1
	lbu $s3, ($t9)		
	subiu $t9, $t9, 2
	
	bne $s1, 255, foundfirst	# looking for first not-white pixel
	bne $s2, 255, foundfirst	# if found go looing for second
	bne $s3, 255, foundfirst	# if not found go to next line 
	
	add $t9, $t9, 3			# shift pixel right
	add $s0, $s0, 1 	
	
	bge $s0, $t1, end_of_line		# if(pixel_pos < width)(else case) end loop8
	b loop8				# if(pixel_pos < width)(then case) jump to loop8


	
foundfirst:				# if we found not-white pixel but next pixel is also not-white
	
	move $t7, $t9	
	sb $s1, blue1
	sb $s2, green1
	sb $s3, red1
	addi $s0, $s0, 1
	addi $t9, $t9, 3
	
	bge $s0, $t1, end_of_line
	
	lbu $s1, ($t9)		
	addiu $t9, $t9, 1
	lbu $s2, ($t9)		
	addiu $t9, $t9, 1
	lbu $s3, ($t9)		
	subiu $t9, $t9, 2
	
	bne $s1, 255, foundfirst	
	bne $s2, 255, foundfirst	
	bne $s3, 255, foundfirst	


	# do-while loop9 condition
	bge $s0, $t1, end_of_line
loop9:	
	lbu $s1, ($t9)		
	addiu $t9, $t9, 1
	lbu $s2, ($t9)		
	addiu $t9, $t9, 1
	lbu $s3, ($t9)		
	subiu $t9, $t9, 2
	
	bne $s1, 255, foundsecond	# looking for second not-white pixel
	bne $s2, 255, foundsecond	
	bne $s3, 255, foundsecond	
	
       	add $t9, $t9, 3
	add $s0, $s0, 1 
	
	bge $s0, $t1, end_of_line	# if(pixel_pos < width)(else case) end loop9
	b loop9				# if(pixel_pos < width)(then case) jump to loop9

foundsecond:
	move $t8, $t9
	sb $s1, blue2
	sb $s2, green2
	sb $s3, red2
	
		
fill: 
	move $t9, $t7
      
        subu $s3, $t8, $t7		#|XiYi|
        div $s3, $s3, 3


	# do-while loop10 condition
        bge $t9, $t8, end_of_line
loop10:  
        li $s6, 1
       
        sub $t2, $t9, $t7		#|Xi actualpoint|
      	div $t2, $t2, 3

        sll $t2, $t2, 8
	div $t2, $t2, $s3		# t = |Xi actualpoint| / |XiYi|
	sll $s6, $s6 , 8
	sub $s6, $s6, $t2		# 1-t 
	
	
			### Interpolation Pij = Pi * t + Pj ( 1 - t ) for each color ###
	#blue
	lbu $t6, blue2
	sll $t6, $t6, 8
	mul $t6, $t2, $t6
	sra $t6, $t6, 16
	lbu $s4, blue1	
	sll $s4, $s4, 8
	mul $s4, $s6, $s4
	sra $s4, $s4, 16
	add $t6, $t6, $s4
	sb $t6, ($t9)		
	addi $t9, $t9, 1	
	
	#green
	lbu $t6, green2
	sll $t6, $t6, 8
	mul $t6, $t2, $t6
	sra $t6, $t6, 16
	lbu $s4, green1	
	sll $s4, $s4, 8
	mul $s4, $s6, $s4
	sra $s4, $s4, 16
	add $t6, $t6, $s4
	sb $t6, ($t9)		
	addi $t9, $t9, 1
	
	#red 
	lbu $t6, red2
	sll $t6, $t6, 8
	mul $t6, $t2, $t6
	sra $t6, $t6, 16
	lbu $s4, red1	
	sll $s4, $s4, 8
	mul $s4, $s6, $s4
	sra $s4, $s4, 16
	add $t6, $t6, $s4
	sb $t6, ($t9)		
	subi $t9, $t9, 2	

	add $t9, $t9, 3
	
	bge $t9, $t8, end_of_line	# if(pixel_pos < width)(else case) end loop10
	b loop10			# if(pixel_pos < width)(then case) jump to loop10



end_of_line:
	lw $t6, zeropadding
	lw $t2, height
	lw $t9, beginning
	add $t5 ,$t5 ,1 
	
	bge $t5, $t2, end_of_file
	add $t9, $t9, $t6
	sw $t9, beginning
	
	
	li $t7, 0
	li $t8, 0
	li $s0, 1
	b loop8
	
end_of_file:

save_file:
	li $v0, 13			# opening a file
	la $a0, output
	li $a1, 1			# flag set on 1 - write-only
	li $a2, 0
	syscall				# v0 - file descriptor 
	
	move $t0, $v0			# copying descriptor to t0
	lw $t7, size
	
	bltz $t0, open_failure 
	
	li $v0, 15			# saving a file 
	move $a0, $t0
	la $a1, ($s5)			# saving data from s5 - beginning of a bmp file 
	la $a2, ($t7)			# loading that much bytes that we have in file size 
	syscall
	
	li $v0, 16			# closing a file 
	move $a0, $t0
	syscall
	
	b end
	
open_failure:
	li $v0, 4
	la $a0, error
	syscall

end:	
	li $v0, 10
	syscall
	

