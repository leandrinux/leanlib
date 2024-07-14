{
  lsystem echo device unit
}
unit
  ldecho;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc,
    ldevice;

  const
    C_CLASS_ID_DEVICE_ECHO = 5005;

  type
    PEchoDevice = ^TEchoDevice;
    TEchoDevice = object (TDevice)
    public
      constructor init;
      destructor done; virtual;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
      procedure writeByte(value: byte); virtual;
    private
    end;

implementation

  { TEchoDevice public }

  constructor TEchoDevice.init;
  begin
    inherited init;
  end;

  destructor TEchoDevice.done;
  begin
    inherited done;
  end;

  function TEchoDevice.getClassName: string;
  begin
    getClassName := 'TEchoDevice';
  end;

  function TEchoDevice.getClassId: word;
  begin
    getClassId := C_CLASS_ID_DEVICE_ECHO;
  end;

  procedure TEchoDevice.writeByte(value: byte);
  begin
    system.write('#', value, ' ');
  end;

  { TEchoDevice private }

  { Other }

end.
