{
  uclasses Unit
  Class IDs for objects extending TObject
  2022 LRT
}
unit
  uclasses;

interface

  const

    { foundation }
    C_CLASS_ID_OBJECT         = 0;
    C_CLASS_ID_EXCEPTION      = 1;
    C_CLASS_ID_MESSAGEBUS     = 2;

    { logging & debugging }
    C_CLASS_ID_LOG             = 50;
    C_CLASS_ID_SERIALEXHANDLER = 60;

    { streams }
    C_CLASS_ID_STREAM         = 100;
    C_CLASS_ID_FILESTREAM     = 101;
    C_CLASS_ID_MEMORYSTREAM   = 102;
    C_CLASS_ID_XORSTREAM      = 103;
    C_CLASS_ID_EMSSTREAM      = 104;
    C_CLASS_ID_SUBSTREAM      = 105;
    C_CLASS_ID_PACKAGE        = 106;
    C_CLASS_ID_STDOUTPUT      = 107;
    C_CLASS_ID_SERIAL         = 108;
    C_CLASS_ID_ANSIWRITER     = 109;
    C_CLASS_ID_CACHEDSTREAM   = 110;

    { graphics }
    C_CLASS_ID_BITMAP         = 200;
    C_CLASS_ID_SUBBITMAP      = 201;
    C_CLASS_ID_CANVAS         = 202;
    C_CLASS_ID_COLORPALETTE   = 203;
    C_CLASS_ID_TURTLE         = 204;
    C_CLASS_ID_BITMAPLAYER    = 210;
    C_CLASS_ID_BITMAPSTACK    = 211;
    C_CLASS_ID_MASKBITMAP     = 212;
    C_CLASS_ID_BITMAP1        = 220;
    C_CLASS_ID_BITMAP8        = 221;
    C_CLASS_ID_VGAMODE13BITMAP= 222;

    { devices }
    C_CLASS_ID_DISPLAYADAPTER = 300;
    C_CLASS_ID_SPEAKER        = 301;
    C_CLASS_ID_MOUSE          = 302;
    C_CLASS_ID_KEYBOARD       = 303;
    C_CLASS_ID_VIDEODRIVER    = 310;
    C_CLASS_ID_VGADRIVER      = 311;

    { standard library objects }
    C_CLASS_ID_STRING         = 400;
    C_CLASS_ID_NUMBER         = 401;
    C_CLASS_ID_LIST           = 402;
    C_CLASS_ID_DICTIONARY     = 403;
    C_CLASS_ID_PATH           = 404;

    { parsing file formats }
    C_CLASS_ID_INIFILE        = 500;
    C_CLASS_ID_JSONREADER     = 501;

    { bitmap font }
    C_CLASS_ID_FONT           = 601;
    C_CLASS_ID_TINYFONT       = 602;
    C_CLASS_ID_SYSTEMFONT     = 603;
    C_CLASS_ID_TEXTRENDERER   = 604;

    { file formats }
    C_CLASS_ID_BMPFILE        = 700;

implementation

end.