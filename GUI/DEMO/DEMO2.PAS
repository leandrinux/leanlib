uses
  xcrt, types,
  uobject, ufstream, ujson, udict, uclasses, uexc, userial, ulog, udisplay,
  gui;

const
  GUI_FILE = 'DEMO.2';

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

var
  ui: PUserInterface;

begin
  writeln('About to start');
  initLog;
  DisplayAdapter := new(PDisplayAdapter, init);
  DisplayAdapter^.detectAdapter;
  DisplayAdapter^.setVideoMode(0);

  ui := new(PUserInterface, init);
  addControls(ui);
  ui^.render;
  readkey;
  
  ui^.release;
  DisplayAdapter^.setTextMode;
end.