unit 
  tpunit;

interface
 
  type
    TPath = string[30];
    TFilename = string[12];

  procedure error(msg: string);
  procedure log(msg: string);
  function run(const cmd, cmdLine: string; hide: boolean): integer;
  function compile(const cmdLine: string): boolean;
  function getTPCPath: TPath;
  function isTPCInstalled: boolean;

implementation

  uses
    dos, execute;

  const
    C_TPC_EXECUTABLE = 'tpc.exe';

  var 
    TPC_PATH: TPath;

  { Private }
  
  function fileExists(const path: TPath; const filename: TFilename): boolean;
  var 
    dirInfo: SearchRec;
  begin
    findFirst(path + filename, archive, dirInfo);
    fileExists := DOSError = 0;
  end;

  procedure searchPath;
  var
    pathvar: string;
    path: TPath;
    i: byte;
  begin
    if fileExists('.', C_TPC_EXECUTABLE) then 
    begin
      TPC_PATH := '';
      exit;
    end else
    begin
      pathVar := GetEnv('PATH');
      path := '';
      i := 1;
      while (i <= length(pathVar)) do
      begin
        if (pathVar[i] = ';') then
          if fileExists(path + '\', C_TPC_EXECUTABLE) then
          begin
            TPC_PATH := path + '\';
            exit;
          end else 
            path := ''
        else
          path := path + pathVar[i];
        inc(i);
      end;
      if (TPC_PATH = '') and fileExists(path + '\', C_TPC_EXECUTABLE) then 
        TPC_PATH := path + '\';
    end;
  end;

  { Public }

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

  function compile(const cmdLine: string): boolean;
  begin
    compile := run(TPC_PATH + C_TPC_EXECUTABLE, cmdLine, true) = 0;
  end;

  function getTPCPath: TPath;
  begin
    getTPCPath := TPC_PATH;
  end;

  function isTPCInstalled: boolean;
  begin
    isTPCInstalled := TPC_PATH <> '';
  end;

begin
  searchPath;
end.