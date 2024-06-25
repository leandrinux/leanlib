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

implementation

  uses
    tpstr_en, dos, execute;

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

end.