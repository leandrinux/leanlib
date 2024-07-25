# this program displays on screen how many bytes of RAM the system has

.data
  
  def RAM_DEVICE = 0
  def ECHO_DEVICE = 1 
  def CMD_GET_SIZE = 1 

.code

  # main program

    out RAM_DEVICE, CMD_GET_SIZE
    in RAM_DEVICE, eax

    out ECHO_DEVICE, 'M'
    out ECHO_DEVICE, 'e'
    out ECHO_DEVICE, 'm'
    out ECHO_DEVICE, ':' 
    out ECHO_DEVICE, ' ' 
    call write_int32

    jmp end            # ends the program


  # this function will print on screen a signed 32 bit integer stored in eax

  write_int32:
    push eax           # preserve the value of the counter
    xor edx, edx       # edx becomes zero. It will be our digit counter. For 4321 it will become 4
    jz get_digit       # if the value is positive then proceed to write the number
    out 1, '-'         # if not, add a preceding minus sign
    not eax
    add eax, 1         # performs base complement + 1 to turn negative value into positive 

  get_digit:           # let's assume eax contains 123 
    mov ecx, eax       # ecx becomes 123
    div eax, 10        # eax becomes 12 -> this is the number for the next iteration
    mod ecx, 10        # ecx becomes the remainder of 123 / 10 which is 3, the digit to be printed
    add ecx, '0'       # 3 is added the ascii code for 0, becoming the character '3'
    push ecx           # the character '3' is stored in the stack
    add edx, 1         # increment the digit counter
    jl 0, get_digit    # if 0 is smaller than eax (now 12) then it must continue adding characters

  write_digit:         # now all the characters are in the stack
    pop ecx            # we take the last digit added to the stack
    out ECHO_DEVICE, cl      # we print the digit
    sub edx, 1         # we decrement the digit counter
    jnz write_digit    # if the counter is not zero we keep printing digits
    out ECHO_DEVICE, ' '     # add a space after the number
    pop eax            # finally we restore the counter value we had saved at the beginning
    ret                # our task here is done 

  end:
    xor ax, ax
