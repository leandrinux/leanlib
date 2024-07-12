{
  lsystem runtime main unit
}
unit
  lsystem;

interface

  uses
    xcrt, ascii, consts, utils, uclasses, types, locale,
    uobject, uexc, ufstream,
    lcommon, lcpu, lram, lbus, ldecho, ltexts;

  const
    C_CLASS_ID_SYSTEM = 5000;
    C_DEFAULT_RAM = 1024;

  type
    PSystem = ^TSystem;
    TSystem = object (TObject)
    public
      constructor init;
      destructor done; virtual;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
      procedure loadBinaryFile(const filename: string);
      procedure run;
    private
      _cpu: PCPU;
      _bus: PBus;
      _ram: PRAM;
    end;

implementation

  { TSystem public }

  constructor TSystem.init;
  var
    echoDevice: PEchoDevice;
  begin
    inherited init;
    _cpu := new (PCPU, init);
    _bus := new (PBus, init);
    _ram := new(PRAM, initWithSize(C_DEFAULT_RAM));
    _cpu^.setBus(_bus);
    _bus^.addDevice(_ram);

    echoDevice := new(PEchoDevice, init);
    _bus^.addDevice(echoDevice);
    echoDevice^.release;
  end;

  destructor TSystem.done;
  begin
    _cpu^.release;
    _bus^.release;
    _ram^.release;
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

  procedure TSystem.loadBinaryFile(const filename: string);
  var
    fs: PFileStream;
    signature: TBinarySignature;
    readBytes: word;
  begin
    fs := new(PFileStream, initWithPath(filename, EFileReadOnly));
    
    if not fs^.isFileOpen then
      msg(EMsgFatal, C_STR_BINARY_NOT_FOUND, '');

    readBytes := fs^.read(@signature, sizeof(TBinarySignature));

    if readBytes<sizeof(TBinarySignature) then
      msg(EMsgFatal, C_STR_BINARY_INVALID, '');

    if compareBuffers(@signature, @C_BINARY_SIGNATURE, sizeof(TBinarySignature)) <> ECompareEqual then 
      msg(EMsgFatal, C_STR_BINARY_INVALID, '');
    
    _ram^.load(fs, 0);
    fs^.release;
  end;

  procedure TSystem.run;
  begin
    _cpu^.initialize;
    while (not keypressed) or (readkey<>C_ESC) do _cpu^.runOnce;
  end;

  { TSystem private }

  { Other }

end.
