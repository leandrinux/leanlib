.data

def count=10

.code

  mov ecx, count
loop:
  call hello
  sub ecx, 1
  jnz loop
  jmp end

hello:
  out 1, 'H'
  out 1, 'e'
  out 1, 'l'
  out 1, 'l'
  out 1, 'o'

  out 1, 13
  out 1, 10
  ret

end:
  mov eax, 0
