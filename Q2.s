.data
prompt: .asciiz "Enter a number(enter -1 to stop): "
result: .asciiz "The new array is: "
space: .asciiz " "


.text

main:
	# important note, since we are using the stack to store the number sequence,
    # the first item of the number sequence will be at the tail of the stack. start of the number sequence = tail of stack
	# because of that we will use register s3 to point to the start of the number sequence,
    # and sp will still point to the head of the stack

    # s1 will be used as a global variable to store the gcd of the two numbers
    # s2 will be used as a global variable to store the stop number (-1)

    addi    $s2, $0, -1		# initialize stop number to -1
    addi    $s0, $sp, -4	# save start of the stack
    
    input_loop:
        la		$a0, prompt        
        jal    print_string        # print the prompt    

        jal		read_int			
        add		$t0, $v0, $0		# save the number

        addi    $sp, $sp, -4		
        sw		$t0, 0($sp)		# save the number in the stack

        bne     $t0, $s2, input_loop		# if the number is not -1, continue taking input
    
    # we will use s3 to store the start of the number sequence
    start_loop:
        addi    $s3, $s0, 0     # set s3 to the start of the number sequence
    continue_loop:
        lw      $t0, 0($s3)		# load the number from the number sequence		
        beq     $t0, $s2, finish		# if the number is -1, go to finish

        lw      $t1, -4($s3)		# load the number from the number sequence		
        beq     $t1, $s2, finish		# if the number is -1, go to finish

        addi    $sp,$sp,-16
        sw      $t0, 0($sp)     # save the first number
        sw      $t1, 4($sp)     # save the second number
        sw      $a0, 8($sp)     # save a0
        sw      $a1, 12($sp)    # save a1
        addi    $a0, $t0, 0     # load the first number to $a0
        addi    $a1, $t1, 0     # load the second number to $a1
        jal     check_coprime   # check if coprime, if coprime, continue_loop
        lw      $a1, 12($sp)    # restore a1
        lw      $a0, 8($sp)     # restore a0
        lw      $t1, 4($sp)     # restore the second number
        lw      $t0, 0($sp)     # restore the first number 
        addi    $sp,$sp,16


        addi    $s3, $s3, -4     # move the number sequence pointer to the next numbers
        bne     $v0, $zero, continue_loop
        # else replace the first number with least common factor, shift loop to the left, go to start_loop 
        addi    $s3, $s3, 4     # move the number sequence pointer back to the current numbers
        # lcm equals to the product of the two numbers divided by their gcd
        mult    $t0, $t1      # a*b
        mflo    $t2
        div     $t2, $s1      # a*b/gcd
        mflo    $t2           # lcm
        sw      $t2, 0($s3)   # replace first number with lcm
        addi    $s3, $s3, -4    # move the number sequence pointer to the next number
        # shift number sequence to the left by 1
        jal     shift_stack
        j       start_loop


    
shift_stack:
    lw      $t1, -4($s3)    # load the second number from the number sequence
    sw      $t1, 0($s3)    # move the second number to the first number
    addi    $s3, $s3, -4    # move the number sequence pointer to the next number
    bne     $t1, $s2, shift_stack # if the second number is not -1, continue shifting the number sequence
    jr      $ra             # return 


    # check if coprime and find gcd using euclidean algorithm
check_coprime:
    move    $t2, $a0       # copy first number to $t2
    move    $t3, $a1       # copy second number to $t3
    gcd_loop:
        beq    $t3, $zero, result_coprime # if t3 is zero, loop done
        move   $t4, $t3   # copy t3 to t4
        div    $t2, $t3    # divide t2 by t3
        mfhi   $t5        # t5 = remainder, t5 = t2 mod t3
        move   $t2, $t4   # copy t4 to t2 (original t3)
        move   $t3, $t5   # copy remainder to t3
        j      gcd_loop      # jump back to loop

    result_coprime:
        move   $s1, $t2            # save gcd to global variable $s1
        bne    $t2, 1, not_coprime # if t2 is not 1, numbers are not co-prime(t2 is the gcd of the two numbers)
        addi   $v0, $zero, 1       # set $v0 to 1 (co-prime)
        jr     $ra

    not_coprime:
        addi   $v0, $zero, 0       # set $v0 to 0 (not co-prime)
        jr     $ra
    


finish:

    la	    $a0, result
    jal	    print_string         # print the result message

    addi    $s3, $s0, 0     # restore start of the numbers
    lw      $a0, 0($s3)		    # load the number from the number sequence
    beq     $a0, $s2, exit      # if the number is -1, exit
    print_array:
        
        jal     print_int       # print the number
        la      $a0, space
        jal     print_string    # print space
        addi    $s3, $s3, -4    # move the number sequence pointer to the next number
        lw      $a0, 0($s3)		# load the number from the number sequence
        bne     $a0, $s2, print_array		# if the number is not -1, continue printing
    
    exit:
        li      $v0, 10			    # system call #10 - exit
        syscall                     # terminate program
    

print_string:
    addi    $v0, $0, 4		# system call #4 - print string
    syscall                     # execute
    jr	    $ra

read_int:
    addi    $v0, $0, 5		# system call #5 - read int
    syscall						# execute
    jr	    $ra

print_int:
    addi    $v0, $0, 1		# system call #1 - print int
    syscall						# execute
    jr	    $ra