.model huge
.code
org 100h

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

start:

OpenFile FILE_NAME,handle
ReadFile handle,BMP_HEADER,36h
ReadFile handle,BMP_PALLETE,100h*4h
ReadFile handle,BMP_BUFFOR,320*200
CloseFile handle
InitGraph 13h
; call screen_delay
SetBMPPallete BMP_PALLETE



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

;mov dx,3d4h
;mov al,0ch
;mov ah,0afh
;out dx,ax
;inc al
;mov ah,00h
;out dx,ax

GetChar
InitGraph 3h
ret

setpallete proc far
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

BMP_PALLETE db 100h*4h dup('0')
BMP_BUFFOR  db 320*200 dup('0')
BMP_HEADER db 36h dup('0')
FILE_NAME db 'a.bmp',0
handle dw ?

screen_delay proc
	mov dx,3dah
_wait:
	in al,dx
	test al,8
	je _wait
	ret
endp


end start