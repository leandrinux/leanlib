unit 
  tpunit;

interface
 
  type
    TPath = string[30];
    TFilename = string[12];

  procedure error(msg: string);
  procedure log(msg: string);
  procedure buildAll(const baseDir: string);
  function getTPCPath: TPath;

implementation

  uses
    dos, execute, tpstring;

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

  procedure buildAll(const baseDir: string);
  var 
    dirInfo: SearchRec;
  begin
    if length(basedir)>0 then 
      log(C_STR_PROJECT_DIR + baseDir)
    else
      log(C_STR_PROJECT_DIR + C_STR_CURRENT_DIR);
    log(C_STR_BUILD_ALL);
    findFirst(baseDir + '\*.PAS', archive, dirInfo);
    while DOSError = 0 do
    begin
      with dirInfo do writeln(name, ',', time);
      findNext(dirInfo);
    end;   
  end;

  function getTPCPath: TPath;
  begin
    getTPCPath := TPC_PATH;
  end;

begin
  searchPath;
end.