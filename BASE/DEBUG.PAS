{
  Datetime Unit
  Used to show debug information
  2022 LRT
}
unit
  debug;

interface

  procedure dbg_writehex(ptr: pointer; length: word);
  function dbg_clock: longint;

implementation

  uses
    utils;

  procedure dbg_writehex(ptr: pointer; length: word);
  var
    i: word;
    p: ^byte;
  begin
    p := ptr;
    for i:= 0 to length - 1 do
    begin
      write(byteToHex(p^));
      if (i and $000F) = 0 then writeln else write(' ');
      inc(p);
    end;
    writeln;
  end;

  function dbg_clock: longint; assembler;
  { Copyright (c) 1989-1993 Norbert Juffa } 
  asm
    PUSH    DS              { save caller's data segment }
    MOV     AX, 0040h       { set DS to BIOS data segment to }
    MOV     DS, AX          {  access ticker counter }
    MOV     BX, 6Ch         { offset of ticker counter in segm.}
    MOV     DX, 43h         { timer chip control port }
    MOV     AL, 4           { freeze timer 0 }
    PUSHF                   { save caller's int flag setting }
    CLI                     { make reading counter an atomic operation}
    MOV     DI, DS:[BX]     { read BIOS ticker counter lo word }
    MOV     CX, DS:[BX+2]   { read BIOS ticker counter hi word }
    STI                     { enable update of ticker counter }
    OUT     DX, AL          { latch timer 0 }
    NOP                     { wait for }
    NOP                     {  possible ticker }
    NOP                     {   counter update }
    NOP                     {    interrupt }
    NOP                     {     to arrive }
    CLI                     { make reading counter an atomic operation}
    MOV     SI, DS:[BX]     { read BIOS ticker counter lo word }
    MOV     BX, DS:[BX+2]   { read BIOS ticker counter hi word?}
    IN      AL, 40h         { read latched timer 0 lo-byte }
    MOV     AH, AL          { save lo-byte }
    IN      AL, 40h         { read latched timer 0 hi-byte }
    POPF                    { restore caller's int flag }
    XCHG    AL, AH          { correct order of hi and lo }
    CMP     DI, SI          { ticker counter updated ? }

    OR      AX, AX          { update before timer freeze ? }

    MOV     DI, SI          { use second }

    MOV     BX, 36EDh       { load multiplier }
    MUL     BX              { W1 * M }
    MOV     SI, DX          { save W1 * M (hi) }
    MOV     AX, BX          { get M }
    MUL     DI              { W2 * M }
    XCHG    BX, AX          { AX = M, BX = W2 * M (lo) }
    MOV     DI, DX          { DI = W2 * M (hi) }
    ADD     BX, SI          { accumulate }
    ADC     DI, 0           {  result }
    XOR     SI, SI          { load zero }
    MUL     CX              { W3 * M }
    ADD     AX, DI          { accumulate }
    ADC     DX, SI          {  result in DX:AX:BX }
    MOV     DH, DL          { move result }
    MOV     DL, AH          {  from DL:AX:BX }
    MOV     AH, AL          {   to }
    MOV     AL, BH          {    DX:AX:BH }
    MOV     DI, DX          { save result }
    MOV     CX, AX          {  in DI:CX }
    MOV     AX, 25110       { calculate correction }
    MUL     DX              {  factor }
    SUB     CX, DX          { subtract correction }
    SBB     DI, SI          {  factor }
    XCHG    AX, CX          { result back }
    MOV     DX, DI          {  to DX:AX }
    POP     DS              { restore caller's data segment }
  end; 

begin
  writeln('Using debug unit');
  Port[$43] := $34;         { need rate generator, not square wave }
  Port[$40] := 0;           { generator as programmed by some BIOSes }
  Port[$40] := 0;           { for timer 0 } 
end.
