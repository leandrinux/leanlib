.data

define count 10

.code

  mov ecx, count
loop:
  call hello
  sub ecx, 1
  jnz loop
  jmp end

hello:
  out 1, 72
  out 1, 69
  out 1, 76
  out 1, 76
  out 1, 79

  out 1, 13
  out 1, 10
  ret

end:
  mov eax, 0
