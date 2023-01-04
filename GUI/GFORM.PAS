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

  type
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
      procedure setTitle(title: string);
      function getTitle: string;
      procedure onEvent(opcode: word; sender: PControl); virtual;
    private
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
    C_DEFAULT_TITLE_HORIZONTAL_MARGIN = 13;
    C_DEFAULT_CLOSE_BUTTON_TEXT = C_CHR_CLOSE;
    C_DEFAULT_TITLE_BAR_HEIGHT = 13;
    C_DEFAULT_CLOSE_BUTTON_WIDTH = 13;

  { TForm public }

  constructor TForm.init;
  begin
    inherited init;

    { root panel }
    _rootPanel := new(PPanel, init);
    with _rootPanel^, getFrame^, size do
    begin
      width := C_DEFAULT_PANEL_WIDTH;
      height := C_DEFAULT_PANEL_HEIGHT;
      setDelegate(@self);
    end;

    { title label }
    _titleLabel := new(PLabel, init);
    with _titleLabel^, getFrame^, size do
    begin
      setText(C_DEFAULT_TITLE);
      setBackgroundColor(C_DEFAULT_TITLE_BACKGROUND_COLOR);
      setAlignment(EAlignTopLeft);
      setTextColor(C_DEFAULT_TITLE_TEXT_COLOR);
      setTextAlignment(EAlignCenter);
      width := C_DEFAULT_PANEL_WIDTH - C_DEFAULT_TITLE_HORIZONTAL_MARGIN;
      height := C_DEFAULT_TITLE_BAR_HEIGHT;
    end;
    _rootPanel^.addControl(_titleLabel);
    _titleLabel^.release;

    { close button }
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
    setTitle(data^.getString(C_ATTR_TITLE, ''));
    cf := new(PControlFactory, init);
    cf^.initPanel(_rootPanel, data);
    cf^.release;    
    _titleLabel^.getFrame^.size.width := _rootPanel^.getFrame^.size.width - C_DEFAULT_TITLE_HORIZONTAL_MARGIN;
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

  procedure TForm.setTitle(title: string);
  begin
    _titleLabel^.setText(title);
  end;

  function TForm.getTitle: string;
  begin
    getTitle := _titleLabel^.getText;
  end;

  procedure TForm.onEvent(opcode: word; sender: PControl);
  begin
    if (opcode = C_MSG_CONTROL_CLICKED) and (sender = PControl(_closeButton)) then
      sendMessage(C_MSG_CLOSE_SIGNAL, getDelegate);
  end;

  { TForm private }

  { Other }

end.
