uses
  lcommon, lbin, lrt;

const
  C_CMD_QUIT = 'quit';
  C_ERR_UNRECOGNIZED = 'Unrecognized command';

var
  systemState: TSystemState;

function parseCommand(var cmd: string): boolean;
begin
  parseCommand := true;
  if (cmd = '') or (cmd = C_CMD_QUIT) then exit;
  
  parseCommand := false;
end;

procedure readCommands;
var
  cmd: string;
begin
  repeat
    write('> ');
    readln(cmd);
    if not parseCommand(cmd) then writeln(C_ERR_UNRECOGNIZED);
  until cmd = C_CMD_QUIT;
end;

begin
  fillchar(systemState, sizeof(TSystemState), 0);
  writeln('lrt interactive shell version ', C_SYSTEM_VERSION);
  readCommands;
end.