.data
	Str_OperationDet: 	.asciiz "Please determine operation, entry(E), inquiry (I), or quit(Q): "

	Str_Entr_num: 		.asciiz "\nPlease enter entry num : "
	Str_Entr_lnam: 		.asciiz "Please enter last name : "
	Str_Entr_fnam: 		.asciiz "Please enter first name : "
	Str_Entr_phnam: 	.asciiz "Please enter phone number : "
	Str_Entr_succ: 		.asciiz "Thank, you the new entry is the following :\n"
	Str_Entr_fail: 		.asciiz "Entry is already taken\n"

	Str_Inq_num: 		.asciiz "\nPlease enter the entry number you wish to retrieve : "
	Str_Inq_fail: 		.asciiz "There is no such entry in the phonebook\n"
	Str_Inq_preset:		.asciiz "The entry you requested is the following : \n"
	
	Str_Quit_bye: 		.asciiz "\nSelf destruct armed and counting down"
	
	Str_NewLine: 		.asciiz "\n"
	Str_Space: 		.asciiz " "
	
	Param_fnam_length: .word 20	# Length of first name
	Param_lnam_length: .word 20	# length of last name
	Param_pnum_length: .word 20	# length of phone number

	Buffer_firstName:	.align 2	# Buffer where the first name will be saved in memory	
			 	.space 20
	Buffer_lastName:  	.align 2	# Buffer where the last name will be saved in memory
			 	.space 20	
	Buffer_PhoneNumber: 	.align 2	# Buffer where the phone number will be saved in memory
			   	.space 20				
	Char_I : .word 'I'
	Char_E : .word 'E'
	Char_Q : .word 'Q'

.text 

main:
	jal init
	Promt:
		jal InputPromt			# Promt user for input
		move $t0, $v0			# Move input into $t0
	
		# --- Input Parsing --- #
		lw $t1, Char_Q			# Load Q into $t1 for comparison
		beq $t0, $t1, Exit		# Compare input to #t1/Q, if equals jump to Exit
		lw $t1, Char_E			# Load E into $t1 for comparison
		beq $t0, $t1, newEntry		# Compare input to #t1/E, if equals jump to ValidInput
		lw $t1, Char_I			# Load Q into $t1 for comparison
		beq $t0, $t1, Inquiry		# Compare input to #t1I, if equals jump to ValidInput
		
		jal PrintNewLine
		
	j Promt					# If reached, input is invalid, therefore loop until valid.
	newEntry:				# Label newEntry : Called when user inputs E !
		jal NewEntry			# Call function NewEntry
		
		j Promt				# Go back to Promt
		
	Inquiry:
		jal PrintEntryPromt		# Promt user for entry
		beqz $v1 Promt			# If entry was invalid, go back
		
		# --- Print "You entry is ..." --- #
		li $v0, 4			# Load system call [Print String]
		la $a0, Str_Inq_preset		# Load string for printing
		syscall				# Execute
		
		move $a0, $v1			
		jal PrintEntry			# Print Entry
		
		j Promt				# Go back to Promt
	Exit:
		li $v0, 4			# Load system call [Print String]
		la $a0, Str_Quit_bye		# Load string into $0 for printing
		syscall	

		li $v0, 10	
		syscall				# Terminate the program
	
	
# -~-~-~- Functions -~-~-~- #
init:	

	la $s0, ($sp)			# Save the top of the stack into $t0	
	sub $sp, $sp, 600		# Make room in the stack for the phonebook
	
	# Initializes values and Stack space.
	# - Stack Space : Nullifies the space where the phonebook will be saved.
	# - $s0 : Global Pointer : Phonebook Start Address.
	# No Arguments.
	# No Returns.
	# --- Function Start --- #
	move $t0, $0			# Used as counter
	move $t1, $s0			# Used as pointer to phonebook
	li $t2, 600			# 600 bytes
	NullifyStack:
		sw $0, ($t1)		# move NULL into stack
		
		add $t0, $t0, 4 	# increment counter
		sub $t1, $t1, 4 	# increment pointer to stack
	blt $t0, $t2, NullifyStack	# While counter is less than 600, goto NullifyStack
	# --- Function End --- #	
	jr $ra				# Return
	
NewEntry:
	sub $sp, $sp 4			# Allocate space in the stack for 1 word
	sw $ra, 0($sp)			# Store current $ra into the stack
	
	jal loadToStack			# Load all $tx registers to the stack.
	# Promts the user for details, creates a new entry and saves it to the 
	# stack by calling SaveToStack.
	# No Arguments.
	# No Returns.
	# --- Function Start --- #
	# Promt/Read Entry Number
	li $v0, 4			# Load system call [Print String]
	la $a0, Str_Entr_num		# Load string into $0 for printing
	syscall	
	
	li $v0, 5			# Load system call [Reading an integer]
	syscall	
	
	move $t0, $v0			# Load integer into $t0 
	mul $t1, $t0, 60		# Calculate offset
	add $t1, $s0, $t1		# Add offset into the phonebook
					# start address 
	lw $t2, ($t1)			# Load word from $t1 into $t2
	beq $t2, $0, EntryVacant	# If entry is vacant, skip this code.
		# --- Print "Entry is iccupied" --- #
		li $v0, 4			# Load system call [Print String]
		la $a0, Str_Entr_fail		# Load string into $0 for printing
		syscall	
		j NewEntryExit			# Exit function;
	EntryVacant:
	# Promt/Read Last Name
	li $v0, 4			# Load system call [Print String]
	la $a0, Str_Entr_lnam		# Load string into $0 for printing
	syscall		

	li $v0, 8			# Load system call [Read String]
    	la $a0, Buffer_lastName		# Load Buffer Address into $a0 for the data to be saved there
    	li $a1, 20 			# Max number of chars to read
    	syscall
	
	jal RemoveNewLine		# Removes NewLine from $a0
	bgezal $v1, PrintNewLine 	# Prints newline if needed
					# (Read RemoveNewLine doc for explenation)
	
	# Promt/Read First Name
	li $v0, 4			# Load system call [Print String]
	la $a0, Str_Entr_fnam		# Load string into $0 for printing
	syscall	
	
	li $v0, 8			# Load system call [Read String]
    	la $a0, Buffer_firstName	# Load Buffer Address into $a0 for the data to be saved there
	li $a1, 20			# Max number of chars to read
	syscall
    	
	jal RemoveNewLine		# Removes NewLine from $a0
	bgezal $v1, PrintNewLine 	# Prints newline if needed
	
	# Promt/Read Phone Number
	li $v0, 4			# Load system call [Print String]
	la $a0, Str_Entr_phnam		# Load string into $a0 for printing
	syscall	
	
	li $v0, 8			# Load system call [Read String]
    	la $a0, Buffer_PhoneNumber	# Load Buffer Address into $a0 for the data to be saved there
    	add $a1, $0, 20			# Max number of chars to read
    	syscall	
    	
    	jal RemoveNewLine		# Removes NewLine from $a0
	bgezal $v1, PrintNewLine 	# Prints newline if needed

	# Save by calling SaveToStack
	move $a0, $t1			# Load Save Address into Arg0
	la $a1, Buffer_lastName		# Load Pull Address for last name
	la $a2, Buffer_firstName	# Load Pull Address for first name
	la $a3, Buffer_PhoneNumber	# Load Pull Address for phone number
	jal SaveToStack			# Pulls data from Pull address and saves them
					# into the Save Address provided in $a0

	# --- Print "Your new entry is .... " --- #
	li $v0, 4			# Load system call [Print String]
	la $a0, Str_Entr_succ		# Load string for printing
	syscall				# Execute

	li $v0, 1			# Load system call [print integer]
	move $a0, $t0			# Load Entry num
	syscall

	jal PrintSpace

	move $a0, $t1			# Move 
	jal PrintEntry

	# --- Function End --- #
	NewEntryExit:
	jal unloadFromStack		# Unload $tx registers from stack
	lw $ra, 0($sp)			# Unload original return address from stack
	add $sp, $sp, 4			# Close the stack
	
	jr $ra				# Return

SaveToStack:
	sub $sp, $sp 4			# Allocate space in the stack for 1 word
	sw $ra, 0($sp)			# Store current $ra into the stack
	
	jal loadToStack			# Load all $tx registers to the stack.
	# Saves entry in the specified address.
	# Arg0 : Stack Save Address -> where data will be saved
	# Arg1 : Last Name Pull Address -> Address where Last Name will be pulled from.
	# Arg2 : First Name Pull Address -> Address where First Name will be pulled from. 
	# Arg3 : Phone Number Pull Address -> Address where Phone Number will be pulled from. 
	# --- Function Start --- #
	move $t0, $a0		# Arg0
	move $t1, $a1		# Arg1
	move $t2, $a2		# Arg2
	move $t3, $a3		# Arg3
	
	# We load each entry details into $t4 word by word, saving it each time
	# in the appropriate address (pointed by $t0).
	
	# --- Save Last Name --- #
	# Last Name - First Word
	lw $t4, 0($t1)		# Load from Pull Address
	sw $t4, 0($t0)		# Save to Stack
	# Last Name - Second Word		
	lw $t4, 4($t1)		# Load from Pull Address
	sw $t4, 4($t0)		# Save to Stack
	# Last Name - Third Word		
	lw $t4, 8($t1)		#	~=~
	sw $t4, 8($t0)		#	~=~
	# Last Name - Fourth Word		
	lw $t4, 12($t1)		#	~=~
	sw $t4, 12($t0)		#	~=~
	# Last Name - Fifth Word		
	lw $t4, 16($t1)
	sw $t4, 16($t0)	
	
	# --- Save First Name --- #
	# First Name - First Word
	lw $t4, 0($t2)
	sw $t4, 20($t0)		
	# First Name - Second Word		
	lw $t4, 4($t2)
	sw $t4, 24($t0)			
	# First Name - Third Word		
	lw $t4, 8($t2)
	sw $t4, 28($t0)
	# First Name - Fourth Word		
	lw $t4, 12($t2)
	sw $t4, 32($t0)	
	# First Name - Fifth Word		
	lw $t4, 16($t2)
	sw $t4, 36($t0)	

	# --- Save Phone Number --- #
	# Phone Number - First Word
	lw $t4, 0($t3)
	sw $t4, 40($t0)		
	# Phone Number - Second Word		
	lw $t4, 4($t3)
	sw $t4, 44($t0)			
	# Phone Number - Third Word		
	lw $t4, 8($t3)
	sw $t4, 48($t0)
	# Phone Number - Fourth Word		
	lw $t4, 12($t3)
	sw $t4, 52($t0)	
	# Phone Number - Fifth Word		
	lw $t4, 16($t3)
	sw $t4, 56($t0)	
	# --- Function End --- #				
	jal unloadFromStack		# Unload $tx registers
	lw $ra, ($sp)			# Unload return address from stack
	add $sp, $sp, 4			# Close the stack
	jr $ra				# Return

RemoveNewLine:
	sub $sp, $sp 4			# Allocate space in the stack for 1 word
	sw $ra, 0($sp)			# Store current $ra into the stack
	
	jal loadToStack			# Load all $tx registers to the stack.
	
	# Searches and removes a single newline char from the string in the specified address.
	# Arg0 : String Pull Address 
	# Returns : -1 if newline char was found and removed, else 0.
	#		( The -1 return value was chosen for an easier incorporation
	#		  with the bgezal command (branch if greated or equal to zero).
	#		  A single line command is suffecient to call PrintNewLine and return
	#		  without extra complications.)
	# --- Function Start --- #
	move $t0, $a0			# Arg0
	move $v1, $0			# Returns 0 if newline was not found, 1 if found.
	add $t8, $t0, 20		# Load the last word address into $t8
	WhileNotEndOfString:
		lw $t1, ($t0)		# Load word into $t1
		li $t2, 0xff		# $t2 acts as a Mask
		li $t9, 0x0a		# load NewLine char into $t9
		WhileNotEndOfWord:
			and $t3, $t1, $t2	# Get byte
			bne $t3, $t9, Repeat	# If char is not NewLine, repeat
			# --- NewLine was found --- #
			nor $t2, $t2, $0		# Invert the mask
			and $t1, $t1, $t2		# And the mask with the word
			
			sw $t1, ($t0)			# Store word back
			li $v1, -1			# Return -1
			j RemoveNewLineExit
			
			Repeat:
			sll $t2, $t2, 8		# Shift mask to mask the next byte
			sll $t9, $t9, 8		# Shifr NewLine to match mask
			beq $t2, $0 EndOfWord	# If the mask has fallen off 
			
			j WhileNotEndOfWord	# Loop back
		EndOfWord:
		add $t0, $t0, 4		# point to next word
		bge $t0, $t8, RemoveNewLineExit	# If we have reached the end of the string, Exit
		j WhileNotEndOfString	# Loop Back	
	# --- Function End --- #			
	RemoveNewLineExit:		
	jal unloadFromStack		# Unload $tx registers
	lw $ra, ($sp)			# Unload return address from stack
	add $sp, $sp, 4			# Close the stack
	jr $ra				# Return
	
PrintNewLine:
	li $v0, 4			# Load system call [Print String]
	la $a0, Str_NewLine		# Load string into $0 for printing
	syscall
	
	jr $ra				# Return
PrintSpace:
	li $v0, 4			# Load system call [Print String]
	la $a0, Str_Space		# Load string into $0 for printing
	syscall	
	
	jr $ra		
PrintEntry:
	sub $sp, $sp 4			# Allocate space in the stack for 1 word
	sw $ra, 0($sp)			# Store current $ra into the stack
	
	jal loadToStack			# Load all $tx registers to the stack.
	# Prints the entry details at the specified address.
	# Arg0 : Entry Pull Address.
	# --- Function Start --- #
	
	move $t1, $a0			# Arg0

	# --- Print Last Name --- #	
	li $v0, 4			# Load system call [Print String]
	move $a0, $t1			# Load string for printing
	syscall				# Execute
	
	jal PrintSpace
	
	# --- Print First Name --- #

	add $t1, $t1, 20		# Increment into the next field
	move $a0, $t1			# Load string for printing
	syscall				# Print next field

	jal PrintSpace

	# --- Print Phone Number --- #
	add $t1, $t1, 20		# Increment into the next field
	move $a0, $t1
	syscall				# Print next field	
	
	jal PrintNewLine
	
	# --- Function End --- #		
	PrintEntryExit:		
	jal unloadFromStack		# Unload $tx registers
	lw $ra, ($sp)			# Unload return address from stack
	add $sp, $sp, 4			# Close the stack
	jr $ra				# Return
PrintEntryPromt:
	sub $sp, $sp 4			# Allocate space in the stack for 1 word
	sw $ra, 0($sp)			# Store current $ra into the stack
	
	jal loadToStack			# Load all $tx registers to the stack.
	# Promt for the Inquiry option.
	# Returns : 0 if the entry is vacant, else the address of the specified entry.
	# --- Function Start --- #
	li $v0, 4			# Load system call [Print string]
	la $a0, Str_Inq_num		# Load string into system call
	syscall				# Execute
	
	li $v0, 5			# Load system call [Reading an integer]
	syscall				# Execute	
	
	move $t0, $v0			# Index of the entry to print

	move $t1, $s0			# Load the Phonebook Address into $t1
	mul $t2, $t0, 60		# $t2 = 60*index | How much we must procced in the stack
					# to reach the specified index
	add $t1, $t1, $t2		# Increment the phonebook pointer to reach the requested index
	
	lw $t3 ($t1)
	bne $t3, $0, ValidEntry
		li $v0, 4		# Load system call [Print String]
		la $a0, Str_Inq_fail	# Load string for printing
		syscall		
		
		move $v1, $0		# Output 0 to mark failure.
		
		j PrintEntryPromtExit
	ValidEntry:
	move $v1, $t1			# Output the address requested
	# --- Function End --- #		
	PrintEntryPromtExit:		
	jal unloadFromStack		# Unload $tx registers
	lw $ra, ($sp)			# Unload return address from stack
	add $sp, $sp, 4			# Close the stack
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
