{
  GAlert Unit

  2022 LRT
}
unit
  GAlert;

interface

  uses
    consts, utils, uclasses, types, locale, math,
    uobject, uexc, utrender, usysfont,
    gclasses, gtypes, gcontrol, gpanel, gform;

  const
    C_BTN_OK     = 1;
    C_BTN_CANCEL = 2;
    C_BTN_YES    = 4;
    C_BTN_NO     = 8;
    C_BTN_CLOSE  = 16;

  type
    TTitleText = string[32];

    TMessageText = string[64];

    TButtonsMask = byte;

    PAlertForm = ^TAlertForm;
    TAlertForm = object (TForm)
    public
      { constructors and destructors}
      constructor initWithTitle(title: TTitleText; message: TMessageText; buttons: TButtonsMask);
      destructor done; virtual;
      { extended methods }
      function getClassName: string; virtual;
      function getClassId: word; virtual;
      procedure onStart; virtual;
      { methods }
    private
      _message: TMessageText;
      _tr: PTextRenderer;
      _titleSize, _messageSize: TSize;
    end;

implementation

  const
    C_HORIZONTAL_MARGIN = 15;

  { TAlertForm public }

  constructor TAlertForm.initWithTitle(title: TTitleText; message: TMessageText; buttons: TButtonsMask);
  begin
    inherited init;
    _message := message;
    _tr := new(PTextRenderer, init);
    _tr^.setFont(SystemFont);
    _tr^.getTextSize(title, @_titleSize);
    _tr^.getTextSize(_message, @_messageSize);
    getTitleLabel^.setText(title);

    with getPanel^, getFrame^, size do
    begin
      { width := (C_HORIZONTAL_MARGIN shl 1) + maxword(_titleSize.width, _messageSize.width); }
      { log('Calculated form width: ' + inttostr(width)); }
    end;
  end;

  destructor TAlertForm.done;
  begin
    _tr^.release;
    inherited done;
  end;

  procedure TAlertForm.onStart;
  begin
  end;

  function TAlertForm.getClassName: string;
  begin
    getClassName := 'TAlertForm';
  end;

  function TAlertForm.getClassId: word;
  begin
    getClassId := C_CLASS_ID_AlertForm;
  end;

  { TAlertForm private }

  { Other }

end.
