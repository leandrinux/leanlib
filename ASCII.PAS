{
  ASCII Unit
  Constants for various ASCII characters and keyboard scan codes
  2022 LRT
}
unit
  ascii;

interface

  const
    C_NULL      = #0;
    C_BACKSPACE = #8;
    C_TAB       = #9;
    C_LF        = #10;
    C_CR        = #13;
    C_ESC       = #27;
    C_LEFT      = #37;
    C_RIGHT     = #39;
    
    C_SPACE     = ' ';
    C_COMMA     = ',';
    C_HASH      = '#';
    C_QUOTE     = '''';

    { function keys are preceded by 0 }
    C_BREAK     = #$03;
    C_F1        = #$3B;
    C_F2        = #$3C;
    C_F3        = #$3D;
    C_F4        = #$3E;
    C_F5        = #$3F;
    C_F6        = #$40;
    C_F7        = #$41;
    C_F8        = #$42;
    C_F9        = #$43;
    C_F10       = #$44;
    C_INSERT    = #$52;
    C_DELETE    = #$53;
    C_HOME      = #$47;
    C_END       = #$4F;
    C_PGUP      = #$49;
    C_PGDOWN    = #$51;

    { special BIOS keys }
    C_INS       = #$80;
    C_CAPSLOCK  = #$40;
    C_NUMLOCK   = #$20;
    C_SCRLOCK   = #$10;
    C_ALT       = #$8;
    C_CTRL      = #$4;
    C_LSHIFT    = #$2;
    C_RSHIFT    = #$1;

    { delimiters }
    C_PRINTABLE_FROM = #32;
    C_PRINTABLE_TO = #126;

    { special symbols }
    C_CHR_FACE_HAPPY  = #0;
    C_CHR_FACE_SAD    = #1;
    C_CHR_FACE        = #2;
    C_CHR_EXCLAMATION = #3;
    C_CHR_CLOSE       = #4;
    C_CHR_TICK        = #5;
    C_CHR_ARROW_RIGHT = #6;
    C_CHR_ARROW_LEFT  = #7;
    C_CHR_ARROW_UP    = #8;
    C_CHR_ARROW_DOWN  = #9;

implementation

end.