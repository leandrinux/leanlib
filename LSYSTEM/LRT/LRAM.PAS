{
  lsystem RAM unit
}
unit
  lram;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc, ustream,
    lcommon, ldevice;

  const
    C_CLASS_ID_RAM = 5002;

  type
    PRAM = ^TRAM;
    TRAM = object (TDevice)
    public
      constructor initWithSize(size: TUInt32);
      destructor done; virtual;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
      procedure load(stream: PStream; position: TUInt32);
    private
      _data: pchar;
      _size: word;
    end;

implementation

  { TRAM public }

  constructor TRAM.initWithSize(size: TUInt32);
  begin
    inherited init;
    getMem(_data, size);
    _size := size;
  end;

  destructor TRAM.done;
  begin
    freeMem(_data, _size);
    inherited done;
  end;

  function TRAM.getClassName: string;
  begin
    getClassName := 'TRAM';
  end;

  function TRAM.getClassId: word;
  begin
    getClassId := C_CLASS_ID_RAM;
  end;

  procedure TRAM.load(stream: PStream; position: TUInt32);
  var
    p: pchar;
    size: TUInt32;
  begin
    p := _data;
    inc(p, position);
    size := stream^.getSize;
    stream^.read(p, size);
  end;

  { TRAM private }

  { Other }

end.
