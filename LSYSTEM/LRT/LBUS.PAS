{
  lsystem main bus unit
}
unit
  lbus;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc,
    lcommon, ldevice, ltexts;

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
      function sendByte(deviceId, data: byte): boolean;
      function receiveByte(deviceId: byte; var data: byte): boolean;
    private
      _devices: TDeviceBusArray;
      _count: byte;
    end;

implementation

  { TBus public }

  constructor TBus.init;
  begin
    inherited init;
    _count := 0;
  end;

  destructor TBus.done;
  begin
    while _count>0 do
    begin
      _devices[_count]^.release;
      dec(_count);
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
    msg(EMsgNormal, C_STR_ADDED_DEVICE, device^.getName + #0 + intToStr(_count));
    _devices[_count] := device;
    device^.retain;
    inc(_count);
  end;

  function TBus.sendByte(deviceId, data: byte): boolean;
  begin
    if deviceId < _count then
      sendByte := _devices[deviceId]^.writeByte(data)
    else 
      sendByte := false;
  end;

  function TBus.receiveByte(deviceId: byte; var data: byte): boolean;
  begin
    if deviceId < _count then
      receiveByte := _devices[deviceId]^.readByte(data)
    else
      receiveByte := false;
  end;

  { TBus private }

  { Other }

end.
