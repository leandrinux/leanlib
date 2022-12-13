uses
  xcrt, udisplay, umouse, uobject, umsgs;

type
  PMouseDelegate = ^TMouseDelegate;
  TMouseDelegate = object(TObject)
    procedure receiveMessage(msg: PObjectMessage); virtual; 
  end;

procedure TMouseDelegate.receiveMessage(msg: PObjectMessage);
begin
  case msg^.opcode of
    C_MSG_MOUSE_MOVEMENT,
    C_MSG_MOUSE_LEFT_DOWN,
    C_MSG_MOUSE_RIGHT_DOWN: beep;
  end;
end;

var
  mouse: PMouse;
  listener: PMouseDelegate;
  cursor: pointer;

begin
  createDefaultDisplayAdapter;
  mouse := new(PMouse, init);
  listener := new(PMouseDelegate, init);
  mouse^.setDelegate(listener);
  mouse^.show;
  while not keypressed do mouse^.update;
  mouse^.hide;
  mouse^.release;
  listener^.release;
  DisplayAdapter^.setTextMode;
end.