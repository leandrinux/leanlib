/*
  this is an example assembly file

*/
main:  // the entry point for this program - this is mandatory
  xor eax, eax     // effectively sets eax with the value 0
  add ax, 0xFFFF   // adds $FFFF to ax, making it equal to ax
  add eax, $FFFF_0000 // it adds $FFFF0000 to eax, making it equal to $FFFFFFFF

/*
  main is a label and it basically represents the position in memory of the
  first instruction to be executed. As such, main is a number and like any number
  it can be used as a literal. for instance, i could set a register with the value
  stored in main. All labels are addresses and as such are 32 bit.

  main is NOT a function, even though we may think of labels as functions
*/

  mov ebx, main    // moves the address of the first instruction to bx
  current: mov ecx, current  // moves the address of this instruction to cx
  sub ebx, ecx // we just got the size in bytes of the code between main and current

/*
  but we can also use labels that are set later in code
  for instance, we can set a dummy instruction at the end of the program
  and assign a label to it, but use it before
*/
  mov edx, last
  sub edx, main

  last: xor eax, eax


