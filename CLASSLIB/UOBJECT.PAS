{
  UObject Unit
  Base class for all objects in the library
  2022 LRT
}
unit
  UObject;

interface

  uses
    uclasses, types;

  type
    PObject = ^TObject;

    TCompareFunc = function(value: pointer; obj: PObject): ECompareResult;

    PObjectMessage = ^TObjectMessage;

    TObject = object
      public
        constructor init;
        destructor done; virtual;
        procedure retain;
        procedure release;
        procedure receiveMessage(msg: PObjectMessage); virtual;
        procedure sendMessageToDelegate(msg: PObjectMessage);
        procedure setDelegate(obj: PObject);
        function getDelegate: PObject;
        function compare(value: PObject): ECompareResult; virtual;
        function getClassName: string; virtual;
        function getClassId: word; virtual;
      private
        _retainCount: word;
        _delegate: PObject;
    end;

    { a simple representation of a message sent between two objects }
    TObjectMessage = packed record
      opcode: word;
      sender: PObject;
      target: PObject;
      payload: pointer;
      size: word;
    end;

implementation

  constructor TObject.init;
  begin
    _retainCount := 1;
    _delegate := nil;
  end;

  destructor TObject.done;
  begin
  end;

  procedure TObject.retain;
  begin
    inc(_retainCount);
  end;

  procedure TObject.release;
  var
    this: PObject;
  begin
    dec(_retainCount);
    if _retainCount = 0 then
    begin
      this := @self;
      dispose(this, done);
    end;
  end;

  procedure TObject.receiveMessage(msg: PObjectMessage); begin end;

  procedure TObject.sendMessageToDelegate(msg: PObjectMessage);
  begin
    if msg = nil then exit;
    if _delegate = nil then exit;
    _delegate^.receiveMessage(msg);
  end;

  procedure TObject.setDelegate(obj: PObject);
  begin
    _delegate := obj;
  end;

  function TObject.getDelegate: PObject;
  begin
    getDelegate := _delegate;
  end;

  function TObject.compare(value: PObject): ECompareResult;
  begin
    compare := ECompareUndefined;
  end;

  function TObject.getClassName: string;
  begin
    getClassName := 'TObject';
  end;

  function TObject.getClassId: word;
  begin
    getClassId := C_CLASS_ID_OBJECT;
  end;

end.