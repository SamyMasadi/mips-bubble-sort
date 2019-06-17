# Title: Bubble Sort	Filename: BubbleProject.asm
# Author: Samy Masadi		Date: 10/18/2018
# Description: A program to perform a bubble sort on user's integers
# Input: An array of 10 integers
# Output: Print sorted arrays: both ascending and descending order
################# Data segment #####################
.data
	input: .space 40
	sortd: .space 40
	sorta: .space 40
	prompt: .asciiz "Enter an integer: "
	div: .asciiz ", "
	unsorted: .asciiz "\nYour integers: "
	des: .asciiz "\nDescending order: "
	asc: .asciiz "\nAscending order: "
################# Code segment #####################
.text
.globl main
main:	# main program entry
	li $s0, 10	# Set array size limit
	la $s1, input	# Set array starting address
	la $s2, sortd	# Set sortd starting address
	la $s3, sorta	# Set sorta starting address
	
	move $s4, $zero		# initialize i counter
collect:	# loop to collect 10 integers from user and save them to input and sortd
	sll $t1, $s4, 2		# $t1 = 4 * i
	add $t0, $t1, $s1	# $t0 = address of input[i]
	add $t1, $t1, $s2	# $t1 = address of sortd[i]
	jal get_int		# Collect int from user
	sw $v0, 0($t0)		# Store int in input[i]
	sw $v0, 0($t1)		# Also copy to sortd[i]
	addi $s4, $s4, 1	# i++
	bge $s4, $s0, L1	# if i>=10, array limit reached
	j collect

L1:
	li $v0, 4		# code to print string
	la $a0, unsorted	# load unsorted string for printing
	syscall
	move $a0, $s1		# Set parameters for print_array
	move $a1, $s0
	jal print_array		# Print unsorted array
	
	move $s4, $zero	# initialize i counter
	li $s5, 9	# set i limit (array length - 1)
sort:	# loop to sort array of integers in descending order
	li $s6, 1		# initialize new j counter
	sub $s7, $s0, $s4	# set new j limit (array length - current i)
inner:	
	sll $t0, $s6, 2		# $t0 = 4 * j
	add $t0, $t0, $s2	# $t0 = address of sortd[j]
	addi $t1, $t0, -4	# $t1 = address of sortd[j-1]
	lw $t2, 0($t0)		# load sortd[j] to $t2
	lw $t3, 0($t1)		# load sortd[j-1] to $t3
	bge $t3, $t2, next	# if(sortd[j-1] >= sortd[j]), do not swap
	# For ascending order sort, change above line to ble $t3, $t2, next
	move $a0, $t0		# if(sortd[j-1] < sortd[j]), swap
	move $a1, $t1		# set parameters for swap
	jal swap
next:	
	addi $s6, $s6, 1	# j++
	bge $s6, $s7, outer	# if j>=(array length - current i), j limit reached
	j inner	
outer:
	addi $s4, $s4, 1	# i++
	bge $s4, $s5, L2	# if i>=(array length - 1), i limit reached
	j sort
	
L2:	# Print sortd
	li $v0, 4		# code to print string
	la $a0, des		# load des string for printing
	syscall
	move $a0, $s2		# Set parameters for print_array
	move $a1, $s0
	jal print_array		# Print sortd array

	li $s4, 9		# Set i to 9 (end of array)
	move $s5, $zero		# Set j to 0 (beginning of array)
reverse:	# loop to copy reversed version of sorted array into a separate array
	sll $t0, $s4, 2		# $t0 = 4 * i
	sll $t1, $s5, 2		# $t1 = 4 * j
	add $t0, $t0, $s2	# $t0 = address of sortd[i]
	add $t1, $t1, $s3	# $t1 = address of sorta[j]
	lw $t2, 0($t0)		# load sortd[i] to $t2
	sw $t2, 0($t1)		# copy to sorta[j]
	addi $s4, $s4, -1	# i--
	addi $s5, $s5, 1	# j++
	bge $s5, $s0, L3	# if (j >= array size), array limit reached
	j reverse

L3:	# print sorta
	li $v0, 4		# code to print string
	la $a0, asc		# load asc string for printing
	syscall
	move $a0, $s3		# Set parameters for print_array
	move $a1, $s0
	jal print_array
	
	li $v0, 10	# Exit program
	syscall

get_int:
########################################### get_int
# Prompts the user for an integer, reads, and returns it
#
# Parameters: none
#
# Pre:		a global string, labeled "prompt" must exist
# Post:		$v0 contains the value entered by the user
# Returns:	value entered by the user
# Called by:	main
# Calls:	none
#
	li $v0, 4	# code to print string
	la $a0, prompt	# load prompt for printing
	syscall
	
	li $v0, 5	# code to read int from user
	syscall		# system waits for input, puts the value in $v0
	
	jr $ra

swap:
############################################## swap
# Swaps two integers stored in two separate array elemnts.
#
# Parameters: $a0, $a1
#
# Pre:		$a0 contains the address for one array element
#		$a1 contains the address for another array element
# Post:		array integers will be swapped in memory
# Returns:	n/a
# Called by:	main
# Calls:	none
#
	lw $t0, 0($a0)	# loads int from $a0 address
	lw $t1, 0($a1)	# loads int from $a1 address
	sw $t1, 0($a0)	# stores $t1 into $a0 address
	sw $t0, 0($a1)	# stores $t0 into $a1 address
	
	jr $ra
	
print_array:
###################################### print_array
# Iterates through an array of integers and prints each integer.
#
# Parameters: $a0, $a1
#
# Pre:		$a0 must contain the starting address of a saved int array
#		$a1 must contain the array size
# Post:		The array has been printed
# Returns:	n/a
# Called by:	main
# Calls:	none
#
	move $t0, $a0		# $t0 = array starting address
	move $t1, $a1		# $t1 = array size
	move $t2, $zero		# inititalize i counter
print:
	sll $t3, $t2, 2		# $t3 = 4 * i
	add $t3, $t3, $t0	# $t3 = address array[i]
	li $v0, 1		# code to print int
	lw $a0, 0($t3)		# load array[i] for printing
	syscall
	addi $t2, $t2, 1	# i++
	bge $t2, $t1, exit	# if i>=array size, exit
	li $v0, 4		# code to print string
	la $a0, div		# load ", " for printing
	syscall
	j print
exit:
	jr $ra
