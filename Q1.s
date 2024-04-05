.data
prompt: .asciiz "Please enter the first coefficient: "
prompt1: .asciiz "Please enter the second coefficient: "
prompt2: .asciiz "Please enter first number of the sequence: "
prompt3: .asciiz "Please enter second number of the sequence: "
prompt4: .asciiz "Enter the number you want to calculate (it must be greater than 1): "
result: .asciiz "Output: "
result_continue: .asciiz ". element of the sequence is "


.text

# throughout this code s0,s1,s2,s3 are used as global variables
main:
    la		$a0, prompt        
    jal    print_string        # print the prompt


    jal		read_int			
    add		$t0, $v0, $0		# save the first coefficient

    la		$a0, prompt1        
    jal    print_string        # print the prompt1

    jal     read_int
    add		$t1, $v0, $0		# save the second coefficient

    la		$a0, prompt2        
    jal     print_string        # print the prompt2

    jal     read_int
    add		$t2, $v0, $0		# save the first sequence number

    la		$a0, prompt3       
    jal    print_string        # print the prompt3

    jal     read_int
    add		$t3, $v0, $0		# save the second sequence number

read_again:
    la		$a0, prompt4        
    jal     print_string        # print the prompt4

    jal     read_int
    add		$t4, $v0, $0		# save the number of sequence number to calculate

    slti    $t5, $t4, 2
    bne     $t5, $0 , read_again
    #exit the loop if the number is greater than 1(adjusted for index)

    addi   $t4, $t4, -1	 	# adjust for index 
    addi   $a0, $t4, 0          # a0 = t4 = n
    addi   $s0, $t0, 0          # s0 = t0 = a
    addi   $s1, $t1, 0          # s1 = t1 = b
    addi   $s2, $t2, 0          # s2 = t2 = x0
    addi   $s3, $t3, 0          # s3 = t3 = x1

    addi   $sp, $sp, -20
    sw     $t0, 0($sp)          # save a
    sw     $t1, 4($sp)          # save b
    sw     $t2, 8($sp)          # save x0
    sw     $t3, 12($sp)         # save x1
    sw     $t4, 16($sp)         # save n
    jal    calculate_sequence  # function call to calculate the sequence
    lw     $t0, 0($sp)          # restore a
    lw     $t1, 4($sp)          # restore b
    lw     $t2, 8($sp)          # restore x0
    lw     $t3, 12($sp)         # restore x1
    lw     $t4, 16($sp)         # restore n
    addi   $sp, $sp, 20
    
    addi   $t4, $t4, 1		# adjust back for index
    addi   $t7, $v0, 0          # t7 = f(n)

    la     $a0, result
    jal    print_string

    addi   $a0, $t4, 0
    jal    print_int

    la     $a0, result_continue
    jal    print_string

    addi   $a0, $t7, 0
    jal    print_int

exit:
    li      $v0, 10
    syscall
    
    


# s0=a, s1=b, s2=x0, s3=x1, a0=n
calculate_sequence:
    addi   $sp, $sp, -20
    sw     $a0, 0($sp)      # save a0
    sw     $a1, 4($sp)      # save a1
    sw     $a2, 8($sp)      # save a2
    sw     $a3, 12($sp)     # save a3
    sw     $ra, 16($sp)     # save ra
    
    
    beq    $a0, 1, if_x_1
    beq    $a0, 0, if_x_0

    addi   $sp, $sp, -4
    sw     $a0, 0($sp)         # save n
    addi   $a0, $a0, -1        # n-1
    jal    calculate_sequence
    lw     $a0, 0($sp)         # restore n
    addi   $sp, $sp, 4
    
    mult   $s0, $v0		#a*f(n-1)
    mflo   $t5			#t5 = a*f(n-1)
    
    addi   $sp, $sp, -4
    sw     $a0, 0($sp)          # save n
    addi   $sp, $sp, -4
    sw     $t5, 0($sp)          # save a*f(n-1)
    addi   $a0, $a0, -2         # n-2
    jal    calculate_sequence
    lw     $t5, 0($sp)          # restore a*f(n-1)
    addi   $sp, $sp, 4
    lw     $a0, 0($sp)          # restore n
    addi   $sp, $sp, 4

    mult   $s1, $v0             #b*f(n-2)
    mflo   $t6                  #t6 = b*f(n-2)

    add    $v0, $t5, $t6        #f(n) = a*f(n-1) + b*f(n-2)
    addi   $v0, $v0, -2         #f(n) = a*f(n-1) + b*f(n-2) - 2

    
    lw     $ra, 16($sp)     # restore ra
    lw     $a3, 12($sp)     # restore a3
    lw     $a2, 8($sp)      # restore a2
    lw     $a1, 4($sp)      # restore a1
    lw     $a0, 0($sp)      # restore a0
    addi   $sp, $sp, 20
    jr     $ra

if_x_1:
    addi   $v0, $s3, 0
    lw     $ra, 16($sp)     # restore ra
    lw     $a3, 12($sp)     # restore a3
    lw     $a2, 8($sp)      # restore a2
    lw     $a1, 4($sp)      # restore a1
    lw     $a0, 0($sp)      # restore a0
    addi   $sp, $sp, 20
    jr     $ra

if_x_0:
    addi   $v0, $s2, 0
    lw     $ra, 16($sp)     # restore ra
    lw     $a3, 12($sp)     # restore a3
    lw     $a2, 8($sp)      # restore a2
    lw     $a1, 4($sp)      # restore a1
    lw     $a0, 0($sp)      # restore a0
    addi   $sp, $sp, 20
    jr     $ra


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

