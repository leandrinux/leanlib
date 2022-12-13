{
  gmsgs Unit
  Messages sent and received by user interface elements
}
unit
  gmsgs;

interface

  const
    C_MSG_CONTROL_REQUEST_REDRAW = $FBF4; { sent by controls that need to be redrawn }

    C_MSG_CONTROL_EVENT_MASK     = $FC00; { mask used to recognize valid control event codes }
    C_MSG_BUTTON_CLICK           = $FC01; { when a button is clicked }
    

implementation

end.