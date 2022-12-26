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
    gclasses, gtypes, gcontrol, gcolors;

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
      function getTextColor: TColor;
      procedure setTextColor(textColor: TColor);
      function getTextAlign: EAlignment;
      procedure setTextAlign(textAlign: EAlignment);
    private
      _text: string;
      _textColor: TColor;
      _textAlign: EAlignment;
    end;

implementation

  { TLabel public }

  constructor TLabel.initWithId(id: TControlId);
  begin
    inherited initWithId(id);
    _text := '';
    _textColor := DefaultColorScheme^.getColor(ECKLabelText);
    _textAlign := EAlignTopLeft;
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

  function TLabel.getTextColor: TColor;
  begin
    getTextColor := _textColor;
  end;

  procedure TLabel.setTextColor(textColor: TColor);
  begin
    _textColor := textColor;
  end;

  function TLabel.getTextAlign: EAlignment;
  begin
    getTextAlign := _textAlign;
  end;

  procedure TLabel.setTextAlign(textAlign: EAlignment);
  begin
    _textAlign := textAlign;
  end;

  { TLabel private }

  { Other }

end.
