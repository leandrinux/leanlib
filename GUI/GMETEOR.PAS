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
    gclasses, gtypes, grender, gcolors, gcontrol, gpanel, glabel, gbutton;

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
      procedure renderControl(control: PControl); virtual;
      procedure renderPanel(panel: PPanel); virtual;
      procedure renderLabel(lbl: PLabel); virtual;
      procedure renderButton(button: PButton); virtual;
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

  procedure TMeteor.renderControl(control: PControl);
  var
    absolutePosition: TPoint;
  begin
    control^.getAbsolutePosition(absolutePosition);
    with getCanvas^, control^, getFrame^.size, absolutePosition do
    begin
      if control^.getBackgroundStyle = EBackgroundStyleSolid then
      begin
        getBitmap^.setPixelBlock(x, y, x+width-1, y+height-1, getBackgroundColor);
      end;
    end;
  end;

  procedure TMeteor.renderPanel(panel: PPanel);
  var
    absolutePosition: TPoint;
    colorTL, colorBR: TColor;
    control: PControl;
  begin
    renderControl(panel);
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
    x, y: word;
    textSize: TSize;
  begin
    renderControl(lbl);
    lbl^.getAbsolutePosition(absolutePosition);
    getCanvas^.getStrokeBrush^.color := lbl^.getTextColor;
    tr := new(PTextRenderer, init);
    tr^.setCanvas(getCanvas);
    tr^.getTextSize(lbl^.getText, @textSize);
    x := absolutePosition.x;
    y := absolutePosition.y;
    case lbl^.getTextAlign of
      ETextAlignTop, ETextAlignCenter, ETextAlignBottom:
        inc(x, (lbl^.getFrame^.size.width div 2) - (textSize.width div 2));
      ETextAlignTopRight, ETextAlignRight, ETextAlignBottomRight:
        inc(x, lbl^.getFrame^.size.width - textSize.width);
    end;
    case lbl^.getTextAlign of
      ETextAlignLeft, ETextAlignCenter, ETextAlignRight:
        inc(y, (lbl^.getFrame^.size.height div 2) - (textSize.height div 2));
      ETextAlignBottomLeft, ETextAlignBottom, ETextAlignBottomRight:
        inc(y, lbl^.getFrame^.size.height - textSize.height);
    end;
    tr^.setCursor(x, y);
    tr^.write(lbl^.getText);
    tr^.release;
  end;

  procedure TMeteor.renderButton(button: PButton);
  var
    absolutePosition: TPoint;
    colorTL, colorBR: TColor;
    tr: PTextRenderer;
    x, y: word;
    textSize: TSize;
  begin
    renderControl(button);
    button^.getAbsolutePosition(absolutePosition);
    x := absolutePosition.x;
    y := absolutePosition.y;
    case button^.getState of
      EButtonStateUp:
      begin
        colorTL := DefaultColorScheme^.getColor(ECKPanelBorderTopLeft);
        colorBR := DefaultColorScheme^.getColor(ECKPanelBorderBottomRight);
      end;

      EButtonStateDown:
      begin
        colorTL := DefaultColorScheme^.getColor(ECKPanelBorderBottomRight);
        colorBR := DefaultColorScheme^.getColor(ECKPanelBorderTopLeft);
      end;
    end;
    with getCanvas^, button^.getFrame^, size do
    begin
      getStrokeBrush^.color := colorTL;
      hline(x, x + width - 1, y);
      vline(y + 1, y + height - 1, x);
      getStrokeBrush^.color := colorBR;
      hline(x, x + width - 1, y + height - 1);
      vline(y + 1, y + height - 1, x + width - 1); 
    end;   

    tr := new(PTextRenderer, init);
    tr^.setCanvas(getCanvas);
    tr^.getTextSize(button^.getCaption, @textSize);
    inc(x, (button^.getFrame^.size.width div 2) - (textSize.width div 2));
    inc(y, (button^.getFrame^.size.height div 2) - (textSize.height div 2));
    getCanvas^.getStrokeBrush^.color := DefaultColorScheme^.getColor(ECKButtonText);
    tr^.setCursor(x, y);
    tr^.write(button^.getCaption);
    tr^.release; 
  end;

  { TMeteor private }

  { Other }

end.
