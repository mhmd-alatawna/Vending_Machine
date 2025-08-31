.data
menu : .asciiz "Please select an item:\nItem 1: Chips - 75 cents\nItem 2: Soda - 100 cents\nItem 3: Candy - 50 cents\nItem 4: Gum - 25 cents\n"
welcome : .asciiz "Welcome to the Vending Machine!\n"
askUser : .asciiz "Enter your selection:\n"
invalidInput : .asciiz "Invalid selection. please try again.\n"
option1 : .asciiz "You selected: Chips - 75 cents\n"
option2 : .asciiz "You selected: Soda - 100 cents\n"
option3 : .asciiz "You selected: Candy - 50 cents\n"
option4 : .asciiz "You selected: Gum - 25 cents\n"
productPrices : .word 75 , 100 , 50 , 25
insertCoins : .asciiz "Insert coins (1, 5, 10, or 25 cents):\n"
invalidInput2 : .asciiz "Invalid coin. Please insert 1, 5, 10, or 25 cents.\n"
currentAmount1 : .asciiz "Current total: "
currentAmount2 : .asciiz " cents\n"
insertionError1 : .asciiz "Transaction failed. Returning inserted coins: "
insertionError2 : .asciiz " cents\n"
dispensingText : .asciiz "Dispensing "
returningChangeMessage : .asciiz "Returning change: "
centsText : .asciiz " cents\n"
ThanksMessage : .asciiz "Thank you for your purchase!\n"

chipsText : .asciiz "Chips...\n"
sodaText : .asciiz "Soda...\n"
candyText : .asciiz "Candy...\n"
gumText : .asciiz "Gum...\n"

quantityArray : .word 5, 3, 10, 8
chips : .asciiz "Chips "
soda : .asciiz "Soda "
candy : .asciiz "Candy "
gum : .asciiz "Gum "
itemsNames : .word chips,soda,candy,gum
availableText : .asciiz "(Available: "
menuCentsText : .asciiz " cents "
menuEndOfText : .asciiz ")\n"
menuMiddleText1 : .asciiz ". "
menuMiddleText2 : .asciiz " - "
managerModeText : .asciiz "0. Manager Mode\n"

askManagerForPIN : .asciiz "enter PIN:\n"
rightPINText : .asciiz "Access Granted. Entering Manager Mode...\n"
wrongPINText : .asciiz "Incorrect PIN. Returning to main menu.\n"

managerModeWelcomeText : .asciiz "Manager Mode:\nEnter new stock for each item:\n"
currentText : .asciiz "(Current: "
managerModeEndText : .asciiz ") - Enter new quantity:\n"

updatedTextStart : .asciiz "Updated "
updatedTextMiddle : .asciiz "stock to "
updatedTextEnd : .asciiz ".\n"

returnToMainMessage : .asciiz "Returning to main menu.\n"

soldOutTextStart : .asciiz "Sorry, "
soldOutTextEnd : .asciiz "are Sold Out.\n"

.text
.globl main

main :
	li $v0 , 4
	la $a0 , welcome
	syscall #print welcome
	
	jal printMenu
	
	jal getInputToMenu
	move $s0 , $v0 #received input
	
	bne $s0 , 0 , ifNotManager
#---------------handle PIN------------------
	li $v0 , 4
	la $a0 , askManagerForPIN
	syscall #ask for PIN
	
	li $v0 , 5
	syscall #get PIN from user
	move $t0 , $v0
	
	beq $t0 , 1234 , correctPIN
	
	li $v0 , 4
	la $a0 , wrongPINText
	syscall #print permision denied
	
	j programEnd
	
	correctPIN :
	
	li $v0 , 4
	la $a0 , rightPINText
	syscall #print permision granted
	
#--------------end of PIN check-------------------
	jal handleManagerMode
	j programEnd
	
	ifNotManager :
	la $t0 , quantityArray
	la $t3 , itemsNames
	sll $t1 , $s0 , 2 #multiply by 4
	subi $t1 , $t1 , 4 #fix to maintain index access
	add $t0 , $t0 , $t1
	add $t3 , $t3 , $t1
	
	lw $t2 , 0($t0)
	
	bne $t2 , 0 , stockIsGood
	
	li $v0 , 4
	la $a0 , soldOutTextStart
	syscall #print start
	
	li $v0 , 4
	lw $a0 , 0($t3)
	syscall #print name
	
	li $v0 , 4
	la $a0 , soldOutTextEnd
	syscall #print end
	
	j programEnd
	
	stockIsGood :
	move $a0 , $s0
	jal printCurrentChoice
	move $s1 , $v0 #price of the selected item
	
	move $a0 , $s1
	move $a1 , $s0
	jal insertCoinsSystem
	move $s2 , $v0
	
	programEnd :
	
	j main
	
	
	
	
printMenu :
	la $t0 , itemsNames #current address to print
	addi $t1 , $0 , 0 #current name's index
	la $t2 , quantityArray
	la $t3 ,productPrices
	
	printLoop :
	
	li $v0 , 1
	addi $a0 , $t1 , 1
	syscall#print number
	
	li $v0 , 4
	la $a0 , menuMiddleText1
	syscall #print middle1
	
	li $v0 , 4
	lw $a0 , 0($t0)
	syscall #print name
	
	li $v0 , 4
	la $a0 , menuMiddleText2
	syscall #print middle2
	
	li $v0 , 1
	lw $a0 , 0($t3)
	syscall #print price
	
	li $v0 , 4
	la $a0 , menuCentsText
	syscall #print cents
	
	li $v0 , 4
	la $a0 , availableText
	syscall #print available
	
	li $v0 , 1
	lw $a0 , 0($t2)
	syscall #print quantity
	
	li $v0 , 4
	la $a0 , menuEndOfText
	syscall #print end
	
	addi $t1 , $t1 , 1
	addi $t0 , $t0 , 4
	addi $t2 , $t2 , 4
	addi $t3 , $t3 , 4
	
	bne $t1 , 4 , printLoop
#-----------------end of loop---------------------
	li $v0 , 4
	la $a0 , managerModeText
	syscall #print manager mode option
	
	jr $ra
	
	
	
getInputToMenu :
	getInput :
	li $v0 , 4
	la $a0 , askUser
	syscall #print askUser
	
	li $v0 , 5
	syscall #get input
	
	move $t0 , $v0 #move input
	
	blt $t0 , 0 , startBlock1 #condition 1
	bgt $t0 , 4 , startBlock1 #condition 2
	j endBlock1
	
	startBlock1 : #this is a block of code which is reachable only using the two conditions above
	
	li $v0 , 4
	la $a0 , invalidInput
	syscall #print invalid message
	
	j getInput
	
	endBlock1 :
	move $v0 , $t0
	jr $ra





handleManagerMode :
	li $v0 , 4
	la $a0 , managerModeWelcomeText
	syscall #print welcome for manager
	
	li $t0 , 0
	la $t1 , itemsNames
	la $t2 , quantityArray
	
	managerLoop :
#-----------ask manager to enter a stock------------------
	addi $t0 , $t0 , 1
	
	li $v0 , 1
	move $a0 , $t0
	syscall #print n
	
	li $v0 , 4
	la $a0 , menuMiddleText1
	syscall #print middle1
	
	li $v0 , 4
	lw $a0 , 0($t1)
	syscall #print name
	
	li $v0 , 4
	la $a0 , currentText
	syscall #print current text
	
	li $v0 , 1
	lw $a0 , 0($t2)
	syscall #print quantity
	
	li $v0 , 4
	la $a0 , managerModeEndText
	syscall #print end
#-----------end of ask manager to enter a stock------------------
	
	li $v0 , 5
	syscall #get input
	move $t3 , $v0 #move input
	
	sw $t3 , 0($t2) #update quantity
#--------------print updated--------------------
	li $v0 , 4
	la $a0 , updatedTextStart
	syscall #print start
	
	li $v0 , 4
	lw $a0 , 0($t1)
	syscall #print name
	
	li $v0 , 4
	la $a0 , updatedTextMiddle
	syscall #print middle
	
	li $v0 , 1
	lw $a0 , 0($t2)
	syscall #print quantity
	
	li $v0 , 4
	la $a0 , updatedTextEnd
	syscall #print end
	
#--------------end of print updated--------------------
	addi $t1 , $t1 , 4
	addi $t2 , $t2 , 4
	
	bne $t0 , 4 , managerLoop
	
	li $v0 , 4
	la $a0 , returnToMainMessage
	syscall #print return message
	
	jr $ra
	
	






printCurrentChoice :
	move $t0 , $a0
#begining of switch on selected option , in the end result will be saved in $a0 as the address of what should be printed
	bne $t0 , 1 , case2
	la $a0 , option1
	addi $t1 , $0 , 75
	j endSwitch #break
	
	case2 :
	bne $t0 , 2 , case3
	la $a0 , option2
	addi $t1 , $0 , 100
	j endSwitch #break
	
	case3 :
	bne $t0 , 3 , default
	la $a0 , option3
	addi $t1 , $0 , 50
	j endSwitch #break
	
	default :
	la $a0 , option4
	addi $t1 , $0 , 25

	endSwitch :
	li $v0 , 4
	syscall
	
	move $v0 , $t1
	jr $ra
	

insertCoinsSystem :
	move $t3 , $a0 #t3 will be the current amount needed to pay for the item
	addi $t2 , $0 , 0 #initialize the counter of tries
	addi $t1 , $0 , 0 #amount inserted till now
	
	loop :
	
	li $v0 , 4
	la $a0 , insertCoins
	syscall #print insertCoins request
	
	li $v0 , 5
	syscall #get input
	
	move $t0 , $v0 #move input
	
	addi $t2 , $t2 , 1 #update tries count
	
	beq $t0 , 1 , ifValidCoin #condition 1
	beq $t0 , 5 , ifValidCoin #condition 2
	beq $t0 , 10 , ifValidCoin #condition 3
	beq $t0 , 25 , ifValidCoin #condition 4
	
#-------------------start of else body
	startBlock2 : #print invalid message (the else of the if condition abouve)
	li $v0 , 4
	la $a0 , invalidInput2
	syscall
	
	j loopCondition
#----------------end of else body------------------
ifValidCoin : #valid coin entered so print current sum and check what should i pay (the if of the if condition abouve)
	
	add $t1 , $t1 , $t0
	
	subi $sp , $sp , 20
	sw $t1 , 0($sp)
	sw $t2 , 4($sp)
	sw $t3 , 8($sp)
	sw $a1 , 12($sp)
	sw $ra , 16($sp)
	
	move $a0 , $t1
	jal printCurrentCoins
	
	lw $t1 , 0($sp)
	lw $t2 , 4($sp)
	lw $t3 , 8($sp)
	lw $a1 , 12($sp)
	lw $ra , 16($sp)
	addi $sp , $sp , 20
	
#-----------------end of loop (this is the conditions for the loop)-----------------	
	loopCondition :
	bge $t1 , $t3 , transactionSucceded
	bne $t2 , 3 , loop
	
#------------------from here we are out of the loop-----------------------------

#------------in case 3 attemps have been used and didn't have enought do this -------------
	li $v0 , 4
	la $a0 , insertionError1
	syscall
	
	li $v0 , 1
	move $a0 , $t1
	syscall
	
	li $v0 , 4
	la $a0 , insertionError2
	syscall
	
	jr $ra
	
	
	transactionSucceded : #transaction succeded
#-----------------update stock---------------
	la $t7 , quantityArray
	sll $a1 , $a1 , 2
	subi $a1 , $a1 , 4
	add $t7 , $t7 , $a1
	lw $t8 , 0($t7)
	subi $t8 , $t8 , 1
	sw $t8 , 0($t7)
#-----------------end of update stock---------------
	sub $t4 , $t1 , $t3 #change
#------------------print dispensing message------------------
	li $v0 , 4
	la $a0 , dispensingText
	syscall
	
	subi $sp , $sp , 8
	sw $t4 , 0($sp)
	sw $ra , 4($sp)
	
	move $a0 , $t3
	jal printCurrentText
	
	lw $t4 , 0($sp)
	lw $ra , 4($sp)
	addi $sp , $sp , 8
#-----------------end of dispensing message--------------------
	beq $t4 , 0 , caseNoChange #if there is change print it otherwise do nothing
	
#----------print change-----------
	li $v0 , 4
	la $a0 , returningChangeMessage
	syscall
		
	li $v0 , 1
	move $a0 , $t4
	syscall
	
	li $v0 , 4
	la $a0 , centsText
	syscall

	caseNoChange :
	li $v0 , 4
	la $a0 , ThanksMessage
	syscall #print thanks message
	
	jr $ra

	

	
			
printCurrentCoins :
	move $t0 , $a0
	
	li $v0 , 4
	la $a0 , currentAmount1
	syscall
	
	li $v0 , 1
	move $a0 , $t0
	syscall
	
	li $v0 , 4
	la $a0 , currentAmount2
	syscall
	
	jr $ra
	
	
	
	
printCurrentText :
	move $t0 , $a0
#begining of switch on selected option , in the end result will be saved in $a0 as the address of what should be printed
	bne $t0 , 75 , case2.2
	la $a0 , chipsText
	j endSwitch2 #break
	
	case2.2 :
	bne $t0 , 100 , case2.3
	la $a0 , sodaText
	j endSwitch2 #break
	
	case2.3 :
	bne $t0 , 50 , default2
	la $a0 , candyText
	j endSwitch2 #break
	
	default2 :
	la $a0 , gumText

	endSwitch2 :
	li $v0 , 4
	syscall
	
	move $v0 , $t1
	jr $ra
