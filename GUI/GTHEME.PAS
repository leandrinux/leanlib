{
  GTheme Unit
  2022 LRT
}
unit
  GTheme;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc,
    gclasses, gtypes;

  type
    PTheme = ^TTheme;
    TTheme = object (TObject)
    public
      { constructors and destructors}
      constructor init;
      destructor done; virtual;
      { extended methods }
      function getClassName: string; virtual;
      function getClassId: word; virtual;
      { methods }
      procedure draw(obj: PObject);
    private
    end;

implementation

  { TTheme public }

  constructor TTheme.init;
  begin
    inherited init;
  end;

  destructor TTheme.done;
  begin
    inherited done;
  end;

  function TTheme.getClassName: string;
  begin
    getClassName := 'TTheme';
  end;

  function TTheme.getClassId: word;
  begin
    getClassId := C_CLASS_ID_Theme;
  end;
  
  procedure TTheme.draw(obj: PObject);
  begin
    case obj^.getClassId of
      C_CLASS_ID_PANEL: exit;
    else
      raise(@self, 0, S_ERR_UNSUPPORTED_ACTION);
    end;
  end;

  { TTheme private }

  { Other }

end.
