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
    dirInfo: SearchRec;
    fileFound, success: boolean;
    errorMsg: string;
  begin
    with BuildConfig do
    begin
      findFirst(baseDir + '*.PAS', archive, dirInfo);
      fileFound := DOSError = 0;
      success := true;
      while fileFound and success do
      begin
        with dirInfo do 
        begin
          success := compile(baseDir, name, errorMsg);
        end;
        findNext(dirInfo);
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
    if success then log(C_STR_BUILD_SUCCESS) else error(C_STR_BUILD_FAILED);
  end;

end.