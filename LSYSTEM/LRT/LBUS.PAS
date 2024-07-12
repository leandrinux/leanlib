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
    C_DEVICE_BUS_SIZE = 5;

  type
    TDeviceBusArray = array[0..C_DEVICE_BUS_SIZE-1] of PDevice;
   
    PBus = ^TBus;
    TBus = object (TObject)
    public
      constructor init;
      destructor done; virtual;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
      procedure addDevice(device: PDevice);
    private
      devices: TDeviceBusArray;
      count: byte;
    end;

implementation

  { TBus public }

  constructor TBus.init;
  begin
    inherited init;
    count := 0;
  end;

  destructor TBus.done;
  begin
    while count>0 do
    begin
      devices[count]^.release;
      dec(count);
    end;
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
    devices[count] := device;
    device^.retain;
  end;

  { TBus private }

  { Other }

end.
