{
  uprocess Unit

  2022 LRT
}
unit
  uprocess;

interface

  uses
    consts, utils, uexc, uclasses, usclass, types, locale, uobject, umsgbus,
    usysmsgs;

  type
    EProcessState = (
      ENew,
      EReady,
      ESuspended,
      EKilled
    );

    PProcess = ^TProcess;
    TProcess = object (TObject)
    public
      constructor init;
      destructor done; virtual;
      procedure prepare; virtual; { when it's new and must become ready }
      procedure work; virtual;    { when it's ready in main loop }
      procedure kill; virtual;    { when it must be terminated }
      procedure suspend; virtual; { when it must wait for something }
      procedure wake; virtual;    { when it must become ready again }
      procedure syscall(opcode: word; args: pointer);
      procedure setSystemBus(bus: PMessageBus);
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
    _state := ENew;
    _bus := nil;
  end;

  destructor TProcess.done;
  begin
    inherited done;
  end;

  procedure TProcess.prepare;
  begin
    _state := EReady;
  end;

  procedure TProcess.work;
  begin
  end;

  procedure TProcess.kill;
  begin
    _state := EKilled;
  end;

  procedure TProcess.suspend;
  begin
    _state := ESuspended;
  end;

  procedure TProcess.wake;
  begin
    _state := EReady;
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