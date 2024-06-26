{
  This unit does the main load of the work of the program
  by finding all the files that need to be compiled and
  carrying out the full build.
}
unit 
  tpmain;

interface

  procedure buildAll(const baseDir: string);

implementation

  uses
    tputil,
    tptpc,
    tpautou,
    tptexts,
    tpmodify,
    dos;

  { Public }

  procedure buildAll(const baseDir: string);
  var 
    dirInfo: SearchRec;
    fileFound, compileSuccess: boolean;
    path: TPath;
    previousRec, currentRec: TModifyRecords;
    recordCount: word;
    errorMsg: string;
  begin
    if length(basedir)>0 then 
      log(C_STR_PACKAGE_TO_BUILD + baseDir)
    else
      log(C_STR_PACKAGE_TO_BUILD + C_STR_CURRENT_DIR);
    log(C_STR_BUILD_ALL);

    if not directoryExists(basedir + '\BIN') then 
    begin
      createDirectory(basedir + '\BIN');
      log(C_STR_CREATED_BIN_DIR);
    end;
    readModifyRecords(basedir, previousRec);
    createDynamicUnit;

    findFirst(baseDir + '\*.PAS', archive, dirInfo);
    fileFound := DOSError = 0;
    compileSuccess := true;
    while fileFound and compileSuccess do
    begin
      with dirInfo do 
      begin
        compileSuccess := compile(baseDir, name, errorMsg);
      end;
      findNext(dirInfo);
      fileFound := DOSError = 0;
    end;
    deleteDynamicUnit;
    if compileSuccess then log(C_STR_BUILD_SUCCESS) else error(C_STR_BUILD_FAILED);
  end;

end.