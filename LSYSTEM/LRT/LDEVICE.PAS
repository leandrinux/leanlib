{
  lsystem base device unit
}
unit
  ldevice;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc,
    lcommon;

  const
    C_CLASS_ID_DEVICE = 5004;

    C_CMD_GET_DEVICE_TYPE = $00;

  type
    TDeviceName = string[20];
   
    PDevice = ^TDevice;
    TDevice = object (TObject)
    public
      constructor init;
      destructor done; virtual;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
      function command(cmd: byte; value: TUInt32): boolean; virtual;
      function read(buffer: pchar; count: word): word; virtual;
      function write(buffer: pchar; count: word): word; virtual;
      function readByte(var value: byte): boolean; virtual;
      function writeByte(value: byte): boolean; virtual;
      function getName: TDeviceName; virtual;
    private
    end;

implementation

  { TDevice public }

  constructor TDevice.init;
  begin
    inherited init;
  end;

  destructor TDevice.done;
  begin
    inherited done;
  end;

  function TDevice.getClassName: string;
  begin
    getClassName := 'TDevice';
  end;

  function TDevice.getClassId: word;
  begin
    getClassId := C_CLASS_ID_DEVICE;
  end;

  function TDevice.command(cmd: byte; value: TUInt32): boolean;
  begin
    command := false;
  end;

  function TDevice.read(buffer: pchar; count: word): word;
  begin
    read := 0;
  end;

  function TDevice.write(buffer: pchar; count: word): word;
  begin
    write := 0;
  end;

  function TDevice.readByte(var value: byte): boolean;
  begin
    value := 0;
    readByte := false;
  end;  

  function TDevice.writeByte(value: byte): boolean;
  begin
    writeByte := false;
  end;

  function TDevice.getName: TDeviceName;
  begin
    getName := 'Device';
  end;

  { TDevice private }

  { Other }

end.
