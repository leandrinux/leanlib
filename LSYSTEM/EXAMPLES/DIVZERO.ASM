
.code

  jerr error

main:
  mov ax, 1000
  mov bx, 5

loop:
  div ax, bx
  sub bx, 1
  cmp bx, -1
  jnz loop

error:
  sub ax, 100
  add ax, 48
  out 1, al
  out 1, 7
  
end:
  jmp end
