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
    gclasses, gtypes, grender, gmsgs, gcolors, gcontrol, gpanel, glabel, gbutton, gchkbox, gfield;

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
      procedure renderCheckbox(checkbox: PCheckbox); virtual;
      procedure renderTextField(textField: PTextField); virtual;
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
    if control^.isHidden then exit;
    inherited renderControl(control);
    with getCanvas^, control^, getFrame^.size, absolutePosition do
    begin      
      control^.defaultDraw;
      getAbsolutePosition(absolutePosition);
      setPattern(ESolid, getStrokeBrush);
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
    if panel^.isHidden then exit;
    renderControl(panel);
    panel^.getAbsolutePosition(absolutePosition);
    with getCanvas^, panel^, getFrame^.size, absolutePosition, DefaultColorScheme^  do
    begin
      case getBorderStyle of        
        EBorderStyleRaised:
        begin
          colorTL := getColor(ECKPanelBorderRaised);
          colorBR := getColor(ECKPanelBorderLowered);
        end;

        EBorderStyleLowered:
        begin
          colorTL := getColor(ECKPanelBorderLowered);
          colorBR := getColor(ECKPanelBorderRaised);
        end;
      end;

      if getBorderStyle <> EBorderStyleNone then
      begin
        getStrokeBrush^.color := colorTL;
        hline(x, x + width - 1, y);
        vline(y + 1, y + height - 1, x);
        getStrokeBrush^.color := colorBR;
        hline(x, x + width - 1, y + height - 1);
        vline(y + 1, y + height - 1, x + width - 1);
      end;

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
    if lbl^.isHidden then exit;
    renderControl(lbl);
    lbl^.getAbsolutePosition(absolutePosition);
    getCanvas^.getStrokeBrush^.color := lbl^.getTextColor;
    tr := new(PTextRenderer, init);
    tr^.setFont(lbl^.getFont);
    tr^.setCanvas(getCanvas);
    tr^.getTextSize(lbl^.getText, @textSize);
    x := absolutePosition.x;
    y := absolutePosition.y;
    case lbl^.getTextAlignment of
      EAlignTop, EAlignCenter, EAlignBottom:
        inc(x, (lbl^.getFrame^.size.width div 2) - (textSize.width div 2));
      EAlignTopRight, EAlignRight, EAlignBottomRight:
        inc(x, lbl^.getFrame^.size.width - textSize.width);
    end;
    case lbl^.getTextAlignment of
      EAlignLeft, EAlignCenter, EAlignRight:
        inc(y, (lbl^.getFrame^.size.height div 2) - (textSize.height div 2));
      EAlignBottomLeft, EAlignBottom, EAlignBottomRight:
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
    if button^.isHidden then exit;
    renderControl(button);
    button^.getAbsolutePosition(absolutePosition);
    x := absolutePosition.x;
    y := absolutePosition.y;
    case button^.getState of
      EButtonStateUp:
      begin
        colorTL := DefaultColorScheme^.getColor(ECKPanelBorderRaised);
        colorBR := DefaultColorScheme^.getColor(ECKPanelBorderLowered);
      end;

      EButtonStateDown:
      begin
        colorTL := DefaultColorScheme^.getColor(ECKPanelBorderLowered);
        colorBR := DefaultColorScheme^.getColor(ECKPanelBorderRaised);
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
    tr^.setFont(button^.getFont);
    tr^.getTextSize(button^.getCaption, @textSize);
    inc(x, (button^.getFrame^.size.width div 2) - (textSize.width div 2));
    inc(y, (button^.getFrame^.size.height div 2) - (textSize.height div 2));
    getCanvas^.getStrokeBrush^.color := DefaultColorScheme^.getColor(ECKButtonText);
    tr^.setCursor(x, y);
    tr^.write(button^.getCaption);
    tr^.release; 
  end;

  procedure TMeteor.renderCheckbox(checkbox: PCheckbox);
  var
    absolutePosition: TPoint;
  begin
    if checkbox^.isHidden then exit;
    renderControl(checkbox);
    checkbox^.getAbsolutePosition(absolutePosition);
    with checkbox^, getCanvas^, getFrame^, absolutePosition, size do
    begin
      getStrokeBrush^.color := DefaultColorScheme^.getColor(ECKPanelBorderLowered);
      hline(x, x + width - 1, y);
      vline(y + 1, y + height - 1, x);
      getStrokeBrush^.color := DefaultColorScheme^.getColor(ECKPanelBorderRaised);
      hline(x, x + width - 1, y + height - 1);
      vline(y + 1, y + height - 1, x + width - 1);
      if checkbox^.isChecked then
      begin
        getStrokeBrush^.color := DefaultColorScheme^.getColor(ECKCheckboxSymbol);
        line(
          x + 4, y + 4,
          x + size.width - 5, y + size.height - 5
        );
        line(
          absolutePosition.x + size.width - 5, absolutePosition.y + 4,
          absolutePosition.x + 4, absolutePosition.y + size.height - 5
        );
      end;
    end;
  end;

  procedure TMeteor.renderTextField(textField: PTextField);
  var
    absolutePosition: TPoint;
    tr: PTextRenderer;
    textSize: TSize;
    textValue: TTextValue;
  begin
    if textField^.isHidden then exit;
    renderControl(textField);
    textField^.getAbsolutePosition(absolutePosition);
    with textField^, getCanvas^, getFrame^, absolutePosition, size do
    begin
      { draw borders }
      getStrokeBrush^.color := DefaultColorScheme^.getColor(ECKPanelBorderLowered);
      hline(x, x + width - 1, y);
      vline(y + 1, y + height - 1, x);
      getStrokeBrush^.color := DefaultColorScheme^.getColor(ECKPanelBorderRaised);
      hline(x, x + width - 1, y + height - 1);
      vline(y + 1, y + height - 1, x + width - 1);

      { text } 
      tr := new(PTextRenderer, init);
      tr^.setFont(textField^.getFont);      
      tr^.setCanvas(getCanvas);
      textValue := textField^.getText;
      if not isFocused and (length(textValue) = 0) then 
      begin
        textValue := textField^.getPlaceholder;
        getStrokeBrush^.color := DefaultColorScheme^.getColor(ECKTextPlaceholder);
      end else begin
        getStrokeBrush^.color := DefaultColorScheme^.getColor(ECKLabelText);
      end;
      tr^.getTextSize(textValue, @textSize);
      tr^.setCursor(x + 4, y + 4);
      if not isEnabled then 
      begin
        setPattern(EDots, getStrokeBrush);
        getStrokeBrush^.color := DefaultColorScheme^.getColor(ECKTextDisabled);
      end;
      tr^.write(textValue);
      setPattern(ESolid, getStrokeBrush);
      tr^.release; 

      { focus border }
      getFillBrush^.color := DefaultColorScheme^.getColor(ECKPanelBackground);
      if isFocused then
      begin
        getStrokeBrush^.color := DefaultColorScheme^.getColor(ECKControlFocus);
        setPattern(EDots, getStrokeBrush);
        rect(x+1, y+1, width - 2, height-2);
        setPattern(ESolid, getStrokeBrush);
        { text cursor }
        getStrokeBrush^.color := DefaultColorScheme^.getColor(ECKTextCursor);
        vline(y+4, y + height - 5, x + 6 + textSize.width);
      end;
      
    end;
  end;
  
  { TMeteor private }

  { Other }

end.
