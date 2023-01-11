{
  GCRender Unit
  2022 LRT
}
unit
  GCRender;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc, ucanvas, 
    gclasses, gtypes, gcontrol;

  type
    PControlRenderer = ^TControlRenderer;
    TControlRenderer = object (TObject)
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
      procedure render(control: PControl); virtual;
      function getAbsolutePosition: PPoint;
    private
      _canvas: PCanvas;
      _absolutePosition: TPoint;
    end;

implementation

  { TControlRenderer public }

  constructor TControlRenderer.init;
  begin
    inherited init;
    _canvas := nil;
  end;

  destructor TControlRenderer.done;
  begin
    inherited done;
  end;

  function TControlRenderer.getClassName: string;
  begin
    getClassName := 'TControlRenderer';
  end;

  function TControlRenderer.getClassId: word;
  begin
    getClassId := C_CLASS_ID_ControlRenderer;
  end;

  procedure TControlRenderer.setCanvas(canvas: PCanvas);
  begin
    _canvas := canvas;
  end;

  function TControlRenderer.getCanvas: PCanvas;
  begin
    getCanvas := _canvas;
  end;

  procedure TControlRenderer.render(control: PControl);
  var
    parent: PControl;
    parentSize: TSize;
  begin
    control^.findAbsolutePosition(_absolutePosition);
    { update control frame point when alignment <> EAlignNone }
    if control^.getAlignment <> EAlignNone then
    begin
      parent := control^.getParent;
      if parent <> nil then
      begin
        parentSize := parent^.getFrame^.size; 
      end else begin
        parentSize.width := getCanvas^.getBitmap^.getWidth;
        parentSize.height := getCanvas^.getBitmap^.getHeight;
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

  function TControlRenderer.getAbsolutePosition: PPoint;
  begin
    getAbsolutePosition := @_absolutePosition;
  end;

  { TControlRenderer private }

  { Other }

end.
