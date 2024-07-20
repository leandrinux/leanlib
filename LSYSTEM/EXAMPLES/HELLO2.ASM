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
  mov al, 72
  out 1, al
  mov al, 69
  out 1, al
  mov al, 76
  out 1, al
  out 1, al
  mov al, 79
  out 1, al

  mov al, 13
  out 1, al
  mov al, 10
  out 1, al
  ret

end:
  mov eax, 0
