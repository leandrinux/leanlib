uses
  xcrt, sprocess, ssystem;

type
  PMyProcess = ^TMyProcess;
  TMyProcess = object(TProcess)
    public 
      procedure setup; virtual;
      procedure loop; virtual;
      procedure kill; virtual;
    private
      _counter: word;
  end;

procedure TMyProcess.setup;
begin
  _counter := 0;
end;

procedure TMyProcess.loop;
begin
  writeln(_counter);
  inc(_counter);
end;

procedure TMyProcess.kill;
begin
  writeln('You killed me, you monster.');
end;

var
  proc: PMyProcess;

begin
  proc := new(PMyProcess, init);
  runp(proc);
  proc^.release;
  writeln('Press a key to end.');
  readkey;
end.