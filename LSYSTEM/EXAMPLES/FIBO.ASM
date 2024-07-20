# this program generates the first 46 numbers of the fibonacci sequence
# where a number equals the sum of the two predecessors

.data 
  
  define C_CR 13
  define C_LF 10
  define C_SPACE 32
  define C_EQUAL 61

.code

    # this is a comment before the operation name
    xor edx, edx     # set edx to 0
    call line_no     # print the line number
    out 1, 48        # print 0
    call eoln        # print CRLF

    mov edx, 1       # set edx to 1
    call line_no     # print the line number
    out 1, 49        # print 1
    call eoln        # print CRLF

    xor ebx, ebx     # set ebx to 0  (first value in the sequence)
    mov ecx, 1       # set ecx to 1  (second value in the sequence)
  loop:
    mov eax, ebx     
    add eax, ecx     # eax = ebx + ecx
    add edx, 1       # increment the line number
    cmp edx, 47
    jz end              # if the line number is 47 then end program
    call line_no        # print the line number
    call write_uint32   # print the value calculated in eax
    call eoln           # print CRLF
    mov ebx, ecx
    mov ecx, eax     # shift the values of the sequence
    jmp loop         # continue with the next value

  write_uint32:      # prints a unsigned 32 bit integer
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

  eoln:                 # prints CRLF
    push eax
    out 1, C_CR
    out 1, C_LF
    pop eax
    ret

  line_no:              # prints the number contained in edx
    push eax
    mov eax, 70
    out 1, al
    mov eax, edx
    call write_uint32
    out 1, C_SPACE
    out 1, C_EQUAL
    out 1, C_SPACE
    pop eax
    ret

  end:
    xor eax, eax
