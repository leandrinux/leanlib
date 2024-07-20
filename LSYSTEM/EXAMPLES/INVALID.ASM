
.code
    jerr error

  main:
    mov ax, 1
    jmp main

  error:
    sub ax, 100
    add ax, 48
    out 1, al
    out 1, 7
