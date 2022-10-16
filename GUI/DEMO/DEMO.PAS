uses
  xcrt, types,
  uobject, udisplay, ufstream, ujson, udict, uclasses, uexc, userial, ulog,
  gui;

const
  GUI_FILE = 'DEMO.1';

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
  Log^.out('Opening ' + GUI_FILE);
  fs := new(PFileStream, initWithPath(GUI_FILE, true));
  Log^.out('Reading JSON from file');
  json := new(PJsonReader, init);
  obj := json^.open(fs);
  xassert(obj^.getClassId = C_CLASS_ID_DICTIONARY, 0, 'Root object in GUI file not a dictionary!');
  Log^.out('Got object of class ' + obj^.getClassName);
  ui^.addFromData(PDictionary(obj));
  json^.release;
  fs^.release;
end;

var
  display: PDisplayAdapter;
  ui: PUserInterface;

begin
  initLog;
  display := new(PDisplayAdapter, init);
  if not display^.detectAdapter then halt(1);
  display^.setVideoMode(0);

  ui := new(PUserInterface, initWithDisplayAdapter(display));
  addControls(ui);
  ui^.render;
  Log^.out('Waiting for key to close program');
  readkey;

  ui^.release;
  display^.setTextMode;
  display^.release;  
end.