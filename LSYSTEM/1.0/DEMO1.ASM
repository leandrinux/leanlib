
    mov ax, 0 
loop:
    out 0, al
    add ax, 1
    jl 10, loop
