{
  GRender Unit

  2022 LRT
}
unit
  GRender;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc, ucanvas, umouse, udisplay, 
    gclasses, gtypes, gcontrol, gpanel, glabel, gbutton, gchkbox, gfield;

  type
    PRenderer = ^TRenderer;
    TRenderer = object (TObject)
    public
      { constructors and destructors}
      constructor initWithCanvas(canvas: PCanvas);
      destructor done; virtual;
      { extended methods }
      function getClassName: string; virtual;
      function getClassId: word; virtual;
      { methods }
      function getRendererName: string16; virtual;
      function getCanvas: PCanvas;
      procedure render(control: PControl);
      procedure renderControl(control: PControl); virtual;
      procedure renderPanel(panel: PPanel); virtual;
      procedure renderLabel(lbl: PLabel); virtual;
      procedure renderButton(button: PButton); virtual;
      procedure renderCheckbox(checkbox: PCheckbox); virtual;
      procedure renderTextField(textField: PTextField); virtual;
    private
      _canvas: PCanvas;
    end;

implementation

  { TRenderer public }

  constructor TRenderer.initWithCanvas(canvas: PCanvas);
  begin
    inherited init;
    _canvas := canvas;
    _canvas^.retain;
  end;

  destructor TRenderer.done;
  begin
    _canvas^.release;
    inherited done;
  end;

  function TRenderer.getClassName: string;
  begin
    getClassName := 'TRenderer';
  end;

  function TRenderer.getClassId: word;
  begin
    getClassId := C_CLASS_ID_Renderer;
  end;

  function TRenderer.getRendererName: string16;
  begin
    getRendererName := getClassName;
  end;

  function TRenderer.getCanvas: PCanvas;
  begin
    getCanvas := _canvas;
  end;

  procedure TRenderer.render(control: PControl);
  begin
    Mouse^.hide;
    control^.setCanvas(getCanvas);
    case control^.getClassId of
      C_CLASS_ID_CONTROL: renderControl(control);
      C_CLASS_ID_PANEL: renderPanel(PPanel(control));
      C_CLASS_ID_LABEL: renderLabel(PLabel(control));
      C_CLASS_ID_BUTTON: renderButton(PButton(control));
      C_CLASS_ID_CHECKBOX: renderCheckbox(PCheckbox(control));
      C_CLASS_ID_TEXTFIELD: renderTextField(PTextField(control));
    end;
    Mouse^.show;
  end;

  { TRenderer private }

  procedure TRenderer.renderControl(control: PControl);
  var
    parent: PControl;
    parentSize: TSize;
  begin
    { update control frame point when alignment <> EAlignNone }
    if control^.getAlignment <> EAlignNone then
    begin
      parent := control^.getParent;
      if parent <> nil then
      begin
        parentSize := parent^.getFrame^.size; 
      end else begin
        parentSize.width := DisplayAdapter^.getCurrentVideoMode^.resX;
        parentSize.height := DisplayAdapter^.getCurrentVideoMode^.resY;
      end;
      with control^.getFrame^ do
      begin
        case control^.getAlignment of
          EAlignTop, EAlignCenter, EAlignBottom:
            point.x := (parentSize.width div 2) - (size.width div 2);
          EAlignTopRight, EAlignRight, EAlignBottomRight:
            point.x := parentSize.width - size.width;
          EAlignTopLeft, EAlignLeft, EAlignBottomLeft:
            point.x := 0;
        end;
        case control^.getAlignment of
          EAlignLeft, EAlignCenter, EAlignRight:
            point.y := (parentSize.height div 2) - (size.height div 2);
          EAlignBottomLeft, EAlignBottom, EAlignBottomRight:
            point.y := parentSize.height - size.height;
          EAlignTopLeft, EAlignTop, EAlignTopRight:
            point.y := 0;
        end;
      end;
    end;  
  end;
  
  procedure TRenderer.renderPanel(panel: PPanel);
  begin
  end;

  procedure TRenderer.renderLabel(lbl: PLabel);
  begin
  end;

  procedure TRenderer.renderButton(button: PButton);
  begin
  end;

  procedure TRenderer.renderCheckbox(checkbox: PCheckbox);
  begin
  end;

  procedure TRenderer.renderTextField(textField: PTextField);
  begin
  end;

  { Other }

end.
