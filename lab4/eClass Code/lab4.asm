.data     ## Data declaration
out_string1: .asciiz "\nProccesed string \n" ## String to be printed
out_string2: .asciiz "\nPlease Enter a Char\n" ## String to be printed

	UpercaseLowerBound: .word 65
	UpercaseUperBound: .word 90
	LowercaseLowerBound: .word 97
	LowercaseUperBound: .word 122
	NumbersLowerBound: .word 48
	NumbersUperBound: .word 57
	spaceCharacter: .word 32
	maxStringSize: .word 99			# String Max size

	
	TerminationChar: .byte  '@'		# String termination character
	TerminationCharAlt: .byte  '\n'		# String termination character


input: 	.align 2 
	.space 100
output: .align 2 
	.space 100		

.text 

main: 				## Start of code section 						
	move $t9, $0			# acts as a counter for total chars read.
	la $t3, input
	readChar:
		move $a1, $t3		# Arg1 : Store input address
		jal getString		# Call getString
	
		move $t0, $v0		# Store getString output : Word
		move $t1, $v1		# Store getString output : Word size
	
		move $a1, $v0		# set arg1: input word 	
		move $a2, $t3		# set arg2: input address
		jal saveString		# call saveString
		
		move $t2, $v0		# bytes saved
		move $t3, $v1		# new address
	
		add $t9, $t9, $t2	# adds number of chars read into counter
	
		la $t4, input		# Set $t4 as input
		add $t4, $t4, $t9	# point to last char + 1
		sub $t4, $t4, 1		# point to the last char
		lb $t4, ($t4)		# load last char

		lw $t5, maxStringSize		# load maxStringSize into $t5
		lb $t6, TerminationCharAlt	# load terminationChar into $t6

		# Break conditions		
		bge $t9, $t5, stopReading	# if we have filled the buffer, break
		beq $t4, $t6, stopReading	# if last char was term char, break
	j readChar				# loop while not break.

	stopReading:

	la $a1, input		# Load input as arg1 for process_string
	la $a2, output		# Load output as arg2 for process_string
	move $a3, $		# Load total chars as arg3 for process_string

	jal process_string	# Call process_string

	la $a0, out_string1	# load out_string for printing
	li $v0, 4 		# system call code for printing string
	syscall
	
	la $a0, output		# print output
	li $v0, 4 		# system call code for printing string
	syscall

	li $v0, 10 		# terminate program 
	syscall
				
# --- END OF PROGRAM --- #
				   
getString:
	add $sp, $sp, -4	# make room in the stack for $ra
	sw $ra, 0($sp)		# save return address to stack
	jal loadToStack		# load tx registers into stack

	move $t1, $a1		# set t1 to Arg1 : pointer to input string
	move $t2, $0 		# $t2 acts as a word indexer
	move $t3, $0		# $t3 acts as the word buffer
	
	lb $t9, TerminationChar
	
	while_loop:
	
		li $v0, 4 			# system call code for printing string = 4 
		la $a0, out_string2 		# load address of string to be printed into $a0 
		syscall 
		li $v0, 12			# Load system call [Reading a char]
		syscall
		
		move $t0, $v0			# get char to temp register
		
		bne $t0, $t9, AddToArray	# if char is not termination char, skip the following code
			li $t0, 0x0a		# load "\n" into t0
			#srl $t3,$t3,8		# shift $t1 right for one byte
			or $t3,$t3,$t0		# copy character to $t1
			add $t2, $t2, 1		# Increment index	
			j get_string_exit
	
		AddToArray:
		beqz $t2, Move			# if t2 == 0 goto Move
		j OR				# else, goto OR
		
		Move:
			move $t3, $t0		# copy 1st character to $t1
			j exit_if_else		# skip the OR
		OR:
			or $t3,$t3,$t0		# copy character to $t1
		exit_if_else:

		add $t2, $t2, 1			# Increment index	
		beq $t2, 0x04, get_string_exit	# if we have have 4 digits, goto exit
		#beq $v0, 0x64, get_string_exit	# if we have 100 bytes, stop.
	repeat:
	
	sll $t3,$t3,8			# shift word left for one byte		
										
	jal while_loop
	
	get_string_exit:
		move $v0, $t3		# Output : word
		move $v1, $t2		# Output : word size
	
		jal unloadFromStack	# Unload $t register from stack
		lw $ra, 0($sp)		# Load back original $ra
		add $sp, $sp, 4		# free $ra from the stack
		jr $ra			# Jump back
		
		
saveString:
	add $sp, $sp, -4	# make room in the stack for $ra
	sw $ra, 0($sp)		# save return address to stack
	jal loadToStack		# load tx registers into stack

	move $t1, $a1		# set $t1 to Arg1 : input word
	move $t2, $a2		# set $t2 to Arg2 : input address
	
	sw $t1, ($t2)		# store word from $t1 into the address pointed by $t2
	move $t1, $0		# reset $t1
		
	move $t4, $0		# reset $t4
	move $s0, $t2		# we copy the address of $t2 into $s0
	for_s0_t1_to_t2_loop:		# t1 holds the start of our data array, t2 holds the end.
		lw $s1, ($s0)		# load contents of #s0 into #s1
		move $s3, $0		# #s3 acts as an indexer for a for-loop
		for_s3_0_to_4_loop:
			andi $t6, $s1, 0xff	# load the first digits into t6
			bnez $t6, ifNotNull	# if t6 != 0x00, skip the following commands
				srl $t4, $t4, 8		# shift t4 back right.
				j for_s3_0_to_4_loop_end	# if (char == null) break
			ifNotNull:
			or $t4, $t4, $t6	# copy the t6 into t4
			beq $s3, 0x03, skip	# if index is 3, skip the following code
				sll $t4, $t4, 8		# shift t4 left 8 bits
				srl $s1, $s1, 8		# shift s1 right 8 bits
		skip:	
		addi $s3, $s3, 1		# increment index
		blt $s3, 0x04, for_s3_0_to_4_loop	# while ($s3 < 4), loop back
	for_s3_0_to_4_loop_end:
	
	sw $t4 0($s0)		# store contents of t4 into the address pointed by s0
	move $t4, $0		# reset t4
	
	addi $s0, $s0, 4	# move s0 to next word
	
	blt $s0, $t2, for_s0_t1_to_t2_loop	# while s0 < t2 -> loop
	
	save_string_exit:
	
		move $v0, $s3			# Output : bytes saved.
	
		bne $s3, 0x04, ifRegIsIncomplete	#if register is incomplete,skip the folowing code
			add $v1, $t2, 4		# Output : next input reg
			j exit_reg_complete_check
		ifRegIsIncomplete:
			move $v1, $t2		# Output : input reg
		exit_reg_complete_check:
			jal unloadFromStack	# Unload $t register from stack
			lw $ra, 0($sp)		# Load back original $ra
			add $sp, $sp, 4		# free $ra from the stack
			jr $ra			# Jump back

process_string:
	move $s7, $ra		# save return address
	jal loadToStack		# load tx registers into stack
	move $ra, $s7		# save return addres back to $ra

	move $t1, $a1		# set t1 to Arg1 : pointer to input string
	move $t2, $a2		# set t2 to Arg2 : pointer to output string
	#move $t3, $a3		# set t3 to Arg3 : input string size

	move $t3, $t1		# $t3 acts as pointer into the input array 
	move $t4, $0		# Reset $t4 for use as buffer
	move $t5, $0 		# Reset $t5 for use as buffer index
	move $t6, $t2		# $t6 acts as a pointer into the output array
	move $s1, $0		# $s1 acts as a numeric indexer of valid chars
	move $s2, $0		# $s2 acts as a numeric indexer of total chars
	

	for_s3_t1_to_t2_loop:
		lw $s3, ($t3)	# store word at s3		
		for_each_byte_loop:
			and $a1, $s3, 0xff	# store first byte into a1 as arg for performCheck
			
			lb $t7, TerminationCharAlt
			bne $a1, $t7, NotTermChar
				move $a1, $t4	# 1st arg, Word to add into array
				move $a2, $t6	# 2nd arg, Address of output
				jal addToOutput 
			NotTermChar:
		
			beqz $a1, for_s3_t1_to_t2_loop_end # if char is null, break loop

			jal performCheck
			move $s4, $v0	# store performCheck's output into $s4

			addi $s2, $s2, 1 	# increment index of total chars
			
			beqz $s4, invalidChar	# if char is invalid, goto invalidChar
				bnez $t5, buff_check
					move $t4, $s4
					j or_end
				buff_check:
					sll $t4, $t4, 8		# shift $t4 left 8 bits
					or $t4, $t4, $s4	# Add char to buffer
				or_end:
				addi $t5, $t5, 1	# increment buffer index
				
				bne $t5, 0x04, invalidChar	# if buffer is full, then save it
					move $a1, $t4	# 1st arg, Word to add into array
					move $a2, $t6	# 2nd arg, Address of output
					jal addToOutput
					
					addi $t6, $t6, 4	# increment output index
					move $t5, $0		# reset buffer index
					move $t4, $0		# reset buffer
										
				sll $t4, $t4, 8		# shift buffer by 8 bits
				
				addi $s1, $s1, 1	# increment index
			invalidChar:		
				add $s4, $0, 0x04		
				div $s2,$s4		# divide total index by 4
				mfhi $s4		# get remainder
				beqz $s4, for_each_byte_loop_end	# if remainder == 0 , get new word
			
				srl $s3, $s3, 8		# shift right to get new byte.
				j for_each_byte_loop
			
		for_each_byte_loop_end:
		add $t3, $t3, 4		# increment pointer of input array
		beq $t6, $t3, for_s3_t1_to_t2_loop_end
		j for_s3_t1_to_t2_loop	# Loop while char is not null
	for_s3_t1_to_t2_loop_end:
move $ra, $s7				
jr $ra
		
loadToStack:
# Loads al $tx registers into the stack
	add $sp, $sp, -40	# make room for 10 variables
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	sw $t5, 20($sp)
	sw $t6, 24($sp)
	sw $t7, 28($sp)
	sw $t8, 32($sp)
	sw $t9, 36($sp)
	
	jr $ra 		# return
	
unloadFromStack:
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	lw $t4, 16($sp)
	lw $t5, 20($sp)
	lw $t6, 24($sp)
	lw $t7, 28($sp)
	lw $t8, 32($sp)
	lw $t9, 36($sp)
	add $sp, $sp, 40	# make room for 10 variables
	
	jr $ra	# return

addToOutput:
	move $s0, $ra		# save return address
	jal loadToStack		# load tx registers into stack
	move $ra, $s0		# save return addres back to $ra

	move $t1, $a1		# set t1 to Arg1 : word to add to array
	move $t2, $a2		# set t2 to Arg2 : address of output array
	
	sw $t1, ($t2)		# store byte 

	move $s0, $ra		# save return address
	jal unloadFromStack	# load tx registers from the stack
	move $ra, $s0		# save return addres back to $ra
	
	jr $ra			# return

performCheck:
	move $s0, $ra		# save return address
	jal loadToStack		# load tx registers into stack
	move $ra, $s0		# save return addres back to $ra

	move $t1, $a1		# set t1 to Arg1 : char to perform checks on
	move $v0, $0		# set v0, to default out as 0x00 or null.

	lw $t2, UpercaseLowerBound      # Load UpercaseLowerBound into t2
	
	# Check if char is an Uppercase letter, if not goto nextCheck
	blt $t1, $t2, CheckLowerCase    # if char is not uppercase, goto CheckLowerCase
	lw $t2, UpercaseUperBound       # load UpercaseUperBound into t2
	bgt $t1, $t2, CheckLowerCase	# if char is not upercase, goto CheckLowerCase
	j insertToOutput                # if uppercase goto insertToOutput
		
	CheckLowerCase:
					  	# Check if char is a Lowercase letter, if not goto CheckIsNumber	
		lw $t2, LowercaseLowerBound	# Load LowercaseLowerBound into t2
		blt $t1, $t2, CheckIsNumber   

		lw $t2, LowercaseUperBound      # Load LowercaseUperBound into t2     
		bgt $t1, $t2, CheckIsNumber
		j insertToOutput                # If lowercase goto insertToOutput

	CheckIsNumber: 
						# Check if char is a number, if not goto CheckIfSpace	
		lw $t2, NumbersLowerBound       # Load NumbersLowerBound into t2
		blt $t1, $t2, CheckIfSpace         
		lw $t2, NumbersUperBound        # Load NumbersUperBound into t2
		bgt $t1, $t2, CheckIfSpace
		j insertToOutput                # If number goto insertToOutput

	CheckIfSpace:
						# Check if char is a space, if not, exit without inserting to output	
		lw $t2, spaceCharacter		# load spaceCharacter into t2
		beq $t1, $t2, insertToOutput	# if char is spaceCharacter, go to insertToOutput
		j performCheck_exit
				
	insertToOutput:
		move $v0, $t1
		#or $v0, $t1, 
	performCheck_exit:
		move $s0, $ra		# save return address
		jal unloadFromStack	# load tx registers from the stack
		move $ra, $s0		# save return addres back to $ra
	
		jr $ra			# return
