unit GTypes;

interface

  uses
    types;

  type
    EColorKey = (
      ECKPanelBorderTopLeft,
      ECKPanelBorderBottomRight,
      ECKPanelBackground,
      ECKLabelText
    );
    
    PControlId = ^TControlId;
    TControlId = string[8];

    EBorderStyle = (
      EBorderStyleNone,
      EBorderStyleRaised,
      EBorderStyleLowered
    );

    EBackgroundStyle = (
      EBackgroundStyleSolid,
      EBackgroundStyleTransparent
    );

    ETextAlign = (
      ETextAlignTopLeft,
      ETextAlignTop,
      ETextAlignTopRight,
      ETextAlignLeft,
      ETextAlignCenter,
      ETextAlignRight,
      ETextAlignBottomLeft,
      ETextAlignBottom,
      ETextAlignBottomRight
    );
    
implementation

end.