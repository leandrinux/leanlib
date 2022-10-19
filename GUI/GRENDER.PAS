{
  GRender Unit

  2022 LRT
}
unit
  GRender;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc, ucanvas,
    gclasses, gtypes, gcontrol, gpanel, glabel;

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
      procedure renderPanel(panel: PPanel); virtual;
      procedure renderLabel(lbl: PLabel); virtual;
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
    case control^.getClassId of
      C_CLASS_ID_PANEL: renderPanel(PPanel(control));
      C_CLASS_ID_LABEL: renderLabel(PLabel(control));
    end;
  end;

  { TRenderer private }

  procedure TRenderer.renderPanel(panel: PPanel);
  begin
  end;

  procedure TRenderer.renderLabel(lbl: PLabel);
  begin
  end;

  { Other }

end.
