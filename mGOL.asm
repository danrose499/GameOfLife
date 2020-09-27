; The location of this template is c:\emu8086\inc\0_com_template.txt
code segment
assume CS:code
    org 100h
start:
jmp realstart
    grid1 db 4000 dup(79)
    grid2 db 4000 dup(79)
    filename DB "C:\save.txt",0
    handle dw ?
    errmsg DB "Error!",13,10,"$"
    instructions db "                          Welcome to THE GAME OF LIFE!                          "
                 db "Use the ARROW keys to move around the board and press SPACE to toggle a cell.   "
                 db "Press S to save the current board layout, and L to load the most recently saved "
                 db "board. When you want to begin the game, press ENTER.                            "
                 db "Enter any key to create the board:$"

printGrid:             ; PROC: Prints grid1 to video
    mov ax, 0b800h
    mov es, ax         ; es=>video!
    mov cx, 4000
    sub bx, bx
    sub si, si
    mov ah, 71h        ; 7=white/light grey, 1=blue
print:
    mov al, grid1[si]
    mov word ptr ES:[bx],ax
    add bx, 2
    inc si
    loop print
    RET

updateGrid:            ; PROC: Goes through each cell and calls updateCell proc at each one
    mov di, 79         ; di = index for update
    mov cx, 48         ; 48 = Inner Rows (50 Total)
l1: add di, 2          ; jump to next row
    mov dx, cx
    mov cx, 78         ; 78 = Inner columns (80 Total)
l2: CALL updateCell    ; CALLS function  to update grid2[si] based on grid1[si]
    inc di             ; Move to the next column
    loop l2
    mov cx, dx         ; Restores cx for l1 call
    loop l1
    RET

updateCell:            ; PROC: updates cell in grid2[di] based on corresponding number of neighbors in grid1[di]
    call neighbors     ; Counts neighbors of cell grid[di] and stores number in bx
    mov ah, grid1[di]
    mov grid2[di], ah  ; sets grid2[di] to grid1[di]
    cmp grid1[di], 254 ; Checks if cell grid1[di] is alive
    jnz dead
    cmp bx, 2          ; This path is for a live cell
    jae up1
    call toggle        ; A live cell dies with less than 2 live neighbors
    RET
up1:cmp bx, 3
    jbe up2
    call toggle        ; A live cell dies with more than 3 live neighbors
    RET
dead:
    cmp bx, 3          ; This path is for a dead cell
    jnz up2
    call toggle        ; A dead cell becomes alive with exactly 3 live neighbors
up2:RET

neighbors:       ; PROC: gets number of neighbors for each cell in grid1 and stores the number in bx
    sub bx, bx   ; bx = number of alive neighbors
    mov si, di   ; si is used to index neighboring cells of ax
    sub si, 81   ; si = Top left corner
    cmp grid1[si], 254
    jnz c1
    inc bx
c1: inc si       ; si = Top middle
    cmp grid1[si], 254
    jnz c2
    inc bx
c2: inc si       ; si = Top right
    cmp grid1[si],254
    jnz c3
    inc bx
c3: add si, 78   ; si = Middle left
    cmp grid1[si],254
    jnz c4
    inc bx
c4: add si, 2    ; si = Middle right
    cmp grid1[si], 254
    jnz c5
    inc bx
c5: add si, 78   ; si = Bottom left
    cmp grid1[si], 254
    jnz c6
    inc bx
c6: inc si       ; si = Bottom middle
    cmp grid1[si], 254
    jnz c7
    inc bx
c7: inc si       ; si = Bottom right
    cmp grid1[si], 254
    jnz c8
    inc bx
c8: RET

toggle:          ; PROC: toggles a cell in grid2 from updateCell based on rules
    xor grid2[di], 177
    RET

setGrid:
    mov cx, 4000
    mov si, 0
s:  mov ah, grid2[si]
    mov grid1[si],ah
    inc si
    loop s
    RET

saveGrid:        ; PROC: saves current grid layout to file
    mov dx, offset filename
    mov ax, 3d01h; open for write
    int 21h
    jc error     ; file not found
    mov handle, ax

    mov bx, ax   ; bx = handle
    mov ah, 40h  ; 40h = write to file
    mov cx, 8000 ; grid = 50x80, x2 bytes
    mov dx, offset grid1
    int 21h      ; writes grid1 to file save.dat
    jc error

    mov ah, 3eh
    mov bx, handle
    int 21h      ; close file
    RET

loadSave:        ; PROC: reads saved file into board1
    mov dx, offset filename
    mov ax, 3d00h; open for read
    int 21h
    jc error     ; file not found
    mov handle, ax

    mov cx, 8000 ; grid = 50x80, x2 bytes
    mov dx, offset grid1
    mov bx, ax
    mov ah, 3fh
    int 21h      ; reads file save.dat to grid1

    mov ah, 3eh
    mov bx, handle
    int 21h      ; close file
    RET

error:
    mov ah, 09
    mov dx, offset errmsg
    int 21h
    mov ax, 4cffh
    int 21h      ; terminate


; CODE BEGIN
realstart:

; Game Instructions
   ; mov ax, 1202h
   ; mov bl, 30h
   ; int 10h

   ; mov ax, 0003h
   ; int 10h

    mov ax, 1112h
    xor bx, bx
    int 10h


    mov dx, offset filename
    mov ax, 3c02h
    mov cx, 0
    int 21h                 ; Creates file 'save.dat,' if it doesn't already exist
    jc error

    mov ah, 09h             ; Outputs string
    mov dx, offset instructions
    int 21h
    mov ah, 1
    mov ch, 20h
    int 10h                 ; Turns off caret
    mov ah, 00h
    int 16h                 ; Waits for input (input is ignored)
; Board Input
    CALL printGrid          ; Prints grid empty grid (dead cells)
    sub si, si              ; "Cursor" to keep track of position
    sub bx, bx
    mov byte ptr ES:[1],37h ; Cursor Highlight, 3=cyan, 7=white
select:
    mov ah, 00h
    int 16h                 ; Inputs selection
    cmp ax, 3920h           ; Space bar (toggle cell)
    jz space
    cmp ax, 4b00h           ; Left Arrow
    jz left
    cmp ax, 4d00h           ; Right Arrow
    jz right
    cmp ax, 5000h           ; Up Arrow
    jz up
    cmp ax, 4800h           ; Down Arrow
    jz down
    cmp ax, 1c0dh           ; Enter: Game begins!
    jz game
    cmp ax, 1f73h           ; S (saves board)
    jz save
    cmp ax, 266ch           ; L (loads board)
    jz load
    jmp select              ; Default input: loops back
space:
    xor grid1[si], 177      ; Toggles cell
    mov ah, grid1[si]
    mov byte ptr ES:[bx],ah ; Updates Cell
    jmp select
left:
    mov ch, 71h             ; Unhighlighted color
    mov cl, grid1[si]
    mov word ptr ES:[bx],cx ; Unhighlights original cell
    dec si
    sub bx, 2
    mov ah, 37h
    mov al, grid1[si]
    mov word ptr ES:[bx],ax
    jmp select
right:
    mov ch, 71h             ; Unhighlighted color
    mov cl, grid1[si]
    mov word ptr ES:[bx],cx ; Unhighlights original cell
    inc si
    add bx, 2
    mov ah, 37h
    mov al, grid1[si]
    mov word ptr ES:[bx],ax
    jmp select
up:
    mov ch, 71h             ; Unhighlighted color
    mov cl, grid1[si]
    mov word ptr ES:[bx],cx ; Unhighlights original cell
    add si,80
    add bx,160
    mov ah, 37h
    mov al, grid1[si]
    mov word ptr ES:[bx],ax
    jmp select
down:
    mov ch, 71h             ; Unhighlighted color
    mov cl, grid1[si]
    mov word ptr ES:[bx],cx ; Unhighlights original cell
    sub si, 80
    sub bx, 160
    mov ah, 37h
    mov al, grid1[si]
    mov word ptr ES:[bx],ax
    jmp select
save:                       ; Saves current display of board in file, then allows user to continue editing board
    push bx                 ; Saves current index of ES
    CALL saveGrid
    pop bx
    jmp select
load:                       ; Board is loaded from file, updated on screen, and then allows user to continue editing
    push bx
    push si
    CALL loadSave
    CALL printGrid          ; load continues into game
    pop si
    pop bx
    mov ch, 37h             ; Highlighted color
    mov cl, grid1[si]
    mov word ptr ES:[bx],cx ; Highlights cell
    jmp select
game:
    CALL updateGrid
    CALL setGrid
    CALL printGrid
    jmp game

    int 20h
; CODE END
code ends

    end start
