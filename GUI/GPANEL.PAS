{
  GPanel Unit
  2022 LRT
}
unit
  GPanel;

interface

  uses
    consts, utils, uclasses, types, locale, ustring, ulist,
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
      destructor done; virtual;
      { extended methods }
      function getClassName: string; virtual;
      function getClassId: word; virtual;
      { methods }
      function getControls: PList;
    private
      _controls: PList;
    end;

implementation

  { TPanel public }

  constructor TPanel.initWithId(id: TControlId);
  begin
    inherited initWithId(id);
    _controls := new(PList, initWithClassFamily(C_CLASS_ID_CONTROL, C_CLASS_ID_CONTROL_FAMILY));
  end;

  destructor TPanel.done;
  begin
    _controls^.release;
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

  function TPanel.getControls: PList;
  begin
    getControls := _controls;
  end;
  
  { TPanel private }

  { Other }

end.
