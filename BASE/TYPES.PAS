{
  Types Unit
  Common types used in multiple units, put here for convenience
  2022 LRT
}
unit
  types;

interface

  type

    { pascal strings of different sizes }
    { (note that each one's actual size is 1 byte bigger than it says) }
    string128 = string[128];
    string64 = string[64];
    string32 = string[32];
    string16 = string[16];
    string12 = string[12];
    string11 = string[11];
    string10 = string[10];
    string9 = string[9];
    string8 = string[8];
    string7 = string[7];
    string6 = string[6];
    string5 = string[5];
    string4 = string[4];
    string3 = string[3];
    string2 = string[2];
    TFilename = string[12];

    { aliases for numeric types }
    float = real;
    uint8 = byte;
    uint16 = word;
    uint32 = longint;
    int8 = shortint;
    int16 = integer;
    int32 = longint;
    long = longint;

    { pointers to common data types }
    pbyte = ^byte;
    pword = ^word;
    plong = ^long;
    pstr = ^string;

    { enumeration of the standard 16 colors }
    EColor = (
      EBlack,
      EBlue,
      EGreen,
      ECyan,
      ERed,
      EMagenta,
      EBrown,
      ELightGray,
      EDarkGray,
      ELightBlue,
      ELightGreen,
      ELightCyan,
      ELightRed,
      ELightMagenta,
      EYellow,
      EWhite
    );

    { communication ports }
    ESerialPort = (COM1, COM2, COM3, COM4);

    { colors are defined as 32-bit integers }
    TColor = longint;

    { a full path to a file, such as C:\WINDOWS\NOTEPAD.EXE or /dev/urandom }
    TFilePath = string;

    PRGBAColor = ^TRGBAColor;
    TRGBAColor = packed record a, b, g, r: byte; end;

    PRGBColor = ^TRGBColor;
    TRGBColor = packed record r, g, b: byte; end;

    PPoint = ^TPoint;
    TPoint = packed record x, y: integer; end;

    PSize = ^TSize;
    TSize = packed record width, height: word; end;

    PFrame = ^TFrame;
    TFrame = packed record
      point: TPoint;
      size: TSize;
    end;

    PVideoMode = ^TVideoMode;
    TVideoMode = packed record
      resX, resY: word;
      colorCount: longint;
    end;

    { comparisons }
    ECompareResult = (
      ECompareUndefined,
      ECompareGreater,
      ECompareLesser,
      ECompareEqual
    );

    TCompareFunc = function (a, b: pointer): ECompareResult;

    EFileOpenMode = (
      EFileReadOnly,
      EFileReadWrite,
      EFileCreate
    );

implementation

end.