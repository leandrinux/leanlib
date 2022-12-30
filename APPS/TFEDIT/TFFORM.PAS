unit TFForm;
    
interface

  uses
    xcrt, ascii, types, utils,
    uobject, uclasses, uexc, udisplay, usysfont, utfont,
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
        _filenameField: PTextField;
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
    C_LOAD_BUTTON_CAPTION = 'Load';
    C_SAVE_BUTTON_CAPTION = 'Save';
    C_CLEAR_BUTTON_CAPTION = 'Clear';
    C_UPDATE_BUTTON_CAPTION = 'Update';
    C_TITLE_TEXT = 'TinyFont Editor';
    C_TITLE_HMARGIN = 40;
    C_QUIT_BUTTON_CAPTION = 'X';
    C_MIN_PRINTABLE_CHAR = #32;
    C_MAX_PRINTABLE_CHAR = #126;

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
      x := 5;
      y := 143;
      width := 40;
    end;
    panel^.addControl(_loadButton);
    _loadButton^.release;

    { save button }
    _saveButton := new(PButton, init);
    with _saveButton^, getFrame^, point, size do
    begin
      setCaption(C_SAVE_BUTTON_CAPTION);
      x := 51;
      y := 143;
      width := 40;
    end;
    panel^.addControl(_saveButton);
    _saveButton^.release;

    { clear button }
    _clearButton := new(PButton, init);
    with _clearButton^, getFrame^, point, size do
    begin
      setCaption(C_CLEAR_BUTTON_CAPTION);
      x := 5;
      y := 159;
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
      y := 159;
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
      y := 174;
      width := 34;
    end;
    panel^.addControl(_indexLabel);
    _indexLabel^.release;

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
    _filenameField := new(PTextField, init);
    with _filenameField^, getFrame^, point, size do
    begin
      x := 5;
      y := 128; 
      width := 86;
      setPlaceholder(C_FILENAME_TEXTFIELD_PLACEHOLDER);
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
  end;

  procedure TMainForm.onEvent(opcode: word; sender: PControl);
  begin
    case opcode of
        C_MSG_CONTROL_CLICKED:
        if sender = PControl(_quitButton) then 
          sendMessage(C_MSG_CLOSE_SIGNAL, getDelegate)
        else if sender = PControl(_updateButton) then 
          updateModifiedSymbol
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
    _editGrid^.requestRedraw;
    ch := _symbolGrid^.getSelectedChar;
    if (ch >= C_MIN_PRINTABLE_CHAR) and (ch <= C_MAX_PRINTABLE_CHAR) then
      _indexLabel^.setText('#' + inttostr(ord(ch)) + '(' + ch + ')')
    else
      _indexLabel^.setText('#' + inttostr(ord(ch)));
    _indexLabel^.requestRedraw;
  end;

  procedure TMainForm.updateModifiedSymbol;
  begin
    _font^.setSymbol(_symbolGrid^.getSelectedChar, _editGrid^.getSymbol);
    _symbolGrid^.redrawCharCell(_symbolGrid^.getSelectedChar);
  end;

  procedure TMainForm.clearSymbols;
  begin
  end;

  procedure TMainForm.loadFont;
  begin
  end;

  procedure TMainForm.saveFont;
  begin
  end;

  procedure TMainForm.loadSystemFont;
  var 
    ch: char;
  begin
    for ch := #0 to #255 do 
      _font^.setSymbol(ch, SystemFont^.getSymbol(ch));
  end;

end.