{
  GLabel Unit
  2022 LRT
}
unit
  GLabel;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc,
    gclasses, gtypes, gcontrol;

  type
    PLabel = ^TLabel;
    TLabel = object (TControl)
    public
      { constructors and destructors}
      constructor initWithId(id: TControlId);
      destructor done; virtual;
      { extended methods }
      function getClassName: string; virtual;
      function getClassId: word; virtual;
      { methods }
      function getText: string;
      procedure setText(text: string);
    private
      _text: string;
    end;

implementation

  { TLabel public }

  constructor TLabel.initWithId(id: TControlId);
  begin
    inherited initWithId(id);
    _text := '';
  end;

  destructor TLabel.done;
  begin
    inherited done;
  end;

  function TLabel.getClassName: string;
  begin
    getClassName := 'TLabel';
  end;

  function TLabel.getClassId: word;
  begin
    getClassId := C_CLASS_ID_Label;
  end;

  function TLabel.getText: string;
  begin
    getText := _text;
  end;

  procedure TLabel.setText(text: string);
  begin
    _text := text;
  end;

  { TLabel private }

  { Other }

end.
