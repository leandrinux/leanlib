{
  GUI Unit
  2022 LRT
}
unit
  GUI;

interface

  uses
    consts, utils, uclasses, types, locale, palette,
    uobject, uexc, udisplay, ucanvas, ubitmap, ulist, udict,
    gclasses, gtypes, grender, gmeteor, gfactory, gcontrol;

  type
    PUserInterface = ^TUserInterface;
    TUserInterface = object (TObject)
    public
      { constructors and destructors}
      constructor initWithDisplayAdapter(display: PDisplayAdapter);
      destructor done; virtual;
      { extended methods }
      function getClassName: string; virtual;
      function getClassId: word; virtual;
      { methods }
      function createFromData(data: PDictionary): PControl;
      function getControls: PList;
      procedure addFromData(data: PDictionary);
      procedure render;
    private
      _colorScheme: TColorScheme;
      _display: PDisplayAdapter;
      _renderer: PRenderer;
      _controls: PList;
    end;

implementation

  { TUserInterface public }
  constructor TUserInterface.initWithDisplayAdapter(display: PDisplayAdapter);
  begin
    inherited init;
    _display := display;
    _display^.retain;
    _renderer := new(PMeteor, initWithCanvas(_display^.getCanvas));
    _controls := new(PList, initWithClassFamily(C_CLASS_ID_CONTROL, C_CLASS_ID_CONTROL_FAMILY));
  end;

  destructor TUserInterface.done;
  begin
    _display^.release;
    _renderer^.release;
    _controls^.release;
    inherited done;
  end;

  function TUserInterface.getClassName: string;
  begin
    getClassName := 'TUserInterface';
  end;

  function TUserInterface.getClassId: word;
  begin
    getClassId := C_CLASS_ID_GUI;
  end;

  function TUserInterface.createFromData(data: PDictionary): PControl;
  var
    cf: PControlFactory;
  begin
    cf := new(PControlFactory, init);
    createFromData := cf^.create(data);
    cf^.release;    
  end;

  function TUserInterface.getControls: PList;
  begin
    getControls := _controls;
  end;

  procedure TUserInterface.addFromData(data: PDictionary);
  var
    control: PControl;
  begin
    control := createFromData(data);
    _controls^.addObject(control);
    control^.release;
  end;

  procedure TUserInterface.render;
  var
    control: PControl;
  begin
    _controls^.moveToStart;
    control := PControl(_controls^.getObjectAtCursor);
    while control <> nil do
    begin
      control := PControl(_controls^.getObjectAtCursor);
      _renderer^.render(control);
    end;
  end;

  { TUserInterface private }


  { Other }

end.
