{
  GForm Unit

  2022 LRT
}
unit
  GForm;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc, ustream, udict, ujson, ufstream, ucstream,
    gclasses, gtypes, gcontrol, gfactory;

  type
    PForm = ^TForm;
    TForm = object (TObject)
    public
      { constructors and destructors}
      constructor init;
      destructor done; virtual;
      { extended methods }
      function getClassName: string; virtual;
      function getClassId: word; virtual;
      { methods }
      function createControlFromDictionary(data: PDictionary): PControl;
      function createControlFromJson(stream: PStream): PControl;
      function createControlFromFile(filename: string): PControl;
      function createControl: PControl; virtual;
      function getRootControl: PControl;
      procedure onStart; virtual;
      procedure onEvent(opcode: word; sender: PControl); virtual;
    private
      _rootControl: PControl;
    end;

implementation

  { TForm public }

  constructor TForm.init;
  begin
    inherited init;
    _rootControl := createControl;
    _rootControl^.setDelegate(@self);
    onStart;
  end;

  destructor TForm.done;
  begin
    inherited done;
    _rootControl^.release;
  end;

  function TForm.getClassName: string;
  begin
    getClassName := 'TForm';
  end;

  function TForm.getClassId: word;
  begin
    getClassId := C_CLASS_ID_Form;
  end;

  function TForm.createControlFromDictionary(data: PDictionary): PControl;
  var
    cf: PControlFactory;
  begin
    cf := new(PControlFactory, init);
    createControlFromDictionary := cf^.create(data);
    cf^.release;    
  end;

  function TForm.createControlFromJson(stream: PStream): PControl;
  var
    json: PJsonReader;
    control: PControl;
    obj: PObject;
  begin
    json := new(PJsonReader, init);
    obj := json^.createFromStream(stream);
    xassert(obj^.getClassId = C_CLASS_ID_DICTIONARY, 0, 'Root object in GUI file not a dictionary!');
    createControlFromJson := createControlFromDictionary(PDictionary(obj));
    json^.release;
  end;

  function TForm.createControlFromFile(filename: string): PControl;
  var
    fs: PFileStream;
    cs: PCachedStream;
  begin
    fs := new(PFileStream, initWithPath(filename, EFileReadOnly));
    cs := new(PCachedStream, initWithStream(fs, 2048));
    createControlFromFile := createControlFromJson(cs);
    fs^.release;
    cs^.release;
  end;

  function TForm.createControl: PControl;
  begin
    createControl := new(PControl, initWithId(''));
  end;

  function TForm.getRootControl: PControl;
  begin
    getRootControl := _rootControl;
  end;

  procedure TForm.onStart;
  begin
  end;

  procedure TForm.onEvent(opcode: word; sender: PControl);
  begin
  end;

  { TForm private }

  { Other }

end.
