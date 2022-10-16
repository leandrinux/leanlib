{
  debug Unit
  Tools for measuring time, testing and improving code performance
  2022 LRT
}
{$IFDEF DEBUG}
unit
  debug;

interface

  uses
    xcrt, types, consts, int10;

  procedure cronometerOn;
  procedure cronometerLap;
  procedure cronometerOff;
  procedure initCounter(i: byte; name: string10);
  procedure incCounter(i: byte);
  procedure summary;


implementation

  const
    C_COUNTER_COUNT = 4;

  type
    TCounter = record
      name: string10;
      value: longint;
    end;

  var
    counters: array[0..C_COUNTER_COUNT-1] of TCounter;
    ticks: longint;
    accum: longint;
    count: longint;
    avg: longint;

  procedure cronometerOn;
  begin
    ticks := C_TICKS^;
    accum := 0;
    count := 0;
    avg := 0;
  end;

  procedure cronometerLap;
  var
    t: longint;
  begin
    t := C_TICKS^;
    accum := accum + t - ticks;
    count := count + 1;
    ticks := t;
  end;

  procedure cronometerOff;
  begin
    avg := accum div count;
  end;

  procedure initCounter(i: byte; name: string10);
  begin
    counters[i].name := name;
    counters[i].value := 0;
  end;

  procedure incCounter(i: byte);
  begin
    inc(counters[i].value);
  end;

  procedure summary;
  const
    C_TEXT_MODE = C_VIDMODE_CGA_T_80x25_16;
  var
    i: byte;
    time: real;
  begin
    cronometerOff;
    if getVideoMode > C_TEXT_MODE then setVideoMode(C_TEXT_MODE);

    if count>0 then
    begin
      time := avg * 54.925;
      writeln('Cron count:', count,', avg: ', avg, ' ticks (', time:2:2, ' msec)');
    end;

    for i:=0 to C_COUNTER_COUNT-1 do
      with counters[i] do
        if name <> '' then
          writeln(name, ': ', value);
    readkey;
    halt(1);
  end;

begin
  cronometerOn;
  fillchar(counters, sizeof(counters), 0);
end.
{$ELSE}
unit debug;
interface
implementation
end.
{$ENDIF}