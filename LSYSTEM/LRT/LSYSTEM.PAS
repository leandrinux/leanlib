{
  lsystem runtime main unit
}
unit
  lsystem;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc,
    lcpu, lram, lbus;

  const
    C_CLASS_ID_SYSTEM = 5000;

  type
    PSystem = ^TSystem;
    TSystem = object (TObject)
    public
      constructor init;
      destructor done; virtual;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
    private
      _cpu: PCPU;
      _ram: PRAM;
      _bus: PBus;
    end;

implementation

  { TSystem public }

  constructor TSystem.init;
  begin
    inherited init;
    _cpu := new (PCPU, init);
    _ram := new (PRAM, init);
    _bus := new (PBus, init);
  end;

  destructor TSystem.done;
  begin
    _bus^.release;
    _ram^.release;
    _cpu^.release;
    inherited done;
  end;

  function TSystem.getClassName: string;
  begin
    getClassName := 'TSystem';
  end;

  function TSystem.getClassId: word;
  begin
    getClassId := C_CLASS_ID_SYSTEM;
  end;

  { TSystem private }

  { Other }

end.
