{
  This unit contains constants, types and methods that COULD be used
  in other programs because they are general enough
}
unit
  tputil;

interface

  type
    TPath = string[50];
    TFilename = string[12];

  procedure error(msg: string);
  procedure log(msg: string);
  function run(const cmd, cmdLine: string; hide: boolean): integer;
  procedure deleteFile(const filename: TFilename);
  function fileExists(const path: TPath; const filename: TFilename): boolean;
  function directoryExists(const dir: TPath): boolean;
  procedure createDirectory(const dir: TPath);
  function strAfterNull(const args: string; index: byte): string;
  function strformat(const str, args: string): string;

implementation

  uses
    {$IFDEF Spanish}tpstr_es,
    {$ELSE}tpstr_en,{$ENDIF}
    dos, execute;

  procedure error(msg: string);
  begin
    writeln('[X] ERROR: ', msg);
    halt(1);
  end;

  procedure log(msg: string);
  begin
    writeln('[-] ', msg);
  end;

  function run(const cmd, cmdLine: string; hide: boolean): integer;
  begin
    swapVectors;
    if hide then
      exec(cmd, cmdLine + '> NUL')
    else
      exec(cmd, cmdLine);
    if DOSError <> 0 then run := 1000 + DOSError else run := DOSExitCode;
    swapVectors;
  end;

  procedure deleteFile(const filename: TFilename);
  var
    regs: Registers;
    p: pointer;
    asciiz: array [0..12] of char;
    i: byte;
  begin
    regs.ah := $41;
    regs.ds := seg(asciiz);
    regs.dx := ofs(asciiz);
    p := Ptr(seg(filename), ofs(filename) + 1);
    move(p^, asciiz, length(filename));
    asciiz[length(filename)] := #0;
    msdos(regs);
  end;

  function fileExists(const path: TPath; const filename: TFilename): boolean;
  var 
    dirInfo: SearchRec;
  begin
    findFirst(path + filename, Archive, dirInfo);
    fileExists := DOSError = 0;
  end;

  function directoryExists(const dir: TPath): boolean;
  var 
    dirInfo: SearchRec;
  begin
    findFirst(dir, Directory, dirInfo);
    directoryExists := DOSError = 0;
  end;

  procedure createDirectory(const dir: TPath);
  var
    regs: Registers;
    p: pointer;
    asciiz: array [0..50] of char;
    i: byte;
  begin
    regs.ah := $39;
    regs.ds := seg(asciiz);
    regs.dx := ofs(asciiz);
    p := Ptr(seg(dir), ofs(dir) + 1);
    move(p^, asciiz, length(dir));
    asciiz[length(dir)] := #0;
    msdos(regs);
  end;

  function strAfterNull(const args: string; index: byte): string;
  var
    i, j: byte;
    result: string;
  begin
    i := 1;
    j := 0;
    result := '';
    while (i <= length(args)) and (j <> index) do
    begin
      if args[i] = #0 then inc(j);
      inc(i);
    end;
    if j = index then
      while (i <= length(args)) and (args[i]<>#0) do
      begin
        result := result + args[i];
        inc(i);
      end;
    strAfterNull := result;
  end;

  function strformat(const str, args: string): string;
  var 
    result: string;
    i: byte;
    ch: char;
  begin
    result := '';
    i := 1;
    while i <= length(str) do
    begin
      ch := str[i];
      if (str[i] = '%') then
        if (i+1<=length(str)) then
        begin
          if (str[i+1] in ['0'..'9']) then 
          begin
            ch := #0;
            result := result + strAfterNull(args, ord(str[i+1]) - ord('0'));
            inc(i);
          end else if str[i+1]='%' then 
            inc(i);
        end;
      if ch <> #0 then result := result + ch;
      inc(i);
    end;
    strformat := result;
  end;

end.