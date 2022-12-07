.data
	maxStringSize: .word 99				        # String Max size
	
	Hello: .asciiz "Programm Starting ... \n"	        # String to identify start of programm.
	Goodbye: .asciiz "\nGoodbye ... \n"		        # String to indentify end of programm.
	InputComString: .asciiz "\nEnter your character: \n"	# String to command the user to input a string
	OutputIdentifier: .asciiz "\nOutput: "		        # String to identify Output
	
	TerminationChar: .byte  '@'			        # String termination character
	
	input: 	.align 2
		.space 100				        # input
	output: .align 2
		.space 100				        # output
	
	modHelper: .word 4
	
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
	
		add $v1,$zero,0					# Reg $v1 acts as an indexer for string size (v1 to follow convention)
		add $s0,$zero,0					# Reg $s0 acts as an indexer
		add $s2,$zero,0					# Reg $s2 acts as an indexer for processed string size
		add $t9,$zero,0
		lb $t1, TerminationChar				# Load the Termination Char into t1
		lw $t2, maxStringSize				# Load the max String Size into the t2
		lw $t8, modHelper 

		la $a1, input					# Load input into a1 (a1 to follow convention)
		la $a2, output					# Load output into a2 (a2 to follow convention)
		
		jr $ra
		
	get_string:
		li $v0, 4                               # Load system call [Print string]
	       	la $a0, InputComString 			# Promt user for input
	       	syscall					# Execute
		
		li $v0, 12				# Load system call [Reading a char]
		syscall					# Execute	

		beq $t1, $v0, fromTempToInput		# If input char is Termination Character, exit get_string		 				
		
		or $t7, $t7, $v0			    
		# sll $t7, $t7, 8
		beq  $v1, $t2, fromTempToInput		# If index has reached the Max String size, exit get_string
		add $v1, $v1, 1				# Increment index by 1
		
		# check if 4 bytes have been stored
		div $v1, $t8
		mfhi $t9
		bne $t9, $zero, get_string

		sll $t7, $t7, 8
		
		jal fromTempToInput
		

		
		j get_string			    	# Loop back
		
	fromTempToInput:
		                               
		sw $t7, input($t9)                      # save from temporary to input
		
		add $t9, $t9, 4
		
		#move $t7, $zero
		
		beq $t1, $v0, process_string
		beq  $v1, $t2, process_string
		
		jr $ra
	
	process_string:
		move $a3, $v1                   # move the number of the characters of user's input from v1 to a3 to follow convention
		
		bgt $s0, $a3, output_string     # When the processing of all characters of input is done, exit process_string
			
		lb $s1, input($s0)              # Load input character into temporary register s1
		add $s0, $s0, 1                 # Increment index by 1
			
		lw $t5, UpercaseLowerBound      # Load UpercaseLowerBound into t5
		lw $t6, UpercaseUperBound       # Load UpercaseUperBound into t6
		
		# Check if char is an Uppercase letter, if not goto nextCheck
		blt $s1, $t5, nextCheck         
		bgt $s1, $t6, nextCheck
		j insertToOutput                # If uppercase goto insertToOutput
			
		
		# Check if char is a Lowercase letter, if not goto nextCheck1		
		nextCheck:
			lw $t5, LowercaseLowerBound      # Load LowercaseLowerBound into t5
			lw $t6, LowercaseUperBound       # Load LowercaseUperBound into t6
			blt $s1, $t5, nextCheck1         
			bgt $s1, $t6, nextCheck1
			j insertToOutput                 # If lowercase goto insertToOutput
	
		# Check if char is a number, if not goto nextCheck2	
		nextCheck1: 
			lw $t5, NumbersLowerBound      # Load NumbersLowerBound into t5
			lw $t6, NumbersUperBound       # Load NumbersUperBound into t6
			blt $s1, $t5, nextCheck2         
			bgt $s1, $t6, nextCheck2
			j insertToOutput               # If number goto insertToOutput
	
		# Check if char is a space, if not go back to Loop2 without inserting to output	
		nextCheck2:
			lw $t5, spaceCharacter
			beq $s1, $t5, insertToOutput
			j process_string
					
		insertToOutput:
			sb $s1, output($s2)
			add $s2, $s2, 1
			j process_string               # After inserting a character to output go back to Loop2
		
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
