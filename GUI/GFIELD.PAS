{
  GField Unit
  2022 LRT
}
unit
  GField;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc,
    gclasses, gtypes, gcontrol;

  type
    PTextField = ^TTextField;
    TTextField = object (TControl)
    public
      { constructors and destructors}
      constructor init;
      destructor done; virtual;
      { extended methods }
      function getClassName: string; virtual;
      function getClassId: word; virtual;
      { methods }
    private
    end;

implementation

  { TTextField public }

  constructor TTextField.init;
  begin
    inherited init;
  end;

  destructor TTextField.done;
  begin
    inherited done;
  end;

  function TTextField.getClassName: string;
  begin
    getClassName := 'TTextField';
  end;

  function TTextField.getClassId: word;
  begin
    getClassId := C_CLASS_ID_TextField;
  end;

  { TTextField private }

  { Other }

end.
