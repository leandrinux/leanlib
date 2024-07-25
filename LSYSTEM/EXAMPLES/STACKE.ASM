.code

  jerr error

  push 10
  push 20
  push 30

loop:
  pop eax
  jmp loop

error:
  sub ax, 100
  add ax, '0'
  out 1, al
  out 1, 7
