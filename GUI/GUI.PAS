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
    gclasses, gtypes, grender, gfactory, gcontrol;

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
      function buildFromData(data: PDictionary): PControl;
      function getControls: PList;
      procedure addFromData(data: PDictionary);
    private
      _colorScheme: TColorScheme;
      _display: PDisplayAdapter;
      _renderer: PRenderer;
      _controls: PList;
      procedure buildDefaultColorScheme;
    end;

implementation

  { TUserInterface public }
  constructor TUserInterface.initWithDisplayAdapter(display: PDisplayAdapter);
  begin
    inherited init;
    _display := display;
    _display^.retain;
    buildDefaultColorScheme;
    _renderer := new(PRenderer, initWithCanvas(_display^.getCanvas, @_colorScheme));
    _controls := new(PList, initWithClassId(C_CLASS_ID_CONTROL));
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

  function TUserInterface.buildFromData(data: PDictionary): PControl;
  var
    cf: PControlFactory;
  begin
    cf := new(PControlFactory, init);
    buildFromData := cf^.build(data);
    cf^.release;    
  end;

  function TUserInterface.getControls: PList;
  begin
    getControls := _controls;
  end;

  procedure TUserInterface.addFromData(data: PDictionary);
  begin
    _controls^.addObject(buildFromData(data));
  end;

  { TUserInterface private }

  procedure TUserInterface.buildDefaultColorScheme;
  begin
    pSetColorDepth(_display^.getCanvas^.getBitmap^.getBitsPerPixel);
    _colorScheme[ECKPanelBorderTopLeft] := pColor(EWhite);
    _colorScheme[ECKPanelBorderBottomRight] := pColor(EDarkgray);
    _colorScheme[ECKPanelBackground] := pColor(ELightgray);
  end;

  { Other }

end.
