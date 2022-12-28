unit TFForm;
    
interface

  uses
    ascii, types, utils,
    uobject, uclasses, uexc, udisplay,
    gui, gtypes, gmsgs, gform, gcontrol, gpanel, glabel, gbutton,
    tfgrid;

  type
    PMainForm = ^TMainForm;
    TMainForm = object (TForm)
      public
        constructor init;
        procedure onStart; virtual;
        procedure onEvent(opcode: word; sender: PControl); virtual;
        function createControl: PControl; virtual;
      private
        _quitButton: PButton;
        _grid: PGrid;
    end;

implementation

  const
    C_TITLE_TEXT = 'TinyForm Editor';
    C_TITLE_HMARGIN = 40;
    C_TITLE_VMARGIN = 6;
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
      width := 250;
      height := 150;
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
      inc(height, C_TITLE_VMARGIN);
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

    { grid }  
    _grid := new(PGrid, init);
    _grid^.setAlignment(EAlignCenter);
    panel^.addControl(_grid);

    createControl := panel;
  end;
  
  procedure TMainForm.onStart;
  begin
  end;

  procedure TMainForm.onEvent(opcode: word; sender: PControl);
  begin
    case opcode of
        C_MSG_CONTROL_CLICKED:
        if sender = PControl(_quitButton) then 
            sendMessage(C_MSG_CLOSE_SIGNAL, getDelegate)
    end;
  end;
{  
        else if (sender^.getId = 'grid') then 
            clickGrid; 

        C_MSG_CONTROL_CUSTOM_DRAW:
        if (sender^.getId = 'grid') then
        begin
            drawGrid;
            drawGlyph;
        end;
    end;
}

  { Private }

end.