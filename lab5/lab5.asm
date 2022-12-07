.data
	Str_OperationDet: .asciiz "Please determine operation, entry(E), inquiry (I), or quit(Q):"

	Str_Entr_num: .asciiz "Please enter entry num :"
	Str_Entr_lnam: .asciiz "Please enter last name:"
	Str_Entr_fnam: .asciiz "Please enter first name:"
	Str_Entr_phnam: .asciiz "Please enter phone number:"
	Str_Entr_succ: .asciiz "Thank, you the new entry is the following:"

	Str_Inq_num: .asciiz "Please enter the entry number you wish to retrieve:"
	Str_Inq_fail: .asciiz "There is no suck entry in the phonebook"
	Str_Inq_succ: .asciiz "The number is:"
	
	Str_Quit_bye: .asciiz "Self destruct armed and counting down:"
	
	Param_fnam_length: .word 20	# Length of first name
	Param_lnam_length: .word 20	# length of last name
	Param_pnum_length: .word 20	# length of phone number

	Addr_PhoneBook: .

	Char_I : .byte 'I'
	Char_E : .byte 'E'
	Char_Q : .byte 'Q'

.text 

main:
	whileInputInvalid:
		jal InputPromt			# Promt user for input
		move $t0, $v1			# Move input into $t0
	
		lw $t1, Char_Q			# Load Q into $t1 for comparison
		beq $t0, $t1, ValidInput	# Compare input to #t1/Q, if equals jump to ValidInput
		lw $t1, Char_E			# Load E into $t1 for comparison
		beq $t0, $t1, ValidInput	# Compare input to #t1/E, if equals jump to ValidInput
		lw $t1, Char_I			# Load Q into $t1 for comparison
		beq $t0, $t1, ValidInput	# Compare input to #t1I, if equals jump to ValidInput
	j whileInputInvalid			# If reached, input is invalid, therefore loop until valid.
	ValidInput:
	
	
	
NewEntry:
	sub $sp, $sp 4				# make room in the stack for 1 word
	sw $ra, 0($sp)				# Store current $ra into the stack
	
	jal LoadToStack				# Load all $tx registers to the stack.
	move $t0, $a0				#


InputPromt:
	# Promts the user for input and returns the char that was read.
	# Args : None
	# returns : char in $v1
	li $v0, 4			# Load system call [Print String]
	la $a0, Str_OperationDet	# Load string into $0 for printing
	syscall				# Execute

	li $v0, 12			# Load system call [Reading a char]
	syscall				# Execute	

	move $v1, $v0			# Return char 
	
	jr $ra
loadToStack:
	# Loads all $tx registers into the stack
	# Args : $a0 : How many bytes to skip in the stack
	# simplified example with $a0 = 8
	#| Before	| After
	#|0x00 <- 0(sp) |0x00	(free to save data)
	#|0x01		|0x01	(free to save data)
	#|0x02		|0x02 <- (t9)
	#|0x03		|0x03 <- (t8)
	#| .		| .
	#| .		| .
	add $a0, $a0, 40
	sub $sp, $sp, ($a0)	# make room for 18 variables
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
	
	la $v0, $sp(40)		# Returns the top address of the saved data 
	jr $ra 			# return
	
unloadFromStack:
# Unloads all $tx registers from the stack
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
	
	add $sp, $sp, 40	# Retract the stack
	
	jr $ra			# return

