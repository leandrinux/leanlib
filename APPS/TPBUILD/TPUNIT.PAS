{
  This unit contains constants, types and methods that are exclusive
  for the operation of TPBUILD
}
unit 
  tpunit;

interface

  procedure buildAll(const baseDir: string);

implementation

  uses
    {$IFDEF Spanish}tpstr_es,
    {$ELSE}tpstr_en,{$ENDIF}
    tputil,
    tptpc,
    tpautou,
    DOS;

  const
    C_MAX_MODIFY_RECORDS = 100;
    C_MODIFY_RECORDS_FILENAME = 'MODIFY.REC';

  type
    TModifyRecord = packed record
      filename: TFilename;
      time: longint;
    end;

    TModifyRecords = record
      recs: array [0..C_MAX_MODIFY_RECORDS - 1] of TModifyRecord;
      count: word;
    end;

  procedure readModifyRecords(const basedir: string; var modifyRecords: TModifyRecords);
  var
    f: file of TModifyRecord;
  begin
    assign(f, basedir + '\' + C_MODIFY_RECORDS_FILENAME);
    {$I-} reset(f); {$I+}
    if IOResult = 0 then
    begin
      with modifyRecords do
        while not eof(f) and (count<C_MAX_MODIFY_RECORDS) do 
        begin
          read(f, recs[count]);
          inc(count);
        end;
      close(f);
      log(C_STR_YES_MODIFIED_RECORDS);
    end else
      log(C_STR_NO_MODIFIED_RECORDS);
  end;

  procedure saveModifyRecords(const basedir: string; var modifyRecords: TModifyRecords);
  var
    f: file of TModifyRecord;
    i: word;
  begin
    assign(f, basedir + '\' + C_MODIFY_RECORDS_FILENAME);
    {$I-} rewrite(f); {$I+}
    if IOResult = 0 then
    begin
      with modifyRecords do for i:= 1 to count do write(f, recs[i]);
      close(f);
      log(C_STR_SAVE_MODIFIED_RECORDS);
    end;
  end;

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