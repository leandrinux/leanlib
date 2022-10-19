{
  GMeteor Unit
  2022 LRT
}
unit
  GMeteor;

interface

  uses
    consts, utils, uclasses, types, locale, palette,
    uobject, uexc, ucanvas, ulog,
    gclasses, gtypes, grender, gcolors, gpanel;

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
    end;

implementation

  { TMeteor public }

  constructor TMeteor.initWithCanvas(canvas: PCanvas);
  begin
    inherited initWithCanvas(canvas);
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
  var
    colorTL, colorBR: TColor;
  begin
    Log^.out('Meteor render panel');
    Log^.out('Panel frame ' + frameToStr(panel^.getFrame));
    with getCanvas^, panel^, getFrame^, DefaultColorScheme^ do
    begin
      case getBorderStyle of
        EBorderStyleNone:
        begin
          colorTL := getBackgroundColor;
          colorBR := colorTL;
        end;
        
        EBorderStyleRaised:
        begin
          colorTL := getColor(ECKPanelBorderTopLeft);
          colorBR := getColor(ECKPanelBorderBottomRight);
        end;

        EBorderStyleLowered:
        begin
          colorTL := getColor(ECKPanelBorderBottomRight);
          colorBR := getColor(ECKPanelBorderTopLeft);
        end;
      end;
      getStrokeBrush^.color := colorTL;
      hline(point.x, point.x + size.width - 1, point.y);
      vline(point.y + 1, point.y + size.height - 1, point.x);
      getStrokeBrush^.color := colorBR;
      hline(point.x, point.x + size.width - 1, point.y + size.height - 1);
      vline(point.y + 1, point.y + size.height - 1, point.x + size.width - 1);
      getStrokeBrush^.color := getBackgroundColor;
      getFillBrush^.color := getStrokeBrush^.color;
      frect(point.x + 1, point.y + 1, size.width - 2, size.height - 2);
    end;
    Log^.out('Meteor render complete');
  end;

  { TMeteor private }

  { Other }

end.
