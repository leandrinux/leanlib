uses
  xcrt, ascii, ukeybrd, umsgs, uobject;

type
  PListener = ^TListener;
  TListener = object (TObject)
    procedure receiveMessage(msg: PObjectMessage); virtual;
  end;

procedure TListener.receiveMessage(msg: PObjectMessage);
begin
  if msg^.opcode = C_MSG_KEYBOARD_KEY_DOWN then write(PChar(msg^.payload)^); 
end;

var
  listener: PListener;

begin
  listener := new(PListener, init);
  Keyboard^.setDelegate(listener);
  while not (Keyboard^.update and (Keyboard^.getLastKeyDown = C_ESC)) do; 
  listener^.release;
end.