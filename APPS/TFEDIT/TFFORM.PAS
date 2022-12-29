unit TFForm;
    
interface

  uses
    ascii, types, utils,
    uobject, uclasses, uexc, udisplay, usysfont,
    gui, gtypes, gmsgs, gform, gcontrol, gpanel, glabel, gbutton,
    tfegrid, tfcgrid;

  type
    PMainForm = ^TMainForm;
    TMainForm = object (TForm)
      public
        constructor init;
        procedure onEvent(opcode: word; sender: PControl); virtual;
        function createControl: PControl; virtual;
      private
        _quitButton: PButton;
        _editGrid: PEditGrid;
        _symbolGrid: PSymbolGrid;
    end;

implementation

  const
    C_TITLE_TEXT = 'TinyForm Editor';
    C_TITLE_HMARGIN = 40;
    C_QUIT_BUTTON_CAPTION = 'X';

  { Public }

  constructor TMainForm.init;
  begin
    inherited init;
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
      width := 256;
      height := 180;
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
      y := 24;
    end;
    _symbolGrid^.setFontData(@C_SYSTEM_FONT_DATA);
    panel^.addControl(_symbolGrid);

    { edit grid }  
    _editGrid := new(PEditGrid, init);
    with _editGrid^, getFrame^, point do
    begin
      x := 160;
      y := 24;
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

end.