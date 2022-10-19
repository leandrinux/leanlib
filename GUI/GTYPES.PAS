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
    
    PControlId = ^TControlId;
    TControlId = string[8];

    EBorderStyle = (
      EBorderStyleNone,
      EBorderStyleRaised,
      EBorderStyleLowered
    );

implementation

end.