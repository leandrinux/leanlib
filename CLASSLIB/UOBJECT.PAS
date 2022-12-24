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
        procedure sendMessage(opcode: word; target: PObject);
        procedure sendMessageWithData(opcode: word; target: PObject; payload: pointer; size: word);
        procedure setDelegate(obj: PObject);
        function getDelegate: PObject;
        function compare(value: PObject): ECompareResult; virtual;
        function getClassName: string; virtual;
        function getClassId: word; virtual;
        function getRetainCount: word;
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

  procedure TObject.sendMessage(opcode: word; target: PObject);
  var 
    msg: TObjectMessage;
  begin
    if target = nil then exit;
    msg.opcode := opcode;
    msg.target := target;
    msg.sender := @self;
    target^.receiveMessage(@msg);
  end;

  procedure TObject.sendMessageWithData(opcode: word; target: PObject; payload: pointer; size: word);
  var 
    msg: TObjectMessage;
  begin
    if target = nil then exit;
    msg.opcode := opcode;
    msg.target := target;
    msg.sender := @self;
    msg.payload := payload;
    msg.size := size;
    target^.receiveMessage(@msg);
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

  function TObject.getRetainCount: word;
  begin
    getRetainCount := _retainCount;
  end;

end.