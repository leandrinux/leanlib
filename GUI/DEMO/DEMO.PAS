uses
  xcrt, 
  uobject, udisplay, ufstream, ujson, udict, uclasses, uexc,
  gui;

const
  GUI_FILE = 'DEMO.1';

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
  display: PDisplayAdapter;
  ui: PUserInterface;

begin
  display := new(PDisplayAdapter, init);
  if not display^.detectAdapter then halt(1);
  display^.setVideoMode(0);

  ui := new(PUserInterface, initWithDisplayAdapter(display));
  addControls(ui);
  ui^.render;
  readkey;

  ui^.release;
  display^.setTextMode;
  display^.release;  
end.