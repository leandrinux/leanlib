unit GTypes;

interface

  uses
    types;

  type
    EColorKey = (
      ECKPanelBorderTopLeft,
      ECKPanelBorderBottomRight,
      ECKPanelBackground,
      ECKLabelText,
      ECKButtonText
    );
    
    PControlId = ^TControlId;
    TControlId = string16;

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

    EMouseEvent = (
      EMouseEventNone,
      EMouseEventLeftDown,
      EMouseEventLeftUp,
      EMouseEventRightDown,
      EMouseEventRightUp
    );

    PMouseActivity = ^TMouseActivity;
    TMouseActivity = packed record
      event: EMouseEvent;
      position: TPoint;
    end;
    
implementation

end.