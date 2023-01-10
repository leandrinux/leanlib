uses
  xcrt, uspeaker;

var
  spk: PSpeaker;

begin
  spk := new(PSpeaker, init);
  with spk^ do
  begin
    writeln('Press a key to play'); readkey;
    setTone(EToneWah);
    sound(500);
    sound(1000);
    sound(1200);
    sound(1500);
    sound(1800);
    sound(2000); delay(40);
    silence;
    writeln('Press a key to play'); readkey;
    setTone(EToneDing);
    sound(500);
    sound(1000);
    sound(1200);
    sound(1500);
    sound(1800);
    sound(2000); delay(40);
    silence;
    release;
  end;
end.