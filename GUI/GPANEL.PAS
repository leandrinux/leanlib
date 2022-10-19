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
    gclasses, gtypes, gcontrol, gcolors;

  const
    C_CONTROL_TYPE_PANEL = 'panel';
    C_DEFAULT_PANEL_BORDER_STYLE = EBorderStyleNone;

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
      procedure setBorderStyle(borderStyle: EBorderStyle);
      function getBorderStyle: EBorderStyle;
      procedure setBackgroundColor(backgroundColor: TColor);
      function getBackgroundColor: TColor;
    private
      _controls: PList;
      _borderStyle: EBorderStyle;
      _backgroundColor: TColor;
    end;

implementation

  { TPanel public }

  constructor TPanel.initWithId(id: TControlId);
  begin
    inherited initWithId(id);
    _controls := new(PList, initWithClassFamily(C_CLASS_ID_CONTROL, C_CLASS_ID_CONTROL_FAMILY));
    _borderStyle := C_DEFAULT_PANEL_BORDER_STYLE;
    _backgroundColor := DefaultColorScheme^.getColor(ECKPanelBackground);
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

  procedure TPanel.setBorderStyle(borderStyle: EBorderStyle);
  begin
    _borderStyle := borderStyle;
  end;

  function TPanel.getBorderStyle: EBorderStyle;
  begin
    getBorderStyle := _borderStyle;
  end;

  procedure TPanel.setBackgroundColor(backgroundColor: TColor);
  begin
    _backgroundColor := backgroundColor;
  end;

  function TPanel.getBackgroundColor: TColor;
  begin
    getBackgroundColor := _backgroundColor;
  end;
  { TPanel private }

  { Other }

end.
