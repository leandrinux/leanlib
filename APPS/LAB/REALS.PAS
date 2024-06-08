(*
    Real -> 6 bytes (48 bit)
    https://moddingwiki.shikadi.net/wiki/Turbo_Pascal_Real
    https://www.oreilly.com/library/view/delphi-in-a/1565926595/re260.html
    Byte 	0 	        1 	        2 	        3        	4        	5
    Bit 	01234567 	01234567 	01234567 	01234567 	01234567 	01234567
    Value 	EEEEEEEE 	MMMMMMMM 	MMMMMMMM 	MMMMMMMM 	MMMMMMMM 	SMMMMMMM
    The Real48 type has an 8-bit exponent and a 39-bit normalized mantissa. 
    It cannot store denormalized values, infinity, or not-a-number. If the exponent is zero, the number is zero.

    single -> 4 bytes (32 bit) IEEE754 format
    https://www.omnicalculator.com/other/floating-point#the-single-precision-32-bit-float-format

    https://github.com/fpc/FPCSource/blob/e2ed90d40f658b13c492c7191b71ce76e6da5bd4/rtl/jvm/math.inc#L87
    function real2double(r : real48) : double;
    var
        res : jlong;
        exponent : word;
    begin
        { check for zero }
        if r[0]=0 then
        begin
            real2double:=0.0;
            exit;
        end;

        { copy mantissa }
        res:=(r[1] shl 5) shl 8;
        res:=res or (((r[1] shr 3) or (r[2] shl 5)) shl 16);
        res:=res or (((r[2] shr 3) or (r[3] shl 5)) shl 24);
        res:=res or (((r[3] shr 3) or (r[4] shl 5)) shl 32);
        res:=res or (((r[4] shr 3) or (r[5] and $7f) shl 5) shl 40);
        res:=res or (((r[5] and $7f) shr 3) shl 48);

        { copy exponent }
        { correct exponent: }
        exponent:=(word(r[0])+(1023-129));
        res:=res or (((exponent and $f) shl 4) shl 48);
        res:=res or ((exponent shr 4) shl 56);

        { set sign }
        res:=res or (r[5] and $80) shl 56;
        real2double:=JLDouble.longBitsToDouble(res);
    end;

*)

function real2single(r : real) : single;
type
    PReal = ^TReal;
    TReal = array[0..5] of byte;
var
    bytes: PReal;
    res : single;
    exponent : word;
begin
    bytes := @r;
    { check for zero }
    if bytes^[0]=0 then
    begin
        real2
        single:=0.0;
        exit;
    end;

    { copy mantissa }
    res:=(r[1] shl 5) shl 8;
    res:=res or (((r[1] shr 3) or (r[2] shl 5)) shl 16);
    res:=res or (((r[2] shr 3) or (r[3] shl 5)) shl 24);
    res:=res or (((r[3] shr 3) or (r[4] shl 5)) shl 32);
    res:=res or (((r[4] shr 3) or (r[5] and $7f) shl 5) shl 40);
    res:=res or (((r[5] and $7f) shr 3) shl 48);

    { copy exponent }
    { correct exponent: }
    exponent:=(word(r[0])+(1023-129));
    res:=res or (((exponent and $f) shl 4) shl 48);
    res:=res or ((exponent shr 4) shl 56);

    { set sign }
    res:=res or (r[5] and $80) shl 56;
    real2double:=JLDouble.longBitsToDouble(res);
end;

type
  PReal64 = ^TReal64;
  TReal64 = packed record
    exp: byte;
    m4, m3, m2, m1, m0: byte;
  end;

var
  r: real;
  s: single;
  p: PReal64;

const
  pi: real = 3.1415926; { 31415926 * 10^-7 } 
  value: real = 1.1;

var
  mantissa: longint;

begin
  p := @value;
  writeln('value: ', value);
  writeln;
  with p^ do
  begin
    writeln('exp  :', exp - 129);
    writeln('m4   :', m4);
    writeln('m3   :', m3);
    writeln('m2   :', m2);
    writeln('m1   :', m1);
    writeln('m0   :', m0 and $7F);
    writeln('sign :', m0 shr 7);

    m0 := m0 and $7F;   
  end;
  readln;
end.