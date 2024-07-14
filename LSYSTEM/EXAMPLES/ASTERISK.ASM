.code
  mov al, 42
loop:
  out 1, al
  jmp loop
