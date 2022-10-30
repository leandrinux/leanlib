{
  SKeyb Unit
  2022 LRT
}
unit
  SKeyb;

interface

  uses
    xcrt, ascii, consts, utils, uclasses, types, locale,
    uobject, uexc,
    sclasses, smsgs, sprocess;

  type
    PKeyboardProc = ^TKeyboardProc;
    TKeyboardProc = object (TProcess)
    public
      { constructors and destructors }
      constructor init;
      destructor done; virtual;
      { extended methods }
      function getClassName: string; virtual;
      function getClassId: word; virtual;
      procedure setup; virtual;
      procedure loop; virtual;
      { methods }
    private
    end;

implementation

  { TKeyboardProc public }

  constructor TKeyboardProc.init;
  begin
    inherited init;
  end;

  destructor TKeyboardProc.done;
  begin
    inherited done;
  end;

  function TKeyboardProc.getClassName: string;
  begin
    getClassName := 'TKeyboardProc';
  end;

  function TKeyboardProc.getClassId: word;
  begin
    getClassId := C_CLASS_ID_KeyboardProc;
  end;

  procedure TKeyboardProc.setup; 
  begin
  end;

  procedure TKeyboardProc.loop;
  var
    key: char;
  begin
    if keypressed then key := readkey;
    if key = C_ESC then syscall(C_SYSCALL_SHUTDOWN_REQUEST, nil);
  end;

  { TKeyboardProc private }

  { Other }

end.
