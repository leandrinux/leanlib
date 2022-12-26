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
      ECKTextDisabled,
      ECKTextCursor,
      ECKTextPlaceholder
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

    EAlignment = (
      EAlignNone,
      EAlignTopLeft,
      EAlignTop,
      EAlignTopRight,
      EAlignLeft,
      EAlignCenter,
      EAlignRight,
      EAlignBottomLeft,
      EAlignBottom,
      EAlignBottomRight
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