{
  usystem Unit
  Manages and runs apps and processes
  2022 LRT
}
unit
  usystem;

interface

  uses
    consts, utils, uexc, uclasses, types, locale, uobject,
    uapp, uprocess, umsgbus, usysmsgs, ulist;

  type
    PSystem = ^TSystem;
    TSystem = object (TObject)
    public
      constructor initWithApp(app: PApp);
      destructor done; virtual;
      procedure start;
      procedure stop;
      procedure receiveMessage(msg: PObjectMessage); virtual;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
    private
      _app: PApp;               { app being run }
      _stopSignal: boolean;     { the system stop/shutdown signal }
      _bus: PMessageBus;        { system's message bus }
      _processList: PList;      { list of processes in the system }
    end;

  procedure run(app: PApp);

implementation

  { TSystem public }

  constructor TSystem.initWithApp(app: PApp);
  begin
    inherited init;
    _app := app;
    _app^.retain;
    _bus := new(PMessageBus, init);
    _processList := new(PList, init);
  end;

  destructor TSystem.done;
  begin
    _processList^.release;
    _bus^.release;
    _app^.release;
    inherited done;
  end;

  procedure TSystem.start;
  var
    appInfo: PAppInfo;
    process: PProcess;
  begin
    { validate app and root process information }
    appInfo := _app^.getAppInfo;
    iassert(appInfo <> nil, @self, 0, S_ERR_APP_INFO_MISSING);
    process := _app^.getRootProcess;
    iassert(process <> nil, @self, 0, S_ERR_PROCESS_UNDEFINED);

    { add root process to process list }
    _processList^.addObject(process);

    { subscribe system to messages }
    _bus^.subscribe(@self);

    { start system main loop }
    _stopSignal := false;
    _processList^.moveToStart;
    while not _stopSignal do
    begin
      process := PProcess(_processList^.getObjectAtCursor);
      case process^.getState of

        ENew: begin
          _bus^.subscribe(process);
          process^.setSystemBus(_bus);
          process^.prepare;
        end;

        EReady: begin
          process^.work;
        end;

        { ESuspended: }

        EKilled: begin
          process^.setSystemBus(nil);
          _bus^.unsubscribe(process);
          _processList^.removeObject(process);
        end;
      end;

      _processList^.moveForward;
      if _processList^.getObjectAtCursor = nil then _processList^.moveToStart;
      _stopSignal := _stopSignal or (_processList^.getCount = 0);
    end;

    { clear list of processes}
    _processList^.clear;

    { unsubscribe myself from the bus to avoid retain cycle }
    _bus^.unsubscribe(@self);
  end;

  procedure TSystem.stop;
  begin
    _stopSignal := true;
  end;

  procedure TSystem.receiveMessage(msg: PObjectMessage);
  begin
    case msg^.opcode of
      C_SYSCALL_SHUTDOWN_REQUEST:
        stop;

      C_SYSCALL_ADD_PROCESS:
        _processList^.addObject(PProcess(msg^.payload));
    end;
  end;

  function TSystem.getClassName: string;
  begin
    getClassName := 'TSystem';
  end;

  function TSystem.getClassId: word;
  begin
    getClassId := C_CLASS_ID_System;
  end;

  { TSystem private }

  { Other }

  procedure run(app: PApp);
  var
    sys: PSystem;
  begin
    sys := new(PSystem, initWithApp(app));
    sys^.start;
    sys^.release;
  end;

end.