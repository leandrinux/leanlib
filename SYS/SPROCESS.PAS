{
  sprocess Unit
  2022 LRT
}
unit
  sprocess;

interface

  uses
    consts, utils, types, locale, 
    uexc, uclasses, uobject, umsgbus,
    sclasses, smsgs;

  type
    EProcessState = (
      EProcessStateNew,
      EProcessStateReady,
      EProcessStateSuspended,
      EProcessStateKilled
    );

    PProcess = ^TProcess;
    TProcess = object (TObject)
    public
      constructor init;
      destructor done; virtual;
      procedure setup; virtual; 
      procedure loop; virtual;
      procedure kill; virtual;
      procedure syscall(opcode: word; args: pointer);
      procedure setSystemBus(bus: PMessageBus);
      procedure setState(state: EProcessState);
      function getState: EProcessState;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
    private
      _state: EProcessState;
      _bus: PMessageBus;
    end;

implementation

  { TProcess public }

  constructor TProcess.init;
  begin
    inherited init;
    _state := EProcessStateNew;
    _bus := nil;
  end;

  destructor TProcess.done;
  begin
    inherited done;
  end;

  procedure TProcess.setup;
  begin
  end;

  procedure TProcess.loop;
  begin
  end;

  procedure TProcess.kill;
  begin
  end;
  
  procedure TProcess.syscall(opcode: word; args: pointer);
  var
    msg: TObjectMessage;
  begin
    if _bus = nil then exit;
    msg.opcode := opcode;
    msg.sender := @self;
    msg.target := nil;
    msg.payload := args;
    msg.size := 0;
    _bus^.broadcast(@msg);
  end;

  procedure TProcess.setSystemBus(bus: PMessageBus);
  begin
    _bus := bus;
  end;

  procedure TProcess.setState(state: EProcessState);
  begin
    _state := state;
  end;

  function TProcess.getState: EProcessState;
  begin
    getState := _state;
  end;

  function TProcess.getClassName: string;
  begin
    getClassName := 'TProcess';
  end;

  function TProcess.getClassId: word;
  begin
    getClassId := C_CLASS_ID_Process;
  end;

  { TProcess private }

  { Other }

end.