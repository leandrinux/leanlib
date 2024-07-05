
    mov ax, 0
    mov ebx, 200
    xor [ebx], [ebx] 
loop:
    out 0, al
    add ax, 1
    add [ebx], ax
    jl 10, loop
    mov cx, 100
    mov [cx-90], cx 
