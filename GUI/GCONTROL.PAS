{
  GControl Unit
  2022 LRT
}
unit
  GControl;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc, udict, 
    gclasses, gtypes;

  type
    PControlId = ^TControlId;
    TControlId = string[8];

    PControl = ^TControl;
    TControl = object (TObject)
    public
      { constructors and destructors}
      constructor initWithId(id: TControlId);
      constructor initWithObjects(obj: PObject);
      destructor done; virtual;
      { extended methods }
      function getClassName: string; virtual;
      function getClassId: word; virtual;
      { methods }
      function getFrame: PFrame;
      function getId: TControlId;
    private
      _frame: TFrame;
      _id: TControlID;
    end;

implementation

  { TControl public }

  constructor TControl.initWithId(id: TControlId);
  begin
    inherited init;
    _id := id;
  end;

  constructor TControl.initWithObjects(obj: PObject);
  var 
    d: PDictionary;
    id: string;
  begin
    inherited init;
    iassert(obj^.getClassId = C_CLASS_ID_DICTIONARY, @self, 0, S_ERR_UNEXPECTED_TYPE);
    d := PDictionary(obj);
    id := d^.getString('id');
    with _frame do
    begin
      point.x := d^.getLongWithPath('frame.x');
      point.y := d^.getLongWithPath('frame.y');
      size.width := d^.getLongWithPath('frame.width');
      size.height := d^.getLongWithPath('frame.height');
    end;
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

  { TControl private }

  { Other }

end.
