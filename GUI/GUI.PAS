{
  GUI Unit

  2022 LRT
}
unit
  GUI;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc,
    gclasses, gtypes, gtheme;

  type
    PGUI = ^TGUI;
    TGUI = object (TObject)
    public
      { constructors and destructors}
      constructor init;
      destructor done; virtual;
      { extended methods }
      function getClassName: string; virtual;
      function getClassId: word; virtual;
      { methods }
    private
      _theme: PTheme;
    end;

implementation

  { TGUI public }
  constructor TGUI.init;
  begin
    inherited init;
    _theme := new(PTheme, init);
  end;

  destructor TGUI.done;
  begin
    _theme^.release;
    inherited done;
  end;

  function TGUI.getClassName: string;
  begin
    getClassName := 'TGUI';
  end;

  function TGUI.getClassId: word;
  begin
    getClassId := C_CLASS_ID_GUI;
  end;

  { TGUI private }

  { Other }

end.
