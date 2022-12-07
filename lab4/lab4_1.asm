.data
	maxStringSize: .word 99				        # String Max size
	
	Hello: .asciiz "Programm Starting ... \n"	        # String to identify start of programm.
	Goodbye: .asciiz "\nGoodbye ... \n"		        # String to indentify end of programm.
	InputComString: .asciiz "\nEnter your character: \n"	# String to command the user to input a string
	OutputIdentifier: .asciiz "\nOutput: "		        # String to identify Output
	
	TerminationChar: .byte  '@'			        # String termination character
	
	input: 	.align 2
		.space 100				        # input
	wordsOfInput: .align 0
	              .space 4 
	output: .space 100				        # output
	
	UpercaseLowerBound: .word 65
	UpercaseUperBound: .word 90
	LowercaseLowerBound: .word 97
	LowercaseUperBound: .word 122
	NumbersLowerBound: .word 48
	NumbersUperBound: .word 57
	spaceCharacter: .word 32
	

.text 
main:
	jal init
     	
	jal get_string
	
		 
		
	init:
		add $sp, $sp, -4                                # get ready to store ra at stack
		
		li $v0, 4 					# Load system call [Print string]
		la $a0, Hello 					# Load the Hello string to greet the user
		syscall						# Execute

		lb $t9, TerminationChar				# Load the Termination Char into t9
			
			# --- #
			
		add $v1,$zero,0					# Reg $v1 acts as an indexer for string size (v1 to follow convention)
		add $s0,$zero,0					# Reg $s0 acts as an indexer
		add $s2,$zero,0					# Reg $s2 acts as an indexer for processed string word size
		add $s5,$zero,0                                 # Reg $s5 acts as an indexer for processed size
		add $t9,$zero,0

		lw $t2, maxStringSize				# Load the max String Size into the t2

		la $a1, input					# Load input into a1 (a1 to follow convention)
		la $t7, input
		la $s6, wordsOfInput
		la $a2, output					# Load output into a2 (a2 to follow convention)
		
		jr $ra
		
	get_string:
	# Args : $a0 -> where to save string
	
	move $t1, $a0			# Move argument into temp memory
		li $v0, 4                               # Load system call [Print string]
	       	la $a0, InputComString 			# Promt user for input
	       	syscall					# Execute
		
		li $v0, 12				# Load system call [Reading a char]
		syscall					# Execute
		move $t0, $v0			        # get char to temp register t0
	
	bne $t0, $t9, AddToArray	# if char is not termination char, skip the following code
		li $t0, 0x0a		# load "\n" into t0
		srl $t2,$t4,8		# shift $t4 right for one byte
		j saveString
	
	AddToArray:
	
	add $v1, $v1, 1                 # increase indexer of string size
	
	beqz $t9, Move			# if t9 == 0 goto Move
	j OR				# else, goto OR
	
	Move:
		move $t4, $t0		# copy 1st character to $t4
		j exit_if_else		# skip the OR
	OR:
		or $t4,$t4,$t0		# copy character to $t4
	exit_if_else:

	add $t9, $t9, 1			# Increment index
			
	beq $t9, 0x04, saveString	# if we have 4 digits, got processString
	
	sll $t4,$t4,8			# shift $t4 left for one byte
		
	j get_string
	
	saveString:
						# $t7 acts as a pointer ('indexer') to the currently empty cell 
		sw $t4, ($t7)			# store word from $t4 into the address pointed by $t7
		move $t4, $0			# reset t4
		move $t9, $0			# reset t9

		add $t7, $t7, 4			# $t7 now points into a new empty cell

		bne $t0, 0x0a, get_string	# if char was not termi char, goto getString
		
		move $s0, $a1			# we copy the address of t5 into s0
		for_s0_a1_to_t7_loop:		# a1 holds the start of our data array, t7 holds the end.
			lw $s1, ($s0)		# load contents of s0 @into s1
			move $s3, $0		# S3 acts as an indexer for a for-loop
			for_s3_0_to_4_loop:
				andi $t6, $s1, 0xff	# load the first two digits into t6
				bnez $t6, ifNotNull	# if t6 != 0x00, skip the following commands
					srl $t4, $t4, 8		# shift t4 back right.
					j for_s3_0_to_4_loop_end
				ifNotNull:
				or $t4, $t4, $t6	# copy the t6 into t4
				beq $s3, 0x03, skip
				sll $t4, $t4, 8		# shift t4 left 8 bits
				srl $s1, $s1, 8		# shift s1 right 8 bits
	
				skip:
		
				addi $s3, $s3, 1
		
				blt $s3, 0x04, for_s3_0_to_4_loop
				
			for_s3_0_to_4_loop_end:
	
			sw $t4 0($s0)		# store contents of t4 into the address pointed by s0
			move $t4, $0		# reset t4
	
			addi $s0, $s0, 4	# move s0 to next word
				
		blt $s0, $t7, for_s0_a1_to_t7_loop	# while s0 < t7 -> loop
		
		move $s0, $0                    # restore s0
		
	
	process_string:
		move $v1, $a0                   # move the number of the characters of user's input from v1 to a3 to follow convention
		
		bgt $s0, $a3, output_string            # When the processing of all characters of input is done, exit process_string
			
		lw  $s6, input($s2)              # Load input word into temporary register s1
		add $s0, $s0, 1                 # Increment index by 1
		add $s2, $s2, 4                 # Increment index by 4
		add $s3,$zero, 0			# Reg $s3 acts as an indexer
		
		wordCheck:
		
		bge $s3, 0x04, process_string
		lb  $s4, wordsOfInput($s3) 
		add $s3, $s3, 1
		
			
		lw $t5, UpercaseLowerBound      # Load UpercaseLowerBound into t5
		lw $t6, UpercaseUperBound       # Load UpercaseUperBound into t6
		
		# Check if char is an Uppercase letter, if not goto nextCheck
		blt $s4, $t5, nextCheck         
		bgt $s4, $t6, nextCheck
		j insertToOutput                # If uppercase goto insertToOutput
			
		
		# Check if char is a Lowercase letter, if not goto nextCheck1		
		nextCheck:
			lw $t5, LowercaseLowerBound      # Load LowercaseLowerBound into t5
			lw $t6, LowercaseUperBound       # Load LowercaseUperBound into t6
			blt $s4, $t5, nextCheck1         
			bgt $s4, $t6, nextCheck1
			j insertToOutput                 # If lowercase goto insertToOutput
	
		# Check if char is a number, if not goto nextCheck2	
		nextCheck1: 
			lw $t5, NumbersLowerBound      # Load NumbersLowerBound into t5
			lw $t6, NumbersUperBound       # Load NumbersUperBound into t6
			blt $s4, $t5, nextCheck2         
			bgt $s4, $t6, nextCheck2
			j insertToOutput               # If number goto insertToOutput
	
		# Check if char is a space, if not go back to Loop2 without inserting to output	
		nextCheck2:
			lw $t5, spaceCharacter
			beq $s4, $t5, insertToOutput
			j wordCheck
					
		insertToOutput:
			sb $s4, output($s5)
			add $s5, $s5, 1
			j wordCheck               # After inserting a character to output go back to Loop2
		
	output_string:
		# Print OutputIdentifier
		li $v0, 4
		la $a0, OutputIdentifier
		syscall
		
		# Print output
		la $a0, output
		syscall
		
		la $a0, Goodbye
		syscall
		
		j exit
		
	exit:
		add $sp, $sp, 4                         # restore the stack
		
		# Terminate the program
		li $v0, 10
		syscall