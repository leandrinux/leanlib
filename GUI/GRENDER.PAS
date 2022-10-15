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
    gclasses, gtypes, gpanel;

  type
    PRenderer = ^TRenderer;
    TRenderer = object (TObject)
    public
      { constructors and destructors}
      constructor initWithCanvas(canvas: PCanvas; colorScheme: PColorScheme);
      destructor done; virtual;
      { extended methods }
      function getClassName: string; virtual;
      function getClassId: word; virtual;
      { methods }
      procedure doPanel(panel: PPanel);
    private
      _canvas: PCanvas;
      _colorScheme: PColorScheme;
    end;

implementation

  { TRenderer public }

  constructor TRenderer.initWithCanvas(canvas: PCanvas; colorScheme: PColorScheme);
  begin
    inherited init;
    _canvas := canvas;
    _canvas^.retain;
    _colorScheme := colorScheme;
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

  procedure TRenderer.doPanel(panel: PPanel);
  begin
    with _canvas^, panel^.getFrame^ do
    begin
      getStrokeBrush^.color := _colorScheme^[ECKPanelBorderTopLeft];

    end;
  end;

  { TRenderer private }

  { Other }

end.
