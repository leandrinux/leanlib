{
  GRender Unit
  2022 LRT
}
unit
  GRender;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc, uhashmap, ucanvas,
    gclasses, gtypes, gcrender, gcontrol;

  const
    C_MAX_CONTROL_RENDERER_COUNT = 10;

  type
    PRenderEngine = ^TRenderEngine;
    TRenderEngine = object (TObject)
    public
      { constructors and destructors}
      constructor init;
      destructor done; virtual;
      { extended methods }
      function getClassName: string; virtual;
      function getClassId: word; virtual;
      { methods }
      procedure setCanvas(canvas: PCanvas);
      function getCanvas: PCanvas;
      procedure register(controlClassId: word; renderer: PControlRenderer);
      procedure render(control: PControl);
    private
      _hashmap: PHashMap;
      _canvas: PCanvas;
    end;

implementation

  { TRenderEngine public }

  constructor TRenderEngine.init;
  begin
    inherited init;
    _hashmap := new (PHashMap, initWithSize(C_MAX_CONTROL_RENDERER_COUNT));
    _canvas := nil;
  end;

  destructor TRenderEngine.done;
  begin
    _hashmap^.release;
    inherited done;
  end;

  function TRenderEngine.getClassName: string;
  begin
    getClassName := 'TRenderEngine';
  end;

  function TRenderEngine.getClassId: word;
  begin
    getClassId := C_CLASS_ID_RenderEngine;
  end;

  procedure TRenderEngine.setCanvas(canvas: PCanvas);
  begin
    _canvas := canvas;
  end;

  function TRenderEngine.getCanvas: PCanvas;
  begin
    getCanvas := _canvas;
  end;

  procedure TRenderEngine.register(controlClassId: word; renderer: PControlRenderer);
  begin
    _hashmap^.add(controlClassId, renderer);
  end;

  procedure TRenderEngine.render(control: PControl);
  var
    cr: PControlRenderer;
  begin
    if _canvas = nil then exit;
    if control^.isHidden then exit;
    cr := PControlRenderer(_hashmap^.get(control^.getClassId));
    if cr = nil then exit;
    cr^.setCanvas(_canvas);
    cr^.render(control);
  end;

  { TRenderEngine private }

  { Other }

end.
