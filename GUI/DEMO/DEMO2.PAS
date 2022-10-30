uses
  ascii, xcrt, types, int33, utils,
  uobject, ufstream, ujson, udict, uclasses, uexc, userial, ulog, udisplay,
  gui, gtypes, gmsgs;

const
  GUI_FILE = 'DEMO.2';

type
  TMouseStatus = packed record
    statusCode: word;
    position: TPoint;
  end;

procedure initLog;
var
  com: PSerial;
  log: PLog;
begin
  com := new(PSerial, initWithPort(COM2));
  log := new(PLog, initWithStream(com));
  log^.setAsDefault;
  log^.release;
  com^.release;
end;

procedure addControls(ui: PUserInterface);
var
  fs: PFileStream;
  json: PJsonReader;
  obj: PObject;
begin
  fs := new(PFileStream, initWithPath(GUI_FILE, true));
  json := new(PJsonReader, init);
  obj := json^.open(fs);
  xassert(obj^.getClassId = C_CLASS_ID_DICTIONARY, 0, 'Root object in GUI file not a dictionary!');
  ui^.addFromData(PDictionary(obj));
  json^.release;
  fs^.release;
end;

procedure sendMouseActivity(var previous, current: TMouseStatus; ui: PUserInterface);
var
  activity: TMouseActivity;
  msg: TObjectMessage;
begin 
  activity.event := EMouseEventNone;
  if ((previous.statusCode and C_MOUSE_LEFT) = 0) and ((current.statusCode and C_MOUSE_LEFT) <> 0) then
    activity.event := EMouseEventLeftDown
  else if ((previous.statusCode and C_MOUSE_LEFT) <> 0) and ((current.statusCode and C_MOUSE_LEFT) = 0) then
    activity.event := EMouseEventLeftUp
  else exit;
  activity.position.x := current.position.x shr 1;
  activity.position.y := current.position.y;
  fillchar(msg, sizeof(msg), 0);
  msg.opcode := C_MSG_MOUSE_ACTIVITY;
  msg.payload := @activity;
  hideMouseCursor;
  ui^.receiveMessage(@msg);
  showMouseCursor;
end;

var
  ui: PUserInterface;
  previous, current: TMouseStatus;
  ch: char;

begin
  initLog;
  DisplayAdapter := new(PDisplayAdapter, init);
  DisplayAdapter^.detectAdapter;
  DisplayAdapter^.setVideoMode(0);

  ui := new(PUserInterface, init);
  addControls(ui);
  ui^.render;
  showMouseCursor;
  fillchar(current, sizeof(TMouseStatus), 0);
  ch := #0;
  while ch <> C_ESC do 
  begin
    previous := current;
    with current do getMouseStatus(position.x, position.y, statusCode); 
    sendMouseActivity(previous, current, ui);
    if keypressed then ch := readkey;
  end;
  hideMouseCursor;

  ui^.release;
  DisplayAdapter^.setTextMode;
end.