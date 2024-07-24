{
  lsystem CPU unit
}
unit
  lcpu;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc,
    lcommon, lbus, op_base, op_full;

  const
    C_CLASS_ID_CPU = 5001;

  type
    PCPU = ^TCPU;
    TCPU = object (TObject)
    public
      regs: TRegisters;
      constructor init;
      destructor done; virtual;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
      procedure setBus(bus: PBus);
      procedure initialize;
      procedure exec(var context: TContext);
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

  procedure TCPU.initialize;
  begin
    fillchar(regs, sizeof(TRegisters), 0);
  end;

  procedure TCPU.exec(var context: TContext);
  begin
    op_full.exec(context);
  end;

  { TCPU private }

  { Other }

end.
