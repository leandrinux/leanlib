{
  GMeteor Unit
  2022 LRT
}
unit
  GMeteor;

interface

  uses
    consts, utils, uclasses, types, locale, palette,
    uobject, uexc, ucanvas, utrender,
    gclasses, gtypes, grender, gcolors, gcontrol, gpanel, glabel;

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
      procedure renderLabel(lbl: PLabel); virtual;
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
    absolutePosition: TPoint;
    colorTL, colorBR: TColor;
    control: PControl;
  begin
    panel^.getAbsolutePosition(absolutePosition);
    with getCanvas^, panel^, getFrame^.size, absolutePosition, DefaultColorScheme^  do
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
      hline(x, x + width - 1, y);
      vline(y + 1, y + height - 1, x);
      getStrokeBrush^.color := colorBR;
      hline(x, x + width - 1, y + height - 1);
      vline(y + 1, y + height - 1, x + width - 1);
      getStrokeBrush^.color := getBackgroundColor;
      getFillBrush^.color := getStrokeBrush^.color;
      frect(x + 1, y + 1, width - 2, height - 2);
      
      with getControls^ do
      begin
        moveToStart;
        control := PControl(getObjectAtCursor);
        while control<>nil do
        begin
          render(control);
          moveForward;
          control := PControl(getObjectAtCursor);
        end;
      end;
      
    end;
  end;

  procedure TMeteor.renderLabel(lbl: PLabel);
  var
    absolutePosition: TPoint;
    tr: PTextRenderer;
  begin
    lbl^.getAbsolutePosition(absolutePosition);
    getCanvas^.getStrokeBrush^.color := DefaultColorScheme^.getColor(ECKLabelText);
    tr := new(PTextRenderer, init);
    tr^.setCanvas(getCanvas);
    tr^.setCursor(absolutePosition.x, absolutePosition.y);
    tr^.write(lbl^.getText);
    tr^.release;
  end;

  { TMeteor private }

  { Other }

end.
