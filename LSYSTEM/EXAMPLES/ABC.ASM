.data

 define device 1
 define count 26

.code

  mov al, count
  mov ah, 'A'
loop:
  out device, ah
  add ah, 1
  sub al, 1
  jnz loop

end: 
  jmp end
