{
  uexc Unit
  Represents an exception (when something bad happens)
  2022 LRT
}
unit
  uexc;

interface

  uses
    xcrt, uclasses, types, uobject, utils, strings, locale, umsgs, int10;

  type
    PException = ^TException;
    TException = object (TObject)
    public
      constructor init(obj: PObject; code: longint; msg: string);
      destructor done; virtual;
      procedure raise;
      function getText: string;
      function getObject: PObject;
      function getErrorCode: longint;
      function getErrorMessage: string;
      function getClassName: string; virtual;
      function classId: word; virtual;
    private
      _obj: PObject;    { object that has caused the exception }
      _code: longint;   { error code }
      _msg: string;     { error message }
      procedure relayToHandler;
      procedure standardRaise;
    end;

  procedure xassert(flag: boolean; code: longint; msg: string);
  procedure iassert(flag: boolean; obj: PObject; code: longint; msg: string);
  procedure raise(obj: PObject; code: longint; msg: string);
  procedure setExceptionHandler(handler: PObject);

implementation

  var
    ExceptionHandler: PObject;

  { TException public }

  constructor TException.init(obj: PObject; code: longint; msg: string);
  begin
    inherited init;
    _obj := obj;
    _code := code;
    _msg := msg;
  end;

  destructor TException.done;
  begin
    inherited done;
  end;

  procedure TException.raise;
  begin
    if ExceptionHandler <> nil then
      relayToHandler
    else
      standardRaise;
    halt(1);
  end;

  function TException.getObject: PObject;
  begin
    getObject := _obj;
  end;

  function TException.getErrorCode: longint;
  begin
    getErrorCode := _code;
  end;

  function TException.getErrorMessage: string;
  begin
    getErrorMessage := _msg;
  end;

  function TException.getClassName: string;
  begin
    getClassName := 'TException';
  end;

  function TException.classId: word;
  begin
    classId := C_CLASS_ID_EXCEPTION;
  end;

  { TException private }

  procedure TException.relayToHandler;
  var
    objmsg: TObjectMessage;
  begin
    with objmsg do
    begin
      opcode := C_MSG_EXCEPTION;
      sender := @self;
      target := ExceptionHandler;
      payload := nil;
      size := 0;
    end;
    ExceptionHandler^.receiveMessage(@objmsg);
  end;

  function TException.getText: string;
  var
    args: array[0..3] of string;
    formatStr: string;
  begin
    args[0] := ptrToStr(_obj); { pointer to object that caused the exception }
    args[3] := _msg;           { error message }
    args[2] := intToStr(_code);{ error code }
    if _obj <> nil then
    begin
      if _code > 0 then
        formatStr := S_EXCEPTION_INSTANCE_ERROR_MSG_FS
      else
        formatStr := S_EXCEPTION_INSTANCE_ERROR_MSG_NO_CODE_FS;
      args[1] := _obj^.getClassName { string name of the class }
    end else begin
      if _code > 0 then
        formatStr := S_EXCEPTION_ERROR_MSG_FS
      else
        formatStr := S_EXCEPTION_ERROR_MSG_NO_CODE_FS;
      args[1] := ''; { no class }
    end;
    getText := strformat(formatStr, @args);
  end;

  procedure TException.standardRaise;
  const
    C_TEXT_MODE = C_VIDMODE_CGA_T_80x25_16;
  begin
    if getVideoMode > C_TEXT_MODE then setVideoMode(C_TEXT_MODE);
    writeln(getText);
    readkey;
  end;

  { Other  }

  procedure xassert(flag: boolean; code: longint; msg: string);
  var
    ex: PException;
  begin
    if not flag then
    begin
      ex := new(PException, init(nil, code, msg));
      ex^.raise;
      { no need to release or do anything, raising kills the program }
    end;
  end;

  procedure iassert(flag: boolean; obj: PObject; code: longint; msg: string);
  var
    ex: PException;
  begin
    if not flag then
    begin
      New(ex, init(obj, code, msg));
      ex^.raise;
      { no need to release or do anything, raising kills the program }
    end;
  end;

  procedure raise(obj: PObject; code: longint; msg: string);
  var
    ex: PException;
  begin
    ex := new(PException, init(obj, code, msg));
    ex^.raise;
  end;

  procedure setExceptionHandler(handler: PObject);
  begin
    ExceptionHandler := handler;
  end;

begin
  ExceptionHandler := nil;
end.