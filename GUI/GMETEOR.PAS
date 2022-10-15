{
  GMeteor Unit
  2022 LRT
}
unit
  GMeteor;

interface

  uses
    consts, utils, uclasses, types, locale, palette,
    uobject, uexc, ucanvas,
    gclasses, gtypes, grender, gpanel;

  type
    PMeteor = ^TMeteor;
    TMeteor = object (TRenderer)
    public
      { constructors and destructors}
      constructor initWithCanvas(canvas: PCanvas);
      destructor done; virtual;
      { extended methods }
      function getClassName: string; virtual;
      function getClassId: word; virtual;
      { methods }
      function getRendererName: string16; virtual;
      procedure renderPanel(panel: PPanel); virtual;
    private
      _colorScheme: TColorScheme;
      procedure buildDefaultColorScheme;
    end;

implementation

  { TMeteor public }

  constructor TMeteor.initWithCanvas(canvas: PCanvas);
  begin
    inherited initWithCanvas(canvas);
    buildDefaultColorScheme;
  end;

  destructor TMeteor.done;
  begin
    inherited done;
  end;

  function TMeteor.getClassName: string;
  begin
    getClassName := 'TMeteor';
  end;

  function TMeteor.getClassId: word;
  begin
    getClassId := C_CLASS_ID_Meteor;
  end;
  
  function TMeteor.getRendererName: string16;
  begin
    getRendererName := 'Meteor';
  end;

  procedure TMeteor.renderPanel(panel: PPanel);
  begin
    with getCanvas^, panel^.getFrame^ do
    begin
      getStrokeBrush^.color := _colorScheme[ECKPanelBorderTopLeft];
      hline(point.x, point.x + size.width - 1, point.y);
      vline(point.y, point.y + size.height - 1, point.x);
      getStrokeBrush^.color := _colorScheme[ECKPanelBorderBottomRight];
      hline(point.x, point.x + size.width - 1, point.y + size.height - 1);
      vline(point.y, point.y + size.height - 1, point.x + size.width - 1);
      getStrokeBrush^.color := _colorScheme[ECKPanelBackground];
      getFillBrush^.color := getStrokeBrush^.color;
      frect(point.x + 1, point.y + 1, point.x + size.width - 2, point.y + size.height - 2);
    end;
  end;

  { TMeteor private }

  procedure TMeteor.buildDefaultColorScheme;
  begin
    pSetColorDepth(getCanvas^.getBitmap^.getBitsPerPixel);
    _colorScheme[ECKPanelBorderTopLeft] := pColor(EWhite);
    _colorScheme[ECKPanelBorderBottomRight] := pColor(EDarkgray);
    _colorScheme[ECKPanelBackground] := pColor(ELightgray);
  end;

  { Other }

end.
