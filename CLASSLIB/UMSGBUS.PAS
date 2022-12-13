{
  umsgbus Unit
  Message bus, used to broadcast messages to multiple objects
  2022 LRT
}
unit
  umsgbus;

interface

  uses
    consts, utils, uexc, uclasses, types, locale, uobject, ulist;

  type
    PMessageBus = ^TMessageBus;
    TMessageBus = object (TObject)
    public
      constructor init;
      destructor done; virtual;
      procedure subscribe(obj: PObject);
      procedure unsubscribe(obj: PObject);
      procedure broadcast(msg: PObjectMessage);
      procedure receiveMessage(msg: PObjectMessage); virtual;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
    private
      _list: PList;
    end;

implementation

  { TMessageBus public }

  constructor TMessageBus.init;
  begin
    inherited init;
    _list := new(PList, init);
    _list^.setWeak(true);
  end;

  destructor TMessageBus.done;
  begin
    _list^.release;
    inherited done;
  end;

  procedure TMessageBus.subscribe(obj: PObject);
  begin
    _list^.addObject(obj);
  end;

  procedure TMessageBus.unsubscribe(obj: PObject);
  begin
    _list^.removeObject(obj);
  end;

  procedure TMessageBus.broadcast(msg: PObjectMessage);
  var
    obj: PObject;
  begin
    _list^.moveToStart;
    obj := _list^.getObjectAtCursor;
    while obj <> nil do
    begin
      obj^.receiveMessage(msg);
      _list^.moveForward;
      obj := _list^.getObjectAtCursor;
    end;
  end;

  procedure TMessageBus.receiveMessage(msg: PObjectMessage);
  begin
    broadcast(msg);
  end;

  function TMessageBus.getClassName: string;
  begin
    getClassName := 'TMessageBus';
  end;

  function TMessageBus.getClassId: word;
  begin
    getClassId := C_CLASS_ID_MessageBus;
  end;

  { TMessageBus private }

  { Other }

end.