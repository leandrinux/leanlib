{
  GLabel Unit
  2022 LRT
}
unit
  GLabel;

interface

  uses
    consts, utils, types, locale,
    uclasses, uobject, uexc, utrender, 
    gclasses, gtypes, gcontrol, gcolors;

  type
    PLabel = ^TLabel;
    TLabel = object (TControl)
    public
      { constructors and destructors}
      constructor init;
      destructor done; virtual;
      { extended methods }
      function getClassName: string; virtual;
      function getClassId: word; virtual;
      procedure receiveMessage(msg: PObjectMessage); virtual;
      { methods }
      function getText: string;
      procedure setText(text: string);
      function getTextColor: TColor;
      procedure setTextColor(textColor: TColor);
      function getTextAlignment: EAlignment;
      procedure setTextAlignment(textAlign: EAlignment);
      procedure adjustSizeToText;
    private
      _text: string;
      _textColor: TColor;
      _textAlign: EAlignment;
    end;

implementation

  const
    C_DEFAULT_LABEL_WIDTH = 75;
    C_DEFAULT_LABEL_HEIGHT = 14;

  { TLabel public }

  constructor TLabel.init;
  begin
    inherited init;
    _text := '';
    _textColor := DefaultColorScheme^.getColor(ECKLabelText);
    _textAlign := EAlignLeft;
    with getFrame^, point, size do
    begin
      x := 0;
      y := 0;
      width := C_DEFAULT_LABEL_WIDTH;
      height := C_DEFAULT_LABEL_HEIGHT;
    end;
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

  procedure TLabel.receiveMessage(msg: PObjectMessage);
  begin
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

  function TLabel.getTextAlignment: EAlignment;
  begin
    getTextAlignment := _textAlign;
  end;

  procedure TLabel.setTextAlignment(textAlign: EAlignment);
  begin
    _textAlign := textAlign;
  end;

  procedure TLabel.adjustSizeToText;
  var
    tr: PTextRenderer;
  begin
    tr := new(PTextRenderer, init);
    tr^.getTextSize(_text, @(getFrame^.size));
    tr^.release;
  end;

  { TLabel private }

  { Other }

end.
