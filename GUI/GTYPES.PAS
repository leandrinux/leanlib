unit GTypes;

interface

  uses
    types;

  type
    EColorKey = (
      ECKPanelBorderTopLeft,
      ECKPanelBorderBottomRight,
      ECKPanelBackground
    );

    PColorScheme = ^TColorScheme;
    TColorScheme = array [EColorKey] of TColor;
    
implementation

end.