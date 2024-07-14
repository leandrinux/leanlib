.data

#define device 1
#define count 26
#define letter_A 65

.code

  mov al, count
  mov ah, letter_A
loop:
  out device, ah
  add ah, 1
  sub al, 1
  jnz loop

end: 
  jmp end
