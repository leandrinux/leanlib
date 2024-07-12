{
  lsystem base device unit
}
unit
  ldevice;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc;

  const
    C_CLASS_ID_DEVICE = 5004;

  type
    PDevice = ^TDevice;
    TDevice = object (TObject)
    public
      constructor init;
      destructor done; virtual;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
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

  { TDevice private }

  { Other }

end.
