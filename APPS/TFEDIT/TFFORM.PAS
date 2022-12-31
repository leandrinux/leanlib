unit TFForm;
    
interface

  uses
    xcrt, ascii, types, utils,
    uobject, uclasses, uexc, udisplay, usysfont, utfont, ufstream,
    gui, gtypes, gmsgs, gform, gcontrol, gpanel, glabel, gbutton, gfield,
    tfegrid, tfsgrid, tfebase;

  type
    PMainForm = ^TMainForm;
    TMainForm = object (TForm)
      public
        constructor init;
        destructor done; virtual;
        procedure receiveMessage(msg: PObjectMessage); virtual;
        procedure onStart; virtual;
        procedure onEvent(opcode: word; sender: PControl); virtual;
        function createControl: PControl; virtual;
      private
        _quitButton: PButton;
        _loadButton: PButton;
        _saveButton: PButton;
        _clearButton: PButton;
        _updateButton: PButton;
        _indexLabel: PLabel;
        _statusLabel: PLabel;
        _filenameField: PTextField;
        _fontnameField: PTextField;
        _editGrid: PEditGrid;
        _symbolGrid: PSymbolGrid;        
        _font: PTinyFont;
        procedure symbolSelectionChanged;
        procedure updateModifiedSymbol;
        procedure clearSymbols;
        procedure loadFont;
        procedure saveFont;
        procedure loadSystemFont;
    end;

implementation

  const
    C_FILENAME_TEXTFIELD_PLACEHOLDER = 'File name';
    C_FONTNAME_TEXTFIELD_PLACEHOLDER = 'Font name';
    C_LOAD_BUTTON_CAPTION = 'Load';
    C_SAVE_BUTTON_CAPTION = 'Save';
    C_CLEAR_BUTTON_CAPTION = 'Clear';
    C_UPDATE_BUTTON_CAPTION = 'Update';
    C_TITLE_TEXT = 'TinyFont Editor';
    C_TITLE_HMARGIN = 40;
    C_QUIT_BUTTON_CAPTION = 'X';
    C_DEFAULT_FILENAME = 'NEWFONT.FON';
    C_STATUS_CLEAR = 'Clearing...';
    C_STATUS_LOAD = 'Loading...';
    C_STATUS_SAVE = 'Saving...';
    C_STATUS_NONE = '';

  { Public }

  constructor TMainForm.init;
  begin
    _font := nil;
    inherited init;
  end;

  destructor TMainForm.done;
  begin
    if _font <> nil then _font^.release;
    inherited done;
  end;

  procedure TMainForm.receiveMessage(msg: PObjectMessage); 
  begin
    inherited receiveMessage(msg);
    if (msg^.sender = PObject(_symbolGrid)) and (msg^.opcode = C_MSG_CHANGED_SELECTION) then symbolSelectionChanged;
  end;

  function TMainForm.createControl: PControl;
  var 
    panel: PPanel;
    lbl: PLabel;
  begin
    { container panel }
    panel := new(PPanel, init);
    with panel^.getFrame^, size do
    begin
      width := 246;
      height := 190;
    end;

    { title label } 
    lbl := new(PLabel, init);
    with lbl^, getFrame^, point, size do
    begin
      setText(C_TITLE_TEXT);
      setAlignment(EAlignTop);
      setBackgroundColor(ord(EBlue));
      setTextColor(ord(EWhite));
      setTextAlignment(EAlignCenter);
      adjustSizeToText;
      inc(width, C_TITLE_HMARGIN);
    end;
    panel^.addControl(lbl);
    lbl^.release;

    { quit button } 
    _quitButton := new(PButton, init);
    with _quitButton^ do
    begin
      setCaption(C_QUIT_BUTTON_CAPTION);
      setAlignment(EAlignTopRight);
      adjustSizeToText;
    end;
    panel^.addControl(_quitButton);
    _quitButton^.release;

    { load button }
    _loadButton := new(PButton, init);
    with _loadButton^, getFrame^, point, size do
    begin
      setCaption(C_LOAD_BUTTON_CAPTION);
      x := 170;
      y := 172;
      width := 34;
    end;
    panel^.addControl(_loadButton);
    _loadButton^.release;

    { save button }
    _saveButton := new(PButton, init);
    with _saveButton^, getFrame^, point, size do
    begin
      setCaption(C_SAVE_BUTTON_CAPTION);
      x := 206;
      y := 172;
      width := 34;
    end;
    panel^.addControl(_saveButton);
    _saveButton^.release;

    { clear button }
    _clearButton := new(PButton, init);
    with _clearButton^, getFrame^, point, size do
    begin
      setCaption(C_CLEAR_BUTTON_CAPTION);
      x := 5;
      y := 143;
      width := 40;
    end;
    panel^.addControl(_clearButton);
    _clearButton^.release;

    { update button }
    _updateButton := new(PButton, init);
    with _updateButton^, getFrame^, point, size do
    begin
      setCaption(C_UPDATE_BUTTON_CAPTION);
      x := 51;
      y := 143;
      width := 40;
    end;
    panel^.addControl(_updateButton);
    _updateButton^.release;

    { index label }
    _indexLabel := new(PLabel, init);
    with _indexLabel^, getFrame^, point, size do
    begin
      setText('#0');
      x := 5;
      y := 160;
      width := 40;
    end;
    panel^.addControl(_indexLabel);
    _indexLabel^.release;

    { status label }
    _statusLabel := new(PLabel, init);
    with _statusLabel^, getFrame^, point, size do
    begin
      x := 5;
      y := 174;
      width := 70;
    end;
    panel^.addControl(_statusLabel);
    _statusLabel^.release;

    { symbol edit grid }  
    _symbolGrid := new(PSymbolGrid, init);
    with _symbolGrid^, getFrame^, point do
    begin
      x := 95;
      y := 24;
    end;
    _symbolGrid^.setDelegate(@self);
    panel^.addControl(_symbolGrid);
    _symbolGrid^.release;

    { font name text field } 
    _fontnameField := new(PTextField, init);
    with _fontnameField^, getFrame^, point, size do
    begin
      x := 5;
      y := 128; 
      width := 86;
      setPlaceholder(C_FONTNAME_TEXTFIELD_PLACEHOLDER);
    end;
    panel^.addControl(_fontnameField);
    _fontnameField^.release;

    { filename text field }
    _filenameField := new(PTextField, init);
    with _filenameField^, getFrame^, point, size do
    begin
      x := 95;
      y := 172; 
      width := 73;
      setPlaceholder(C_FILENAME_TEXTFIELD_PLACEHOLDER);
      setText(C_DEFAULT_FILENAME);
      setLengthLimit(11);
    end;
    panel^.addControl(_filenameField);
    _filenameField^.release;

    { edit grid }  
    _editGrid := new(PEditGrid, init);
    with _editGrid^, getFrame^, point do
    begin
      x := 5;
      y := 24;
    end;
    panel^.addControl(_editGrid);
    _editGrid^.release;

    createControl := panel;
  end;
  
  procedure TMainForm.onStart;
  begin
    _font := new(PTinyFont, init);
    _symbolGrid^.setFont(_font);
    loadSystemFont;
    _editGrid^.setSymbol(_font^.getSymbol(#0));
  end;

  procedure TMainForm.onEvent(opcode: word; sender: PControl);
  begin
    case opcode of
        C_MSG_CONTROL_CLICKED:
        if sender = PControl(_quitButton) then 
          sendMessage(C_MSG_CLOSE_SIGNAL, getDelegate)
        else if sender = PControl(_updateButton) then 
          updateModifiedSymbol
        else if sender = PControl(_clearButton) then 
          clearSymbols          
        else if sender = PControl(_loadButton) then 
          loadFont
        else if sender = PControl(_saveButton) then 
          saveFont;
    end;
  end;

  { Private }

  procedure TMainForm.symbolSelectionChanged;
  var
    ch: char;
  begin
    _editGrid^.setSymbol(_symbolGrid^.getSelectedSymbol);
    ch := _symbolGrid^.getSelectedChar;
    if (ch >= C_PRINTABLE_FROM) and (ch <= C_PRINTABLE_TO) then
      _indexLabel^.setText('#' + inttostr(ord(ch)) + '(' + ch + ')')
    else
      _indexLabel^.setText('#' + inttostr(ord(ch)));
  end;

  procedure TMainForm.updateModifiedSymbol;
  begin
    _font^.setSymbol(_symbolGrid^.getSelectedChar, _editGrid^.getSymbol);
    _symbolGrid^.redrawCharCell(_symbolGrid^.getSelectedChar);
  end;

  procedure TMainForm.clearSymbols;
  var 
    ch: char;
  begin
    _statusLabel^.setText(C_STATUS_CLEAR);
    for ch := #0 to #255 do _font^.setSymbol(ch, 0);
    _symbolGrid^.requestRedraw;
    symbolSelectionChanged;
    _filenameField^.setText('');
    _fontnameField^.setText('');
    _statusLabel^.setText(C_STATUS_NONE);
  end;

  procedure TMainForm.loadFont;
  var
    fs: PFilestream;
  begin
    _statusLabel^.setText(C_STATUS_LOAD);
    fs := new(PFilestream, initWithPath(_filenameField^.getText, EFileReadOnly));
    _font^.load(fs);
    fs^.release;
    _symbolGrid^.requestRedraw;
    symbolSelectionChanged;
    _fontnameField^.setText(_font^.getName);
    _statusLabel^.setText(C_STATUS_NONE);
  end;

  procedure TMainForm.saveFont;
  var
    fs: PFilestream;
  begin
    _statusLabel^.setText(C_STATUS_SAVE);
    _font^.setName(_fontNameField^.getText);
    fs := new(PFilestream, initWithPath(_filenameField^.getText, EFileCreate));
    _font^.save(fs);
    fs^.release;
    _statusLabel^.setText(C_STATUS_NONE);
  end;

  procedure TMainForm.loadSystemFont;
  var 
    ch: char;
  begin
    for ch := #0 to #255 do 
      _font^.setSymbol(ch, SystemFont^.getSymbol(ch));
    _fontNameField^.setText(SystemFont^.getName);
  end;

end.