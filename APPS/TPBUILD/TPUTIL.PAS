unit
  tputil;

interface

  uses
    tpstring, dos;

  const
    C_MAX_MODIFY_RECORDS = 100;
    C_MODIFY_RECORDS_FILENAME = 'MODIFY.REC';

  type
    TPath = string[50];

    TFilename = string[12];

    TModifyRecord = packed record
      filename: TFilename;
      time: longint;
    end;

    TModifyRecords = record
      recs: array [0..C_MAX_MODIFY_RECORDS - 1] of TModifyRecord;
      count: word;
    end;

  procedure error(msg: string);
  procedure log(msg: string);
  procedure readModifyRecords(const basedir: string; var modifyRecords: TModifyRecords);
  procedure saveModifyRecords(const basedir: string; var modifyRecords: TModifyRecords);
  procedure deleteFile(const filename: TFilename);

implementation

  procedure error(msg: string);
  begin
    writeln('[X] ERROR: ', msg);
    halt(1);
  end;

  procedure log(msg: string);
  begin
    writeln('[-] ', msg);
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

end.