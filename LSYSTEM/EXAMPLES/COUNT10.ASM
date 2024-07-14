.data

#define count 10
#define device 1

.code

  mov al, count
loop:
  out device, al
  sub al, 1
  jnz loop

end: 
  jmp end
