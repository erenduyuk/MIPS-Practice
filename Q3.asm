.data
    prompt: .asciiz "Enter a string: "
    prompt1: .asciiz "Enter the shuffle count: "
    str: .asciiz "Computer"


.text
.globl main

# $a0 - string address
# $a1 - shuffle count
# $a2 - string length

main:
    li $v0, 4               # Load system call code for print string
    la $a0, prompt          # Load address of the prompt
    syscall
    
    li $v0, 8               # Load system call code for read string
    la $a0, str             # Load address of the string
    li $a1, 2048            # Load string buffer size
    syscall
    
    addi $sp, $sp, -4       # Allocate space for 1 register on the stack
    sw $a0, 0($sp)          # Save string address

    li $v0, 4               # Load system call code for print string
    la $a0, prompt1         # Load address of the prompt1
    syscall

    li $v0, 5               # Load system call code for read integer
    syscall
    move $a1, $v0           # Save shuffle count

    lw $a0, 0($sp)          # Restore string address
    addi $sp, $sp, 4        # Deallocate stack space

    li $s3, 0                   # Initialize counter for string length
strlen:
    add $t2, $s3, $a0       # Calculate address of the current character
    lb $t3, 0($t2)          # Load current character
    beqz $t3, main_cont     # If current character is null, exit loop
    addi $s3, $s3, 1        # Increment counter
    j strlen
    

main_cont:

    add $a2, $s3, $0        # Load string length
    jal shuffle             # Call shuffle procedure

    la $a0, str             # Load address of the string
    addi $v0, $0, 4         # Load system call code for print string
    syscall

	li $v0, 10              # Exit program
	syscall





shuffle:
    addi $sp, $sp, -16      # Allocate space for 4 registers on the stack
    sw $ra, 0($sp)          # Save return address
    sw $a0, 4($sp)          # Save string address
    sw $a2, 12($sp)         # Save string lenght

    beqz $a1, shuffle_end   # If shuffle count is 0, exit recursion

    addi $a1, $a1, -1       # Decrement shuffle count
    srl $a2, $a2, 1         # Calculate string length /2
    jal swap                # Call swap procedure on the current string


    jal shuffle             # Recursive call to first ha
    
    add $a0, $a0, $a2       # Move to the next half in the string

    jal shuffle             # Recursive call to second half string

shuffle_end:
    lw $ra, 0($sp)          # Restore return address
    lw $a0, 4($sp)          # Restore string address
    lw $a1, 8($sp)          # Restore shuffle count
    lw $a2, 12($sp)         # Restore string length

    addi $sp, $sp, 16       # Deallocate stack space
    jr $ra                  # Return to caller


swap:
    addi $sp, $sp, -16       # Allocate space for 2 registers on the stack
    sw $ra, 0($sp)          # Save return address
    sw $a0, 4($sp)          # Save string address
    sw $a1, 8($sp)          # Save shuffle count
    sw $a2, 12($sp)         # Save string length

    li $t3, 0               # Initialize counter for for loop

swap_for_loop:
    ble $a2, $t3, swap_end  # If string length is less than 0, exit swap procedure

    lb $t0, 0($a0)          # Load first character
    add $t1, $a0, $a2       # Calculate address of the second character
    lb $t2, 0($t1)          # Load second character
    
    sb $t2, 0($a0)          # Store second character in the first character's address
    sb $t0, 0($t1)          # Store first character in the second character's address

    addi $a0, $a0, 1        # Move to the next character
    addi $t3, $t3, 1        # Increment counter
    j swap_for_loop


swap_end:
    lw $a2, 12($sp)         # Restore shuffle count
    lw $a1, 8($sp)          # Restore string length
    lw $a0, 4($sp)          # Restore string address
    lw $ra, 0($sp)          # Restore return address

    addi $sp, $sp, 16       # Deallocate stack space
    jr $ra                  # Return to caller

