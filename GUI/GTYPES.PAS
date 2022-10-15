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
    
    PControlId = ^TControlId;
    TControlId = string[8];

implementation

end.