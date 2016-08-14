BITS 32
global _start
_syscalls:
	sys_write equ 0x4
	sys_getcwd equ 0xb7

section .bss
	buffer resb 4096

section .text
_start:
	pop ecx ;Arg count
	add esp, 4 ;remove program name from stack
	dec ecx
	jz _mode_l ;No arguments? Then default
	_arg_loop:
		pop edi
		dec ecx
		jnz _arg_loop ;Only the last argument should be counted, ignore invalids
	mov eax, [edi]
	bswap eax
	xor al,al ;Remove last character
	;time to parse
	cmp eax, `\0\0P-`
	je _mode_p
	;Default to -L behaviour for invalid arguments or -L

_mode_l:
	add esp, 4 ;remove the null from the stack
	;Loop through envp until we find PWD=
	_pwd_find:
		pop edi
		cmp dword [edi], `PWD=`
		jne _pwd_find
	add edi, 4
	;edi now holds the value of PWD

;takes edi, appends newline and prints
_print_result:
	_strlen:
		mov esi, -16
		_strlen_loop:
			add esi, 16
			pcmpistri xmm0, [edi+esi],8
			jnz _strlen_loop
		add esi, ecx
	;Append the new line
	mov byte [edi+esi],`\n`
	inc esi
	
	;esi holds length
	mov eax, sys_write
	mov ebx, 1 ;stdout
	mov ecx, edi;buffer
	mov edx, esi ;length
	push _exit
	lea ebp, [esp-12] ;esp-12 because we don't care what gets put in those registers after, so just use any stack garbage, this is smaller than a bunch of pushes
	sysenter

_exit:
	mov eax, 1
	xor ebx,ebx
	;We've already mov'd esp into ebp, no need to do it again
	sysenter

_mode_p:
	;So it can both printed and used in sys_getcwd
	;doing it here means we can get the syscall to jump us back
	;no extra jump call needed!
	mov edi, buffer
	
	mov eax, sys_getcwd
	mov ebx, edi
	mov ecx, 4096
	push _print_result
	lea ebp, [esp-12]
	sysenter
