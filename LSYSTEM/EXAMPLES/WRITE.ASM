.data
  
#define value 100

.code

    mov eax, value
  loop:
    call write_int32
    mov bl, 32
    out 1, bl
    sub eax, 1
    jnz loop
    call write_int32
    jmp end

  write_int32:
    push eax
    xor edx, edx
    cmp eax, 0
    jp get_digit
    mov ebx, 45
    out 1, bl
    not eax
    add eax, 1
  get_digit:
    mov ebx, eax
    div ebx, 10
    mov ecx, eax
    mov eax, ebx
    mul ebx, 10
    sub ecx, ebx
    add ecx, 48
    push ecx
    add edx, 1
    jl 0, get_digit
  write_digit:
    pop ecx
    out 1, cl
    sub edx, 1    
    jnz write_digit
    pop eax
    ret

  end:
    xor ax, ax
