global _start
_start:
	push '0'
	mov byte [cnt], 0x01
    mov edx, Welcome_msgLen      	; Setup sys_write for the character
    mov ecx, Welcome_msg
    mov ebx, stdout 
    mov eax, sys_write 
    int 0x80 
_input: ; read the input to inBuffer
    mov edx, 0x01  	; use sys_read to read one byte at a time.
    mov ecx, inBuffer  
    mov ebx, stdin   
    mov eax, sys_read 
    int 0x80            	; trigger a system call interrupt for the sys_read
	mov esi, inBuffer		; Point esi at the byte read in.
_check:	; See if the input is a bracket and process it accordingly, if it's not, read the next input.
	cmp eax, 0x00 ; check for EOF
	je _exit
	cmp byte [ecx], new_line
	jne _line
	add byte [cnt], 0x01
_line:
	_n0:	; Check for open parenthesis, jump the push if it doesn't match.
	cmp byte [ecx], '('
	jne _n1
	push '('
	_n1:	; Repeat for the rest of the brackets.
	cmp byte [ecx], '{'
	jne _n2
	push '{'
	_n2:
	cmp byte [ecx], '['
	jne _n3
	push '['
	_n3:	; If it's a closed bracket, jump to specific instructions for checking the last input bracket.
	cmp byte [ecx], ')'
	je _cPar
	cmp byte [ecx], '}'
	je _cCur
	cmp byte [ecx], ']'
	je _cSqr
	inc ecx
	cmp ecx, esi
	je _exit
	jmp _input ; Read the next byte.
_closedBracket:	; Based on the type of closed bracket we recieved, check if it's open type is popped from the stack. If it's not, see what it is and go to the expected group.
	_cPar: ; Figure out which bracket we're trying to close.
		pop edi	; Store the last open bracket in eax
		cmp edi, '{'
		je _ExpCur	
		cmp edi, '['
		je _ExpSqr	
		inc ecx
		jmp _input ; Read the next byte.
	_cCur:
		pop edi	; Store the last open bracket in eax
		cmp edi, '('
		je _ExpPar	
		cmp edi, '['
		je _ExpSqr	
		inc ecx
		jmp _input ; Read the next byte.
	_cSqr:
		pop edi	; Store the last open bracket in eax
		cmp edi, '('
		je _ExpPar	
		cmp edi, '{'
		je _ExpCur
		inc ecx
		jmp _input ; Read the next byte.
_ExpectedMsg:	; Print the proper message based on what we expected to have.
	_ExpPar:
		mov edi, ecx	; Save the current input symbol
		mov edx, ExpectedPar_msgLen
		mov ecx, ExpectedPar_msg
		mov ebx, stdout 
		mov eax, sys_write 
		int 0x80
		jmp _got
	_ExpCur:
		mov edi, ecx	; Save the current input symbol
		mov edx, ExpectedCur_msgLen
		mov ecx, ExpectedCur_msg
		mov ebx, stdout 
		mov eax, sys_write 
		int 0x80
		jmp _got
	_ExpSqr:
		mov edi, ecx	; Save the current input symbol
		mov edx, ExpectedSqr_msgLen
		mov ecx, ExpectedSqr_msg
		mov ebx, stdout 
		mov eax, sys_write 
		int 0x80
		jmp _got
_got:	; Check what we actually got as an input and print the proper message accordingly.
	cmp byte [edi], ')'
	je _gotPar
	cmp byte [edi], '}'
	je _gotCur
	cmp byte [edi], ']'
	je _gotSqr
	jmp _badExit
	_gotPar:
		mov edx, gotPar_msgLen
		mov ecx, gotPar_msg
		mov ebx, stdout 
		mov eax, sys_write 
		int 0x80
		jmp _badExit
	_gotCur:
		mov edx, gotCur_msgLen
		mov ecx, gotCur_msg
		mov ebx, stdout 
		mov eax, sys_write 
		int 0x80
		jmp _badExit
	_gotSqr:
		mov edx, gotSqr_msgLen
		mov ecx, gotSqr_msg
		mov ebx, stdout 
		mov eax, sys_write 
		int 0x80
		jmp _badExit
_exit:	; Check for the 0 that is at the bottom of the stack. If it's at the top, all input was processed successfully. 
	pop eax
	cmp eax, '0'
	je _goodExit
	jne _badExit	; Redundant, put it there in case I move stuff around later.
	_badExit:
		mov edx, lineNum_msgLen      	; Setup sys_write line number
		mov ecx, lineNum_msg
		mov ebx, stdout 
		mov eax, sys_write 
		int 0x80 
		mov edx, 0x01      	; Setup sys_write line number
		mov ecx, cnt
		mov ebx, stdout 
		mov eax, sys_write 
		int 0x80 
		mov edx, badExit_msgLen      	; Setup sys_write for bad exit
		mov ecx, badExit_msg
		mov ebx, stdout 
		mov eax, sys_write 
		int 0x80 
		mov ebx, 0x00				; Exit
		mov eax, 0x01
		int 	 0x80
	_goodExit:	
		mov edx, goodExit_msgLen      	; Setup sys_write for clean exit
		mov ecx, goodExit_msg
		mov ebx, stdout 
		mov eax, sys_write 
		int 0x80 
		mov ebx, 0x00				; Exit
		mov eax, 0x01
		int 	 0x80
section .data	; Lots of messages for the different cases. I'm sure this can be refined later.
	Welcome_msg     DB      "Matching brackets...",0x0A
	Welcome_msgLen  equ   	$ - Welcome_msg
	Error_msg		DB	  	"Error!",0x0A
	Error_msgLen	equ	  	$ - Error_msg
	goodExit_msg	DB		"Brackets Match!",0x0A,"Exiting program...",0x0A
	goodExit_msgLen	equ	  	$ - goodExit_msg
	badExit_msg		DB	  	0x0A,"Bracket left unmatched!",0x0A,"Exiting program...",0x0A
	badExit_msgLen	equ	  	$ - badExit_msg
	ExpectedPar_msg	DB		"Error. Expected a )"
	ExpectedPar_msgLen	equ	  	$ - ExpectedPar_msg
	gotPar_msg		DB		" and got a )."
	gotPar_msgLen	equ	  	$ - gotPar_msg
	ExpectedCur_msg	DB		"Error. Expected a }"
	ExpectedCur_msgLen	equ	  	$ - ExpectedCur_msg
	gotCur_msg		DB		" and got a }."
	gotCur_msgLen	equ	  	$ - gotCur_msg
	ExpectedSqr_msg	DB		"Error. Expected a ]"
	ExpectedSqr_msgLen	equ	  	$ - ExpectedSqr_msg
	gotSqr_msg		DB		" and got a ]."
	gotSqr_msgLen	equ	  	$ - gotSqr_msg
	lineNum_msg		DB		" Line number: "
	lineNum_msgLen	equ	  	$ - lineNum_msg
section .bss
	sys_read   	equ  0x03 
	sys_write  	equ  0x04 
	stdin     	equ  0x00 
	stdout     	equ  0x01 
	stderr     	equ  0x02 
	new_line	equ	 0x0A
	inBuffer   	resb 0x04
	cnt			resb 0x01
