var
  currentDirectory: string;
begin
  getDir(0, CurrentDirectory);
  writeln('set currentdir=', CurrentDirectory);
end.