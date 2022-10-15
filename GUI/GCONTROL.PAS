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
