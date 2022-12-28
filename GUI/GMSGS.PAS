{
  gmsgs Unit
  Messages sent and received by user interface elements
}
unit
  gmsgs;

interface

  const
    C_MSG_CLOSE_SIGNAL           = $FB00; { indicates that the app needs to be closed }
    C_MSG_CONTROL_REQUEST_REDRAW = $FBF4; { sent by controls that need to be redrawn }
    C_MSG_CONTROL_FOCUS_CHANGED  = $FBF5; { sent by a control that has become the main focus }

    C_MSG_CONTROL_EVENT_MASK     = $FC00; { mask used to recognize valid control event codes }
    C_MSG_CONTROL_CLICKED        = $FC01; { when a control, such as a button, is clicked }

implementation

end.