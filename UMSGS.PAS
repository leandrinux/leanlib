{
  umsgs Unit
  Codes for messages sent between TObjects
  2022 LRT
}
unit
  umsgs;

interface

  const
    { standard notifications }
    C_MSG_EXCEPTION            = 1;
    C_MSG_STREAM_COPY_PROGRESS = 100;

    C_MSG_MOUSE_MOVEMENT       = 10;
    C_MSG_MOUSE_LEFT_UP        = 11;
    C_MSG_MOUSE_LEFT_DOWN      = 12;
    C_MSG_MOUSE_RIGHT_UP       = 13;
    C_MSG_MOUSE_RIGHT_DOWN     = 14;

    C_MSG_KEYBOARD_KEY_DOWN    = 20;

implementation

end.