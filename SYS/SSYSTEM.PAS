{
  ssystem Unit
  Manages and runs apps and processes
  2022 LRT
}
unit
  ssystem;

interface

  uses
    consts, utils, uexc, types, locale,
    uclasses, uobject, ulist, umsgbus,
    sclasses, sapp, sprocess, smsgs, skeyb;

  type
    PSystem = ^TSystem;
    TSystem = object (TObject)
    public
      { constructors and destructors}
      constructor init;
      destructor done; virtual;
      { extended methods }
      function getClassName: string; virtual;
      function getClassId: word; virtual;
      procedure receiveMessage(msg: PObjectMessage); virtual;
      { methods }
      procedure runProcess(process: PProcess);
      procedure start;
      procedure stop;
    private
      _stopSignal: boolean;        { the system stop/shutdown signal }
      _bus: PMessageBus;           { system's message bus }
      _all, _new, _ready: PList;   { lists of processes in the system }
      procedure activateNewProcesses;
      procedure runReadyProcesses;
      procedure killAllProcesses;
    end;

  { Standalone convenience procs and functions }
  procedure runp(process: PProcess);

implementation

  { TSystem public }

  constructor TSystem.init;
  begin
    inherited init;
    _bus := new(PMessageBus, init);
    _all := new(PList, init);
    _new := new(PList, init);
    _ready := new(PList, init);
    _bus^.subscribe(@self);
  end;

  destructor TSystem.done;
  begin
    _bus^.unsubscribe(@self);
    _bus^.release;
    _all^.release;
    _new^.release;
    _ready^.release;
    inherited done;
  end;

  function TSystem.getClassName: string;
  begin
    getClassName := 'TSystem';
  end;

  function TSystem.getClassId: word;
  begin
    getClassId := C_CLASS_ID_System;
  end;

  procedure TSystem.receiveMessage(msg: PObjectMessage);
  begin
    case msg^.opcode of
      C_SYSCALL_SHUTDOWN_REQUEST: stop;
    end;
  end;

  procedure TSystem.runProcess(process: PProcess);
  begin
    process^.setState(EProcessStateNew);
    _all^.addObject(process);
    _new^.addObject(process);
  end;

  procedure TSystem.start;
  begin
    _stopSignal := false;
    while not _stopSignal do
    begin
      activateNewProcesses;
      runReadyProcesses;
    end;
    killAllProcesses;
  end;

  procedure TSystem.stop;
  begin
    _stopSignal := true;
  end;

  { TSystem private }

  procedure TSystem.activateNewProcesses;
  var 
    p: PProcess;
  begin
    p := PProcess(_new^.getFirst);
    while p <> nil do
    begin
      p^.setup;
      p^.setState(EProcessStateReady);
      p^.setSystemBus(_bus);
      _ready^.addObject(p);
      _new^.removeFirst;
      p := PProcess(_new^.getFirst);
    end;
  end;

  procedure TSystem.runReadyProcesses;
  var
    p: PProcess;
  begin
    _ready^.moveToStart;
    p := PProcess(_ready^.getObjectAtCursor);
    while p <> nil do
    begin
      p^.loop;
      _ready^.moveForward;
      p := PProcess(_ready^.getObjectAtCursor);
    end;
  end;

  procedure TSystem.killAllProcesses;
  var 
    p: PProcess;
  begin
    p := PProcess(_all^.getFirst);
    while p <> nil do
    begin
      p^.kill;
      p^.setState(EProcessStateKilled);
      p^.setSystemBus(nil);
      _all^.removeFirst;
      p := PProcess(_all^.getFirst);
    end;
  end;

  { Standalone convenience procs and functions }

  procedure runp(process: PProcess);
  var
    sys: PSystem;
    p: PProcess;
  begin
    sys := new(PSystem, init);
    sys^.runProcess(process);

    p := new(PKeyboardProc, init);
    sys^.runProcess(p);
    p^.release;

    sys^.start;
    sys^.release;
  end;

end.