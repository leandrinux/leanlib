const
  code: array[0..42] of byte = (
    $55, $89, $E5, $31, $C0, $9A, $CD, $02,
    $6A, $08, $BF, $98, $01, $1E, $57, $B8,
    $FE, $CA, $BA, $BE, $BA, $52, $50, $31,
    $C0, $50, $9A, $89, $07, $6A, $08, $9A,
    $FE, $05, $6A, $08, $9A, $91, $02, $6A, 
    $08, $5D, $CB
  );

type
  TProc = procedure;

var
  proc: TProc;
  p: pointer;

begin
   p := @code;
   proc := TProc(p);
   proc;
end.