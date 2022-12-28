{
  GColors Unit
  2022 LRT
}
unit
  GColors;

interface

  uses
    consts, utils, uclasses, types, locale, palette,
    uobject, uexc, udisplay,
    gclasses, gtypes;

  type
    PColorArray = ^TColorArray;
    TColorArray = array [EColorKey] of TColor;

    PColorScheme = ^TColorScheme;
    TColorScheme = object (TObject)
    public
      { constructors and destructors}
      constructor init;
      destructor done; virtual;
      { extended methods }
      function getClassName: string; virtual;
      function getClassId: word; virtual;
      { methods }
      function getColor(key: EColorKey): TColor;
    private
      _colorArray: TColorArray;
    end;

  function DefaultColorScheme: PColorScheme;

implementation

  var
    ColorScheme: PColorScheme;

  { TColorScheme public }

  constructor TColorScheme.init;
  begin
    inherited init;
    _ColorArray[ECKPanelBorderRaised] := ord(EWhite);
    _ColorArray[ECKPanelBorderLowered] := ord(EDarkgray);
    _ColorArray[ECKPanelBackground] := ord(ELightgray);
    _ColorArray[ECKCheckboxSymbol] := ord(EBlue);
    _ColorArray[ECKLabelText] := ord(EBlack);
    _ColorArray[ECKButtonText] := ord(EBlack);
    _ColorArray[ECKControlFocus] := ord(EBlue);
    _ColorArray[ECKTextCursor] := ord(EBlue);
    _ColorArray[ECKTextDisabled] := ord(EDarkgray);
    _ColorArray[ECKTextPlaceholder] := ord(EDarkgray);
  end;

  destructor TColorScheme.done;
  begin
    inherited done;
  end;

  function TColorScheme.getClassName: string;
  begin
    getClassName := 'TColorScheme';
  end;

  function TColorScheme.getClassId: word;
  begin
    getClassId := C_CLASS_ID_ColorScheme;
  end;

  function TColorScheme.getColor(key: EColorKey): TColor;
  begin
    getColor := _ColorArray[key];
  end;

  { TColorScheme private }

  { Other }

  function DefaultColorScheme: PColorScheme;
  begin
    if ColorScheme = nil then ColorScheme := new(PColorScheme, init);
    DefaultColorScheme := ColorScheme;
  end;

begin
  ColorScheme := nil;
end.
