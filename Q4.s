.data
    matrix: .byte 5, 6, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0
    newline: .asciiz "\n"
    output: .asciiz "The number of the 1s on the largest island is: "

.text
main:
    
    add $a2, $zero, $zero # tempIslandSize = 0 = a2
    add $t2, $zero, $zero # i = 0 = t2
    add $t3, $zero, $zero # j = 0 = t3
    la $t9, matrix # t9 = matrix address
    add $t8, $zero, $zero # t8 = maxIslandSize
    lb $t0, 0($t9) # t0 = maxRow
    lb $t1, 1($t9) # t1 = maxColumn
    addi $t9, $t9, 2 # t9 = matrix[0][0]

    L1:
        slt $t4, $t2, $t0 # i < row
        beq $t4, 0, end
        add $a3, $t2, $zero # a3 = i
        addi $t2, $t2, 1 # i++
        add $t3, $zero, $zero # j = 0 = t1

        L2:
            slt $t4, $t3, $t1 # j < column
            beq $t4, 0, goL1
            add $a1, $t3, $zero # a1 = j
            addi $t3, $t3, 1 # j++
            mul $t5, $a3, $t1
            add $t5, $t5, $a1 # t3 = i * column + j
            add $t5, $t5, $t9 # t5 = matrix[i][j]
            lb $t5, 0($t5) # t3 = matrix[i][j]
            li $v0 1
            move $a0, $t5
            syscall
            beq $t5, 1, goCheckIsland
            j L2
            goCheckIsland:
                add $a2, $zero, $zero # tempIslandSize = 0 = t8
                jal checkIsland
                j L2
            goL1:
                la $a0, newline
                li $v0, 4
                syscall
                j L1

    # End of program
    end:

        # Print max island size
        move $t0, $t8
        li $v0, 4           # Sistem çağrısı numarası: 4 (print_str)
        syscall

        la $a0, output      
        li $v0, 4
        syscall
        
        li $v0, 1           # Sistem çağrısı numarası: 1 (print_int)
        move $a0, $t0       
        syscall

        # Programı sonlandır
        li $v0, 10        
        syscall           

checkIsland:
    # Stack pointer operations
    addi $sp, $sp, -8
    sb $a3, 0($sp)
    sb $a1, 1($sp)
    sw $ra, 4($sp)

    addi $a2, $a2, 1 # tempIslandSize++
    jal checkDown
    jal checkUp
    jal checkRight
    
    add $t5, $t8, $zero # t5 = maxIslandSize
    slt $t4, $a2, $t5 # tempIslandSize < maxIslandSize
    beq $t4, 1, endOfFunction # if tempIslandSize < maxIslandSize, end of function
    add $t8, $a2, $zero # maxIslandSize = tempIslandSize

    j endOfFunction

checkRight:
    # Stack pointer operations
    addi $sp, $sp, -8
    sb $a3, 0($sp)
    sb $a1, 1($sp)
    sw $ra, 4($sp)

    addi $a1, $a1, 1 # j++
    slt $t4, $a1, $t1 # j < column
    beq $t4, 0, endOfFunction # if i >= column, check down side
    mul $t4, $a3, $t1 
    add $t4, $t4, $a1 # t3 = i * column + j
    add $t4, $t4, $t9 # t4 = matrix[i][j + 1]
    lb $t4, 0($t4) # t3 = matrix[i][j + 1]    
    beq $t4, 1, goRightInFunction
    j endOfFunction
    goRightInFunction:
        addi $a2 $a2, 1 # tempIslandSize++
        jal checkDown
        jal checkUp
        jal checkRight
        j endOfFunction

    # Check there is an island on down side
checkDown:
    # Stack pointer operations
    addi $sp, $sp, -8
    sb $a3, 0($sp)
    sb $a1, 1($sp)
    sw $ra, 4($sp)

    addi $a3, $a3, 1 # i++
    slt $t4, $a3, $t0 # i < row
    beq $t4, 0, endOfFunction # if i >= row, end of island
    mul $t4, $a3, $t1
    add $t4, $t4, $a1 # t4 = i * column + j
    add $t4, $t4, $t9 # t4 = matrix[i][j + 1]
    lb $t4, 0($t4) # t4 = matrix[i + 1][j]
    beq $t4, 1, goDownInFunction
    j endOfFunction
    goDownInFunction:
        addi $a2 $a2, 1 # tempIslandSize++
        jal checkDown
        j endOfFunction

    # Check there is an island on up side
checkUp:
    # Stack pointer operations
    addi $sp, $sp, -8
    sb $a3, 0($sp)
    sb $a1, 1($sp)
    sw $ra, 4($sp)

    addi $a3, $a3, -1 # i--
    slt $t4, $a3, $zero # i < 0
    beq $t4, 1, endOfFunction # if i < 0, end of island
    mul $t4, $a3, $t1
    add $t4, $t4, $a1 # t4 = i * column + j
    add $t4, $t4, $t9 # t4 = matrix[i][j + 1]
    lb $t4, 0($t4) # t4 = matrix[i - 1][j]
    beq $t4, 1, goUpInFunction
    j endOfFunction
    goUpInFunction:
        addi $a2 $a2, 1 # tempIslandSize++
        jal checkUp
        j endOfFunction


endOfFunction:
    lb $a3, 0($sp)
    lb $a1, 1($sp)
    lw $ra, 4($sp) 
    addi $sp, $sp, 8
    jr $ra