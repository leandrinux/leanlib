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
        procedure receiveMessage(msg: PObjectMessage); virtual;
        procedure onEvent(opcode: word; sender: PControl); virtual;
        function createControl: PControl; virtual;
      private
        _name: PTextField;
        _quitButton: PButton;
        _editGrid: PEditGrid;
        _symbolGrid: PSymbolGrid;
        procedure onSymbolChanged;
    end;

implementation

  const
    C_NAME_TEXTFIELD_PLACEHOLDER = 'Font name';
    C_TITLE_TEXT = 'TinyFont Editor';
    C_TITLE_HMARGIN = 40;
    C_QUIT_BUTTON_CAPTION = 'X';

  { Public }

  constructor TMainForm.init;
  begin
    inherited init;
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
    { container panel }
    panel := new(PPanel, init);
    with panel^.getFrame^, size do
    begin
      width := 300;
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

    { quit button } 
    _quitButton := new(PButton, init);
    with _quitButton^ do
    begin
      setCaption(C_QUIT_BUTTON_CAPTION);
      setAlignment(EAlignTopRight);
      adjustSizeToText;
    end;
    panel^.addControl(_quitButton);

    { symbol edit grid }  
    _symbolGrid := new(PSymbolGrid, init);
    with _symbolGrid^, getFrame^, point do
    begin
      x := 10;
      y := 40;
    end;
    _symbolGrid^.setFontData(@C_SYSTEM_FONT_DATA);
    _symbolGrid^.setDelegate(@self);
    panel^.addControl(_symbolGrid);

    { font name text field }
    _name := new(PTextField, init);
    with _name^, getFrame^, point, size do
    begin
      x := 10;
      y := 24; 
      width := _symbolGrid^.getFrame^.size.width;
      setPlaceholder(C_NAME_TEXTFIELD_PLACEHOLDER);
      setText(_symbolGrid^.getFont^.getName);
    end;
    panel^.addControl(_name);

    { edit grid }  
    _editGrid := new(PEditGrid, init);
    with _editGrid^, getFrame^, point do
    begin
      x := 160;
      y := 40;
    end;
    panel^.addControl(_editGrid);

    createControl := panel;
  end;
  
  procedure TMainForm.onEvent(opcode: word; sender: PControl);
  begin
    case opcode of
        C_MSG_CONTROL_CLICKED:
        if sender = PControl(_quitButton) then 
            sendMessage(C_MSG_CLOSE_SIGNAL, getDelegate)
    end;
  end;

  { Private }

  procedure TMainForm.onSymbolChanged;
  begin
    _editGrid^.setSymbol(_symbolGrid^.getSelectedSymbol);
    _editGrid^.sendMessage(C_MSG_CONTROL_REQUEST_REDRAW, _editGrid^.getBus);
  end;

end.