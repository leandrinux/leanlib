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
        procedure onEvent(opcode: word; sender: PControl); virtual;
        function createControl: PControl; virtual;
      private
        _loadButton: PButton;
        _saveButton: PButton;
        _nameField: PTextField;
        _quitButton: PButton;
        _editGrid: PEditGrid;
        _symbolGrid: PSymbolGrid;        
        _font: PTinyFont;
        procedure onSymbolChanged;
        procedure updateModifiedSymbol;
    end;

implementation

  const
    C_NAME_TEXTFIELD_PLACEHOLDER = 'Font name';
    C_LOAD_BUTTON_CAPTION = 'L';
    C_SAVE_BUTTON_CAPTION = 'S';
    C_TITLE_TEXT = 'TinyFont Editor';
    C_TITLE_HMARGIN = 40;
    C_QUIT_BUTTON_CAPTION = 'X';

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
    if (msg^.sender = PObject(_symbolGrid)) and (msg^.opcode = C_MSG_CHANGED_SELECTION) then onSymbolChanged;
  end;

  function TMainForm.createControl: PControl;
  var 
    panel: PPanel;
    lbl: PLabel;
  begin
    _font := new(PTinyFont, init);

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
      y := 24;
      width := 14;
    end;
    panel^.addControl(_loadButton);
    _loadButton^.release;

    { save button }
    _saveButton := new(PButton, init);
    with _saveButton^, getFrame^, point, size do
    begin
      setCaption(C_SAVE_BUTTON_CAPTION);
      x := 20;
      y := 24;
      width := 14;
    end;
    panel^.addControl(_saveButton);
    _saveButton^.release;

    { symbol edit grid }  
    _symbolGrid := new(PSymbolGrid, init);
    with _symbolGrid^, getFrame^, point do
    begin
      x := 95;
      y := 40;
    end;

    _symbolGrid^.setFont(_font);
    _symbolGrid^.setDelegate(@self);
    panel^.addControl(_symbolGrid);
    _symbolGrid^.release;

    { font name text field }
    _nameField := new(PTextField, init);
    with _nameField^, getFrame^, point, size do
    begin
      x := 95;
      y := 24; 
      width := _symbolGrid^.getFrame^.size.width;
      setPlaceholder(C_NAME_TEXTFIELD_PLACEHOLDER);
      setText(_font^.getName);
    end;
    panel^.addControl(_nameField);
    _nameField^.release;

    { edit grid }  
    _editGrid := new(PEditGrid, init);
    with _editGrid^, getFrame^, point do
    begin
      x := 5;
      y := 40;
    end;
    panel^.addControl(_editGrid);
    _editGrid^.release;

    createControl := panel;
  end;
  
  procedure TMainForm.onEvent(opcode: word; sender: PControl);
  begin
    case opcode of
        C_MSG_CONTROL_CLICKED:
        if sender = PControl(_quitButton) then 
          sendMessage(C_MSG_CLOSE_SIGNAL, getDelegate)
        else if sender = PControl(_saveButton) then 
          updateModifiedSymbol;
    end;
  end;

  { Private }

  procedure TMainForm.onSymbolChanged;
  begin
    _editGrid^.setSymbol(_symbolGrid^.getSelectedSymbol);
    _editGrid^.sendMessage(C_MSG_CONTROL_REQUEST_REDRAW, _editGrid^.getBus);
  end;

  procedure TMainForm.updateModifiedSymbol;
  begin
    _font^.setSymbol(_symbolGrid^.getSelectedChar, _editGrid^.getSymbol);
    _symbolGrid^.redrawCharCell(_symbolGrid^.getSelectedChar);
  end;

end.