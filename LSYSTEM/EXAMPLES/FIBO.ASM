.code

    xor edx, edx
    call line_no
    mov eax, 48
    out 1, al
    call eoln

    mov edx, 1
    call line_no
    mov eax, 49
    out 1, al
    call eoln

    xor ebx, ebx
    mov ecx, 1
  loop:
    mov eax, ebx
    add eax, ecx
    add edx, 1
    cmp edx, 47
    jz end
    call line_no
    call write_uint32
    call eoln
    mov ebx, ecx
    mov ecx, eax
    jmp loop

  write_uint32:
    pusha 
    xor edx, edx
    push 0
  _get_digit:
    cmp edx, 3
    jnz _next
    push 46
    xor edx, edx
  _next:  
    add edx, 1
    mov ebx, eax
    div ebx, 10
    mov ecx, eax
    mov eax, ebx
    mul ebx, 10
    sub ecx, ebx
    add ecx, 48
    push ecx
    jl 0, _get_digit
  _write_digit:
    pop ecx
    cmp ecx, 0
    jz _end
    out 1, cl
    jmp _write_digit
  _end:  
    popa 
    ret 

  eoln:
    push eax
    mov al, 13
    out 1, al
    mov al, 10
    out 1, al
    pop eax
    ret

  line_no: 
    push eax
    mov eax, 70
    out 1, al
    mov eax, edx
    call write_uint32
    mov eax, 58
    out 1, al
    mov eax, 61
    out 1, al
    mov eax, 32
    out 1, al
    pop eax
    ret

  end:
    xor eax, eax
