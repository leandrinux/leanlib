unit GTypes;

interface

  uses
    types;

  type
    EColorKey = (
      ECKPanelBorderRaised,
      ECKPanelBorderLowered,
      ECKPanelBackground,
      ECKCheckboxSymbol,
      ECKLabelText,
      ECKButtonText,
      ECKControlFocus,
      ECKTextCursor
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