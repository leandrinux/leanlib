{
  This unit does the main load of the work of the program
  by finding all the files that need to be compiled and
  carrying out the full build.
}
unit 
  tpmain;

interface

  uses
    tputil,
    tptpc,
    tpautou,
    tptexts,
    tpmodify,
    tpconfig,
    dos;

  procedure buildAll(baseDir: string);

implementation

  procedure setBuildBaseDirectory(baseDir: string);
  begin
    if (length(basedir)>0) and (basedir[length(basedir)]<>'\') then basedir := basedir + '\';
    BuildConfig.basedir := baseDir;
    if length(basedir)>0 then 
      log(C_STR_PACKAGE_TO_BUILD + baseDir)
    else
      log(C_STR_PACKAGE_TO_BUILD + C_STR_CURRENT_DIR);
    log(C_STR_BUILD_ALL);
  end;
 
  procedure createBinDirectory;
  begin
    with BuildConfig do
      if not directoryExists(basedir + 'BIN') then 
      begin
        createDirectory(basedir + 'BIN');
        log(C_STR_CREATED_BIN_DIR);
      end;
  end;
  
  function compileAll: boolean;
  var
    fileFound, success: boolean;
    packageDir: TPath;
    errorMsg: string;
    i: byte;
    dirInfo: SearchRec;
  begin
    with BuildConfig do
    begin
      success := true;
      
      { make the required packages }
      log(C_STR_BUILD_DEPENDENCIES);
      i := 0;
      while (i<requires.count) and success do
      begin
        packageDir := baseDir + requires.values[i] + '\';
        findFirst(packageDir + '*.PAS' , archive, dirInfo);
        fileFound:= DOSError = 0;
        while fileFound and success do
        begin
          success := compile(packageDir, dirInfo.name, errorMsg);
          findNext(dirInfo);
          fileFound:= DOSError = 0;
        end;
        inc(i);
        fileFound := DOSError = 0;
      end;

      { make the requested builds }
      log(C_STR_BUILD_PROGRAM);
      i := 0;
      while (i<builds.count) and success do
      begin
        success := compile(baseDir, builds.values[i], errorMsg);
        inc(i);
        fileFound := DOSError = 0;
      end;
    end;
    compileAll := success;
  end;

  procedure buildAll(baseDir: string);
  var 
    previousRec, currentRec: TModifyRecords;
    success: boolean;
  begin
    setBuildBaseDirectory(baseDir);
    createBinDirectory;
    readModifyRecords(basedir, previousRec);
    createDynamicUnit;
    success := compileAll;
    deleteDynamicUnit;
    deleteFiles(BuildConfig.basedir + 'BIN\', '*.TPU');
    if success then log(C_STR_BUILD_SUCCESS) else error(C_STR_BUILD_FAILED);
  end;

end.