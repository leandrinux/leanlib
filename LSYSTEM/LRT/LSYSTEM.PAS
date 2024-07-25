{
  lsystem runtime main unit
}
unit
  lsystem;

interface

  uses
    xcrt, ascii, consts, utils, uclasses, types, locale,
    uobject, uexc, ufstream,
    lcommon, lcpu, lram, lbus, ldecho, ltexts,
    op_base;

  const
    C_CLASS_ID_SYSTEM = 5000;
  
    C_DEFAULT_RAM = 4096;
    C_DEFAULT_STACK = 128;  

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
      _codeSize : TUInt32;
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
    _cpu^.setBus(_bus);

    _ram := new(PRAM, initWithSize(C_DEFAULT_RAM));
    msg(EMsgNormal, C_STR_INIT_MEMORY_WITH_SIZE, intToStr(C_DEFAULT_RAM));
    _bus^.addDevice(_ram); { RAM is device #0 }

    echoDevice := new(PEchoDevice, init);
    _bus^.addDevice(echoDevice);
    echoDevice^.release;  { echo device is device #1 }
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
    
    _codeSize := fs^.getSize - sizeof(TBinarySignature);
    _ram^.loadStream(fs, _codeSize, 0);
    fs^.release;
  end;

  procedure TSystem.run;
  var
    context: TContext;
  begin
    _cpu^.initialize;
    with context do
    begin
      regs := @(_cpu^.regs);
      ram := _ram;
      bus := _bus;
      regs^.DS := _codeSize;
      regs^.SS := C_DEFAULT_RAM - C_DEFAULT_STACK;
      stackSize := C_DEFAULT_STACK;

      while regs^.IP < _codeSize do
      begin
        _ram^.readFromMemory(@instruction, regs^.IP, sizeof(TInstruction));
        _cpu^.exec(context);
      end;
    end;
  end;

  { TSystem private }

  { Other }

end.
