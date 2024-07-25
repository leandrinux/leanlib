.code

  jerr error

loop:
  push 100
  jmp loop

error:
  sub ax, 100
  add ax, '0'
  out 1, al
  out 1, 7

  