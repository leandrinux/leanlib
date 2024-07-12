{
  lsystem CPU unit
}
unit
  lcpu;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc,
    lcommon, lbus;

  const
    C_CLASS_ID_CPU = 5001;

  type
    PCPU = ^TCPU;
    TCPU = object (TObject)
    public
      constructor init;
      destructor done; virtual;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
      procedure setBus(bus: PBus);
    private
      _bus: PBus;
    end;

implementation

  { TCPU public }

  constructor TCPU.init;
  begin
    inherited init;
    _bus := nil;
  end;

  destructor TCPU.done;
  begin
    if _bus <> nil then _bus^.release;
    inherited done;
  end;

  function TCPU.getClassName: string;
  begin
    getClassName := 'TCPU';
  end;

  function TCPU.getClassId: word;
  begin
    getClassId := C_CLASS_ID_CPU;
  end;

  procedure TCPU.setBus(bus: PBus);
  begin
    if _bus <> nil then _bus^.release;
    _bus := bus;
    bus^.retain;    
  end;
  { TCPU private }

  { Other }

end.
