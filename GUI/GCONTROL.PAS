{
  GControl Unit
  2022 LRT
}
unit
  GControl;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc, 
    gclasses, gtypes;

  type
    PControl = ^TControl;
    TControl = object (TObject)
    public
      { constructors and destructors}
      constructor initWithId(id: TControlId);
      destructor done; virtual;
      { extended methods }
      function getClassName: string; virtual;
      function getClassId: word; virtual;
      { methods }
      function getFrame: PFrame;
      function getId: TControlId;
      function getParent: PControl;
      procedure setParent(parent: PControl);
      procedure getAbsolutePosition(var point: TPoint);
    private
      _frame: TFrame;
      _id: TControlID;
      _parent: PControl;
    end;

implementation

  { TControl public }

  constructor TControl.initWithId(id: TControlId);
  begin
    inherited init;
    _id := id;
    _parent := nil;
  end;

  destructor TControl.done;
  begin
    inherited done;
  end;

  function TControl.getClassName: string;
  begin
    getClassName := 'TControl';
  end;

  function TControl.getClassId: word;
  begin
    getClassId := C_CLASS_ID_Control;
  end;

  function TControl.getFrame: PFrame;
  begin
    getFrame := @_frame;
  end;

  function TControl.getId: TControlId;
  begin
    getId := _id;
  end;

  function TControl.getParent: PControl;
  begin
    getParent := _parent;
  end;

  procedure TControl.setParent(parent: PControl);
  begin
    _parent := parent;
  end;

  procedure TControl.getAbsolutePosition(var point: TPoint);
  begin
    with point do
      if _parent = nil then
      begin
        x := _frame.point.x;
        y := _frame.point.y;
      end else begin
        _parent^.getAbsolutePosition(point);
        x := x + _frame.point.x;
        y := y + _frame.point.y;
      end;
  end;

  { TControl private }

  { Other }

end.
