{
  ULog Unit
  2022 LRT
}
unit
  ULog;

interface

  uses
    consts, utils, uexc, uclasses, types, locale, uobject, ustream,
    uansiw, umsgs;

  type
    ELevel = (
      ELevelStandard,
      ELevelWarning,
      ELevelError
    );

    PLog = ^TLog;
    TLog = object (TObject)
    public
      constructor initWithStream(stream: PStream);
      destructor done; virtual;
      procedure receiveMessage(msg: PObjectMessage); virtual;
      procedure setAsExceptionHandler;
      procedure reset;
      procedure out(str: string);
      procedure warn(str: string);
      procedure fail(str: string);
      procedure setAnsiSupport(value: boolean);
      procedure setAsDefault;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
    private
      _stream: PStream;
      _ansi: PAnsiWriter;
      _count: longint;
      procedure entry(level: ELevel; var str: string);
    end;

  var
    Log: PLog;

implementation

  const
    C_LEVEL_COLORS: array [ELevel] of EAnsiColor = (
      fgWhite,
      fgYellow,
      fgRed
    );

  { TLog public }

  constructor TLog.initWithStream(stream: PStream);
  begin
    inherited init;
    _stream := stream;
    _stream^.retain;
    _ansi := new(PAnsiWriter, initWithStream(_stream));
    _ansi^.writeln('');
    _count := 0;
  end;

  destructor TLog.done;
  begin
    _ansi^.release;
    _stream^.release;
    inherited done;
  end;

  procedure TLog.receiveMessage(msg: PObjectMessage);
  var
    ex: PException;
    error: string;
  begin
    if msg^.opcode = C_MSG_EXCEPTION then
    begin
      ex := PException(msg^.sender);
      error := ex^.getText;
      entry(ELevelError, error);
    end else
      inherited receiveMessage(msg);
  end;

  procedure TLog.setAsExceptionHandler;
  begin
    setExceptionHandler(@self);
  end;

  procedure TLog.reset;
  begin
    _ansi^.setColor(none);
    _ansi^.clear;
    _ansi^.gotoxy(1, 1);
  end;

  procedure TLog.out(str: string);
  begin
    entry(ELevelStandard, str);
  end;

  procedure TLog.warn(str: string);
  begin
    entry(ELevelWarning, str);
  end;

  procedure TLog.fail(str: string);
  begin
    entry(ELevelError, str);
  end;

  procedure TLog.setAnsiSupport(value: boolean);
  begin
    _ansi^.setEnabled(value);
  end;

  procedure TLog.setAsDefault;
  begin
    if Log <> nil then Log^.release;
    Log := @self;
    retain;
  end;

  function TLog.getClassName: string;
  begin
    getClassName := 'TLog';
  end;

  function TLog.getClassId: word;
  begin
    getClassId := C_CLASS_ID_Log;
  end;

  { TLog private }

  procedure TLog.entry(level: ELevel; var str: string);
  begin
    with _ansi^ do
    begin
      _ansi^.setColor(C_LEVEL_COLORS[ELevelStandard]);
      writestr('[' + longtostr(_count) + '] ');
      _ansi^.setColor(C_LEVEL_COLORS[level]);
      writeln(str);
      inc(_count);
    end;
  end;

  { Other }

begin
  Log := nil;
end.