{
  lsystem CPU unit
}
unit
  lcpu;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc;

  const
    C_CLASS_ID_CPU = 5001;

  type
    PCPU = ^TCPU;
    TCPU = object (TObject)
    public
      constructor init;
      destructor done; virtual;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
    private
    end;

implementation

  { TCPU public }

  constructor TCPU.init;
  begin
    inherited init;
  end;

  destructor TCPU.done;
  begin
    inherited done;
  end;

  function TCPU.getClassName: string;
  begin
    getClassName := 'TCPU';
  end;

  function TCPU.getClassId: word;
  begin
    getClassId := C_CLASS_ID_CPU;
  end;

  { TCPU private }

  { Other }

end.
