.code

main:
  call hello
  call hello
  call hello

end: 
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