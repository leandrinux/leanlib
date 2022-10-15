{
  GPanel Unit
  2022 LRT
}
unit
  GPanel;

interface

  uses
    consts, utils, uclasses, types, locale, ustring, udict, 
    uobject, uexc,
    gclasses, gtypes, gcontrol;

  const
    C_CONTROL_TYPE_PANEL = 'panel';

  type
    PPanel = ^TPanel;
    TPanel = object (TControl)
    public
      { constructors and destructors}
      constructor initWithId(id: TControlId);
      constructor initWithObjects(obj: PObject);
      destructor done; virtual;
      { extended methods }
      function getClassName: string; virtual;
      function getClassId: word; virtual;
      { methods }
    private
    end;

implementation

  { TPanel public }

  constructor TPanel.initWithId(id: TControlId);
  begin
    inherited initWithId(id);
  end;

  constructor TPanel.initWithObjects(obj: PObject);
  begin
    inherited initWithObjects(obj);
  end;

  destructor TPanel.done;
  begin
    inherited done;
  end;

  function TPanel.getClassName: string;
  begin
    getClassName := 'TPanel';
  end;

  function TPanel.getClassId: word;
  begin
    getClassId := C_CLASS_ID_Panel;
  end;

  { TPanel private }

  { Other }

end.
