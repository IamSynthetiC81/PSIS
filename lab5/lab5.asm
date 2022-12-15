.data
	Str_OperationDet: .asciiz "\nPlease determine operation, entry(E), inquiry (I), or quit(Q):"

	Str_Entr_num: .asciiz "Please enter entry num :"
	Str_Entr_lnam: .asciiz "\nPlease enter last name:"
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

	Addr_PhoneBook: 	.align 2	# Address of phonebook in the stack	
				.space  60
	Buffer_firstName:	.align 2	# Buffer where the first name will be saved 	
			 	.space 20
	Buffer_lastName:  	.align 2	# Buffer where the last name will be saved
			 	.space 20	
	Buffer_PhoneNumber: 	.align 2	# Buffer where the phone number will be saved
			   	.space 20				

	Char_I : .word 'I'
	Char_E : .word 'E'
	Char_Q : .word 'Q'

.text 

main:
	whileInputInvalid:
		jal InputPromt			# Promt user for input
		move $t0, $v0			# Move input into $t0
	
		lw $t1, Char_Q			# Load Q into $t1 for comparison
		beq $t0, $t1, Exit		# Compare input to #t1/Q, if equals jump to Exit
		lw $t1, Char_E			# Load E into $t1 for comparison
		beq $t0, $t1, newEntry		# Compare input to #t1/E, if equals jump to ValidInput
		lw $t1, Char_I			# Load Q into $t1 for comparison
		beq $t0, $t1, ValidInput	# Compare input to #t1I, if equals jump to ValidInput
	j whileInputInvalid			# If reached, input is invalid, therefore loop until valid.
	ValidInput:
	newEntry:				# Label newEntry : Called when user inputs E !
		jal NewEntry			# Call function NewEntry
		
		j main
	Exit:

		li $v0, 10	
		syscall				# Terminate the program
	
NewEntry:
	sub $sp, $sp 4			# Allocate space in the stack for 1 word
	sw $ra, 0($sp)			# Store current $ra into the stack
	
	jal loadToStack			# Load all $tx registers to the stack.
	
	# Promt/Read Entry Number
	li $v0, 4			# Load system call [Print String]
	la $a0, Str_Entr_num		# Load string into $0 for printing
	syscall	
	
	li $v0, 12			# Load system call [Reading a char]
	syscall	
	
	move $t0, $v0			# Load char into $t0
	
	# Promt/Read Last Name
	li $v0, 4			# Load system call [Print String]
	la $a0, Str_Entr_lnam		# Load string into $0 for printing
	syscall	
	

	li $v0, 8			# Load system call [Read String]
    	la $a0, Buffer_lastName		# Load Buffer Address into $a0 for the data to be saved there
    	add $a1, $0, 0x14 		# Max number of chars to read
    	syscall

	la $t1, Buffer_lastName		# Load the first name buffer address into $t1 	
	
	# Promt/Read First Name
	li $v0, 4			# Load system call [Print String]
	la $a0, Str_Entr_fnam		# Load string into $0 for printing
	syscall	
	
	li $v0, 8			# Load system call [Read String]
    	la $a0, Buffer_firstName	# Load Buffer Address into $a0 for the data to be saved there
    	add $a1, $0, 0x14 		# Max number of chars to read
    	syscall

	la $t2, Buffer_firstName	# Load the first name buffer address into $t1 	

	# Promt/Read Phone Number
	li $v0, 4			# Load system call [Print String]
	la $a0, Str_Entr_phnam		# Load string into $0 for printing
	syscall	
	
	li $v0, 8			# Load system call [Read String]
    	la $a0, Buffer_PhoneNumber	# Load Buffer Address into $a0 for the data to be saved there
    	add $a1, $0, 0x14 		# Max number of chars to read
    	syscall

	la $t2, Buffer_PhoneNumber	# Load the first name buffer address into $t1 		
	#### TESTING
	li $v0, 4			# Load system call [Print String]
	la $a0, Buffer_firstName	# Load string into $0 for printing
	syscall	
	la $a0, Buffer_lastName		# Load string into $0 for printing
	syscall	
	la $a0, Buffer_PhoneNumber	# Load string into $0 for printing
	syscall	

	# Closing code
	jal unloadFromStack		# Unload $tx registers from stack
	lw $ra, 0($sp)			# Unload original return address from stack
	add $ra, $ra, 4			# Close the stack
	
	jr $ra				# Return

InputPromt:
	# Promts the user for input and returns the char that was read.
	# Args : None
	# returns : char in $v0
	li $v0, 4			# Load system call [Print String]
	la $a0, Str_OperationDet	# Load string into $0 for printing
	syscall				# Execute

	li $v0, 12			# Load system call [Reading a char]
	syscall				# Execute	
	
	jr $ra				# $V0 has the char already loaded
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
	sub $sp, $sp, 40	# make room for 10 variables
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
	
	lw $v0, 40($sp)		# Returns the top address of the saved data 
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

