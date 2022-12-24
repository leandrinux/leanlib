{
  UKeyBrd Unit
  2022 LRT
}
unit
  UKeyBrd;

interface

  uses
    xcrt, consts, utils, uclasses, types, locale,
    uobject, uexc, umsgs;

  type
    PKeyboard = ^TKeyboard;
    TKeyboard = object (TObject)
    public
      constructor init;
      destructor done; virtual;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
      function update: boolean;
      function getLastKeyDown: char;
    private
      _lastKeyDown: char;
    end;

  var
    Keyboard: PKeyboard;

implementation

  { TKeyboard public }

  constructor TKeyboard.init;
  begin
    inherited init;
  end;

  destructor TKeyboard.done;
  begin
    inherited done;
  end;

  function TKeyboard.getClassName: string;
  begin
    getClassName := 'TKeyboard';
  end;

  function TKeyboard.getClassId: word;
  begin
    getClassId := C_CLASS_ID_Keyboard;
  end;

  function TKeyboard.update: boolean;
  var
    delegate: PObject;
    key: char;
  begin
    update := false;
    delegate := getDelegate;
    if delegate = nil then exit;
    if keypressed then 
    begin
      key := readkey;
      _lastKeyDown := key;
      sendMessageWithData(C_MSG_KEYBOARD_KEY_DOWN, delegate, @key, 1);
      update := true;
    end; 
  end;

  function TKeyboard.getLastKeyDown: char;
  begin
    getLastKeyDown := _lastKeyDown;
  end;

  { TKeyboard private }

  { Other }

begin
  Keyboard := new(PKeyboard, init);
end.
