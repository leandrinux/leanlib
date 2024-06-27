{
  This unit contains constants, types and methods that COULD be used
  in other programs because they are general enough
}
unit
  tputil;

interface

  uses
    tptexts,
    dos, 
    execute;

  type
    TPath = string[50];
    TFilename = string[12];
    string6 = string[6];

  procedure error(msg: string);
  procedure log(msg: string);
  function run(const cmd, cmdLine: string; hide: boolean): integer;
  procedure deleteFile(const filename: TFilename);
  procedure deleteFiles(const path: TPath; filename: TFilename);
  function fileExists(const path: TPath; const filename: TFilename): boolean;
  function directoryExists(const dir: TPath): boolean;
  procedure createDirectory(const dir: TPath);
  function strformat(const str, args: string): string;
  function strToInt(s: string): integer;
  function intToStr(i: integer): string6;

implementation

  procedure error(msg: string);
  begin
    writeln('[X] ', msg);
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
    asciiz: array [0..255] of char;
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

  procedure deleteFiles(const path: TPath; filename: TFilename);
  var 
    dirInfo: SearchRec;
  begin
    findFirst(path + filename, Archive, dirInfo);
    while DOSError = 0 do
    begin
      deleteFile(path + dirInfo.name);
      findNext(dirInfo);
    end;
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


  function strformat(const str, args: string): string;
  var 
    tokens: array[0..9] of byte;
    result: string;
    i, index: byte;
    ch: char;
  begin
    { find tokens in args }
    fillchar(tokens, sizeof(tokens), 0);
    tokens[0] := 1;
    index := 1;
    i := 1;
    while i<=length(args) do
    begin
      if args[i]=#0 then begin
        tokens[index] := i+1;
        inc(index);
      end;
      inc(i);
    end;

    { replace tokens in string }
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
            { copy the token until next null or end of line}
            index := tokens[ord(str[i+1]) - ord('0')];
            while (index<>0) and (index<=length(args)) and (args[index]<>#0) do
            begin
              result := result + args[index];
              inc(index);
            end;
            inc(i);
          end else if str[i+1]='%' then 
            inc(i);
        end;
      if ch <> #0 then result := result + ch;
      inc(i);
    end;
    strformat := result;
  end;

  function strToInt(s: string): integer;
  var i, c: integer;
  begin
    Val(s, i, c);
    StrToInt := i;
  end;

  function intToStr(i: integer): string6;
  var
    s: string6;
  begin
    Str(i, s);
    IntToStr := s;
  end;

end.