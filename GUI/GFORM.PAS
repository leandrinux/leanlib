{
  GForm Unit

  2022 LRT
}
unit
  GForm;

interface

  uses
    ascii, consts, utils, uclasses, types, locale,
    uobject, uexc, ustream, udict, ujson, ufstream, ucstream,
    gclasses, gattribs, gtypes, gmsgs, gcontrol, gfactory, gpanel, glabel, gbutton;

  const
    C_FORM_CONTROLS_TITLE = 1;
    C_FORM_CONTROLS_CLOSE = 2;
    C_FORM_CONTROLS_DEFAULT = C_FORM_CONTROLS_TITLE + C_FORM_CONTROLS_CLOSE;
    
  type
    TFormControlsMask = byte;
     
    PForm = ^TForm;
    TForm = object (TObject)
    public
      { constructors and destructors}
      constructor init;
      destructor done; virtual;
      { extended methods }
      function getClassName: string; virtual;
      function getClassId: word; virtual;
      { methods }
      procedure loadFromDictionary(data: PDictionary);
      procedure loadFromJson(stream: PStream);
      procedure loadFromFile(filename: string);
      function getPanel: PPanel;
      function getTitleLabel: PLabel;
      procedure onEvent(opcode: word; sender: PControl); virtual;
      procedure setControls(controls: TFormControlsMask);
    private
      _controls: TFormControlsMask;
      _rootPanel: PPanel;
      _titleLabel: PLabel;
      _closeButton: PButton;
    end;

implementation

  const
    C_DEFAULT_PANEL_WIDTH = 250;
    C_DEFAULT_PANEL_HEIGHT = 100;
    C_DEFAULT_TITLE = '';
    C_DEFAULT_TITLE_BACKGROUND_COLOR = ord(ELightBlue);
    C_DEFAULT_TITLE_TEXT_COLOR = ord(EWhite);
    C_DEFAULT_CLOSE_BUTTON_TEXT = C_CHR_CLOSE;
    C_DEFAULT_TITLE_BAR_HEIGHT = 13;
    C_DEFAULT_CLOSE_BUTTON_WIDTH = 13;

  { TForm public }

  constructor TForm.init;
  begin
    inherited init;
    _controls := C_FORM_CONTROLS_DEFAULT;

    { root panel }
    _rootPanel := new(PPanel, init);
    with _rootPanel^, getFrame^, size do
    begin
      width := C_DEFAULT_PANEL_WIDTH;
      height := C_DEFAULT_PANEL_HEIGHT;
      setDelegate(@self);
    end;

    { title label }
    if (_controls and C_FORM_CONTROLS_TITLE) <> 0 then
    begin
      _titleLabel := new(PLabel, init);
      with _titleLabel^, getFrame^, size do
      begin
        setText(C_DEFAULT_TITLE);
        setBackgroundColor(C_DEFAULT_TITLE_BACKGROUND_COLOR);
        setAlignment(EAlignNone);
        setTextColor(C_DEFAULT_TITLE_TEXT_COLOR);
        setTextAlignment(EAlignCenter);
        width := C_DEFAULT_PANEL_WIDTH;
        height := C_DEFAULT_TITLE_BAR_HEIGHT;
      end;
      _rootPanel^.addControl(_titleLabel);
      _titleLabel^.release;
    end else
      _titleLabel := nil;

    { close button }
    if (_controls and C_FORM_CONTROLS_CLOSE) <> 0 then
    begin
      _closeButton := new(PButton, init);
      with _closeButton^, getFrame^, size do
      begin
        setCaption(C_DEFAULT_CLOSE_BUTTON_TEXT);
        setAlignment(EAlignTopRight);
        width := C_DEFAULT_CLOSE_BUTTON_WIDTH;
        height := C_DEFAULT_TITLE_BAR_HEIGHT;
      end;
      _rootPanel^.addControl(_closeButton);
      _closeButton^.release;
    end else
    begin
      _closeButton := nil;      
    end;

  end;

  destructor TForm.done;
  begin
    inherited done;
    _titleLabel^.release;
    _rootPanel^.release;
  end;

  function TForm.getClassName: string;
  begin
    getClassName := 'TForm';
  end;

  function TForm.getClassId: word;
  begin
    getClassId := C_CLASS_ID_Form;
  end;

  procedure TForm.loadFromDictionary(data: PDictionary);
  var
    cf: PControlFactory;
  begin
    getTitleLabel^.setText(data^.getString(C_ATTR_TITLE, ''));
    cf := new(PControlFactory, init);
    cf^.initPanel(_rootPanel, data);
    cf^.release;    
    
  end;

  procedure TForm.loadFromJson(stream: PStream);
  var
    json: PJsonReader;
    control: PControl;
    obj: PObject;
  begin
    json := new(PJsonReader, init);
    obj := json^.createFromStream(stream);
    xassert(obj^.getClassId = C_CLASS_ID_DICTIONARY, 0, 'Root object in GUI file not a dictionary!');
    loadFromDictionary(PDictionary(obj));
    obj^.release;
    json^.release;
  end;

  procedure TForm.loadFromFile(filename: string);
  var
    fs: PFileStream;
    cs: PCachedStream;
  begin
    fs := new(PFileStream, initWithPath(filename, EFileReadOnly));
    cs := new(PCachedStream, initWithStream(fs, 2048));
    loadFromJson(cs);
    cs^.release;
    fs^.release;
  end;

  function TForm.getPanel: PPanel;
  begin
    getPanel := _rootPanel;
  end;

  function TForm.getTitleLabel: PLabel;
  begin
    getTitleLabel := _titleLabel;
  end;

  procedure TForm.onEvent(opcode: word; sender: PControl);
  begin
    if (opcode = C_MSG_CONTROL_CLICKED) and (sender = PControl(_closeButton)) then
      sendMessage(C_MSG_CLOSE_SIGNAL, getDelegate);
  end;

  procedure TForm.setControls(controls: TFormControlsMask);
  begin
    _controls := controls;
  end;

  { TForm private }

  { Other }

end.
