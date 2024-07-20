.code

  jerr error

loop:
  push 100
  jmp loop

error:
  sub ax, 100
  add ax, 48
  out 1, al
  out 1, 7
end:
  jmp end