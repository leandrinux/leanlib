{
  this unit's responsibility is to keep track of which files
  have already been compiled and have not been modified since
  then in order to avoid recompiling them again and speed up
  the whole process
}
unit 
  tpmodify;

interface

  uses
    tputil,
    tptexts;

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
  procedure saveModifyRecords(const basedir: string; var modifyRecords: TModifyRecords);

implementation

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

end.