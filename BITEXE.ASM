.model huge
.stack 100h
.data
BMP_PALLETE db 100h*4h dup(?)
BMP_BUFFOR  db 320*200 dup(?)
BMP_HEADER  db 36h dup(?)
FILE_NAME   db 'a.bmp',0
handle      dw ?
.code

OpenFile macro _filename, _handle
	mov ah,3dh
	mov dx,offset _filename
	mov al,0
	int 21h
	mov _handle,ax
endm

CloseFile macro _handle
	mov bx,_handle
	mov ah,3eh
	int 21h
endm

ReadFile macro _handle, _buffer, _count
	mov bx,handle
	mov cx,_count
	mov dx,offset _buffer
	mov ah,3fh
	int 21h
endm

InitGraph macro _mode
	xor ah,ah
	mov al,_mode
	int 10h	
endm

GetChar macro
	mov ah,07h
	int 21h
endm

SetBMPPallete macro _bmppalletebuffer
	mov cx,256
	mov al,0
	mov si,offset _bmppalletebuffer
	call setpallete
endm

screen_delay proc
	mov dx,3dah
_wait:
	in al,dx
	test al,8
	je _wait
	ret
endp


setpallete proc
	set_pal:
		mov dx,03c8h
		out dx,al
		push ax
		inc dx
		mov al,byte ptr [si+2]
		shr al,2
		out dx,al
		mov al,byte ptr [si+1]
		shr al,2
		out dx,al
		mov al,byte ptr [si]
		shr al,2
		out dx,al
		add si,4
		pop ax
		inc al
		loop set_pal
		ret
endp

start:
mov ax,@data
mov ds,ax
OpenFile FILE_NAME,handle
ReadFile handle,BMP_HEADER,36h
ReadFile handle,BMP_PALLETE,100h*4h
ReadFile handle,BMP_BUFFOR,320*200
CloseFile handle
InitGraph 13h
SetBMPPallete BMP_PALLETE
call screen_delay
mov si,offset BMP_BUFFOR
mov dx,0a000h
mov es,dx
mov cx,200
petla:
push cx
dec cx
mov ax,cx
mov cx,320
mov bx,320
mul bx
mov di,ax
line:
mov al,byte ptr [si]
mov es:[di],al
inc di
inc si
loop line
pop cx
loop petla

GetChar
InitGraph 3h
mov ah,4ch
int 21h
end start