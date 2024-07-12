{
  lsystem main bus unit
}
unit
  lbus;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc,
    lcommon, ldevice;

  const
    C_CLASS_ID_BUS = 5003;

  type
    PBus = ^TBus;
    TBus = object (TObject)
    public
      constructor init;
      destructor done; virtual;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
      procedure addDevice(device: PDevice);
    private
    end;

implementation

  { TBus public }

  constructor TBus.init;
  begin
    inherited init;
  end;

  destructor TBus.done;
  begin
    inherited done;
  end;

  function TBus.getClassName: string;
  begin
    getClassName := 'TBus';
  end;

  function TBus.getClassId: word;
  begin
    getClassId := C_CLASS_ID_BUS;
  end;

  procedure TBus.addDevice(device: PDevice);
  begin
  end;

  { TBus private }

  { Other }

end.
