{
  lsystem RAM unit
}
unit
  lram;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc;

  const
    C_CLASS_ID_RAM = 5002;

  type
    PRAM = ^TRAM;
    TRAM = object (TObject)
    public
      constructor init;
      destructor done; virtual;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
    private
    end;

implementation

  { TRAM public }

  constructor TRAM.init;
  begin
    inherited init;
  end;

  destructor TRAM.done;
  begin
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

  { TRAM private }

  { Other }

end.
