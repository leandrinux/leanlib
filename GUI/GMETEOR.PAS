{
  GMeteor Unit
  2022 LRT
}
unit
  GMeteor;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc, ucanvas, utrender,
    gclasses, gtypes, gcontrol, gmsgs, grender, gcrender, gcolors, gpanel, glabel, gbutton, gchkbox, gfield;

  type
    PBaseRenderer = ^TBaseRenderer; 
    TBaseRenderer = object(TControlRenderer)
      procedure render(control: PControl); virtual;
    end;

    PPanelRenderer = ^TPanelRenderer;
    TPanelRenderer = object(TBaseRenderer)
      procedure render(control: PControl); virtual;
    end;

    PLabelRenderer = ^TLabelRenderer;
    TLabelRenderer = object(TBaseRenderer)
      procedure render(control: PControl); virtual;
    end;

    PButtonRenderer = ^TButtonRenderer;
    TButtonRenderer = object(TBaseRenderer)
      procedure render(control: PControl); virtual;
    end;

    PCheckboxRenderer = ^TCheckboxRenderer;
    TCheckboxRenderer = object(TBaseRenderer)
      procedure render(control: PControl); virtual;
    end;

    PTextFieldRenderer = ^TTextFieldRenderer;
    TTextFieldRenderer = object(TBaseRenderer)
      procedure render(control: PControl); virtual;
    end;

    PMeteor = ^TMeteor;
    TMeteor = object (TRenderEngine)
    public
      { constructors and destructors}
      constructor init;
      destructor done; virtual;
      { extended methods }
      function getClassName: string; virtual;
      function getClassId: word; virtual;
      { methods }
    private
    end;

implementation

  { Control renderers }

  procedure TBaseRenderer.render(control: PControl);
  begin
    inherited render(control);
    with getAbsolutePosition^, getCanvas^, control^, getFrame^.size do
    begin      
      control^.defaultDraw;
      setPattern(ESolid, getStrokeBrush);
      if control^.getBackgroundStyle = EBackgroundStyleSolid then
      begin
        getBitmap^.setPixelBlock(x, y, x+width-1, y+height-1, getBackgroundColor);
      end;
    end;
  end;

  procedure TPanelRenderer.render(control: PControl);
  var
    colorTL, colorBR: TColor;
  begin
    inherited render(control);
    with getAbsolutePosition^, getCanvas^, PPanel(control)^, getFrame^.size, DefaultColorScheme^ do
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
          control^.sendMessage(C_MSG_CONTROL_REQUEST_REDRAW, self.getDelegate);
          moveForward;
          control := PControl(getObjectAtCursor);
        end;
      end;
    end;
  end;

  procedure TLabelRenderer.render(control: PControl);
  var
    tr: PTextRenderer;
    x, y: word;
    textSize: TSize;
    lbl: PLabel;
  begin
    inherited render(control);
    lbl := PLabel(control);
    getCanvas^.getStrokeBrush^.color := lbl^.getTextColor;
    tr := new(PTextRenderer, init);
    tr^.setFont(lbl^.getFont);
    tr^.setCanvas(getCanvas);
    tr^.getTextSize(lbl^.getText, @textSize);
    x := getAbsolutePosition^.x;
    y := getAbsolutePosition^.y;
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

  procedure TButtonRenderer.render(control: PControl);
  var
    colorTL, colorBR: TColor;
    button: PButton;
    tr: PTextRenderer;
    x, y: word;
    textSize: TSize;
  begin
    inherited render(control);
    x := getAbsolutePosition^.x;
    y := getAbsolutePosition^.y;
    button := PButton(control);
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

  procedure TCheckboxRenderer.render(control: PControl);
  var
    checkbox: PCheckbox;
  begin
    inherited render(control);
    (*
    checkbox := PCheckbox(control);
    with checkbox^, getCanvas^, getFrame^, getAbsolutePosition^, size do
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
          x + size.width - 5, y + 4,
          x + 4, y + size.height - 5
        );
      end;
    end;
    *)
  end;

  procedure TTextFieldRenderer.render(control: PControl);
  var
    tr: PTextRenderer;
    textSize: TSize;
    textValue: TTextValue;
    textField: PTextField;
  begin
    inherited render(control);
    (*
    textField := PTextField(control);
    with textField^, getCanvas^, getFrame^, getAbsolutePosition^, size do
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
    *)
  end;

  { TMeteor public }

  constructor TMeteor.init;
  begin
    inherited init;
    register(C_CLASS_ID_CONTROL, PBaseRenderer(new(PBaseRenderer, init)^.autorelease));
    register(C_CLASS_ID_PANEL, PPanelRenderer(new(PPanelRenderer, init)^.autorelease));
    register(C_CLASS_ID_LABEL, PLabelRenderer(new(PLabelRenderer, init)^.autorelease));
    register(C_CLASS_ID_BUTTON, PButtonRenderer(new(PButtonRenderer, init)^.autorelease));
    register(C_CLASS_ID_CHECKBOX, PCheckboxRenderer(new(PCheckboxRenderer, init)^.autorelease));
    register(C_CLASS_ID_TEXTFIELD, PTextFieldRenderer(new(PTextFieldRenderer, init)^.autorelease));
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

  { TMeteor private }

  { Other }

end.
