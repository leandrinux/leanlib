{
  UVGADrv Unit
  VGA graphics adapter driver
  2022 LRT
}
unit
  uvgadrv;

interface

  uses
    uexc, uclasses, types, locale, uobject, uviddrv, int10, math,
    ubitmap, ubitmap8, upalette, ulog;

  type
    PVGADriver = ^TVGADriver;
    TVGADriver = object (TVideoDriver)
    public
      constructor init;
      destructor done; virtual;
      function isAvailable: boolean; virtual;
      function supportsPalette: boolean; virtual;
      function getCurrentVideoMode: PVideoMode; virtual;
      function getBitmap: PBitmap; virtual;
      procedure getVideoModes(var list:PVideoMode; var count: word); virtual;
      procedure setVideoMode(index: word); virtual;
      procedure setTextMode; virtual;
      procedure setPalette(palette: PColorPalette); virtual;
      function getDriverName: string; virtual;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
    private
      _currentVideoMode: PVideoMode;
      _bitmap: PBitmap;
    end;

    { this represents the VGA video memory for mode 13th as a bitmap }
    PVGAMode13Bitmap = ^TVGAMode13Bitmap;
    TVGAMode13Bitmap = object (TBitmap)
    public
      constructor init;
      destructor done; virtual;
      procedure setPixel(x, y: word; color: TColor); virtual;
      procedure setPixelBlock(x1, y1, x2, y2: word; color: TColor); virtual;
      procedure merge(src: PBitmap; x, y: word); virtual;
      function getPixel(x, y: word): TColor; virtual;
      procedure clear(color: TColor); virtual;
      function getColorCount: longint; virtual;
      function getBitsPerPixel: byte; virtual;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
    end;

implementation

  const
    C_VGA_VIDEO_MODES_COUNT = 1;
    C_VGA_VIDEO_MODES: array[0..C_VGA_VIDEO_MODES_COUNT-1] of TVideoMode = (
      (resX: 320; resY: 200; colorCount: 256)
    );

  { TVGADriver }

  constructor TVGADriver.init;
  begin
    inherited init;
    _currentVideoMode := nil;
    _bitmap := nil;
  end;

  destructor TVGADriver.done;
  begin
    if _bitmap <> nil then _bitmap^.release;
    inherited done;
  end;

  function TVGADriver.isAvailable: boolean;
  var
    a, i: byte;
    res : boolean;
  begin
    res := int10.getVideoDisplayCombination(a, i);
    isAvailable := res and (a >= C_DISPLAY_CODE_VGA_MONO);
  end;

  function TVGADriver.supportsPalette: boolean;
  begin
    supportsPalette := true;
  end;

  function TVGADriver.getCurrentVideoMode: PVideoMode;
  begin
    getCurrentVideoMode := _currentVideoMode;
  end;

  function TVGADriver.getBitmap: PBitmap;
  begin
    getBitmap := _bitmap;
  end;

  procedure TVGADriver.getVideoModes(var list:PVideoMode; var count: word);
  begin
    list := @C_VGA_VIDEO_MODES;
    count := C_VGA_VIDEO_MODES_COUNT;
  end;

  procedure TVGADriver.setVideoMode(index: word);
  const
    C_VGA_MODES: array[0..C_VGA_VIDEO_MODES_COUNT-1] of byte = ( $13 );
  begin
    int10.setVideoMode(C_VGA_MODES[index]);
    _currentVideoMode := @C_VGA_VIDEO_MODES;
    inc(_currentVideoMode, index);
    if _bitmap <> nil then _bitmap^.release;
    case index of
      0: _bitmap := new(PVGAMode13Bitmap, init);
    else
      iassert(false, @self, 0, S_ERR_UNSUPPORTED_ACTION);
    end;
  end;

  procedure TVGADriver.setTextMode;
  begin
    int10.setVideoMode(C_VIDMODE_CGA_T_80x25_16);
  end;

  procedure TVGADriver.setPalette(palette: PColorPalette);
  var
    rgbColors: PRGBColor;
    count, c, size: word;
    shiftedColors: PRGBColor;
    oldColor, newColor: PRGBColor;
  begin
    palette^.getColors(rgbColors, count);
    size := count * sizeof(TRGBColor);
    getMem(shiftedColors, size);
    c := count;
    oldColor := rgbColors;
    newColor := shiftedColors;
    while c>0 do
    begin
      newColor^.r := oldColor^.r shr 2; { needs to be shifted twice to the }
      newColor^.g := oldColor^.g shr 2; { right because the palette uses }
      newColor^.b := oldColor^.b shr 2; { 0..255 and VGA expects 0..63 }
      inc(oldColor);
      inc(newColor);
      dec(c);
    end;
    setDACColorRegistersBlock(shiftedColors, count, 0);
    freeMem(shiftedColors, size);
  end;

  function TVGADriver.getDriverName: string;
  begin
    getDriverName := 'VGA';
  end;

  function TVGADriver.getClassName: string;
  begin
    getClassName := 'TVGADriver';
  end;

  function TVGADriver.getClassId: word;
  begin
    getClassId := C_CLASS_ID_VGADriver;
  end;

  { TVGAMode13Bitmap public }

  constructor TVGAMode13Bitmap.init;
  begin
    inherited initWithSize(320, 200);
  end;

  destructor TVGAMode13Bitmap.done;
  begin
    inherited done;
  end;

  procedure TVGAMode13Bitmap.setPixel(x, y: word; color: TColor);
  begin
    if (x>319) or (y>199) then exit;
    mem[$A000 : y shl 8 + y shl 6 + x] := color;
  end;

  procedure TVGAMode13Bitmap.setPixelBlock(x1, y1, x2, y2: word; color: TColor);
  var
    p: pByte;
    w, y: word;
  begin
    w := x2-x1+1;
    p := ptr($A000, y2 shl 8 + y2 shl 6 + x1);
    for y:= y2-y1 downto 0 do
    begin
      fillchar(p^, w, color);
      dec(p, 320);
    end;
  end;

  procedure TVGAMode13Bitmap.merge(src: PBitmap; x, y: word);
  var
    sw, sh: word;
    sr, sp, tp: pbyte;
    sx, sy, i: word;
  begin  
    sw := src^.getWidth;
    sh := src^.getHeight;
    if (src^.getBitsPerPixel = 8) then
    begin
      if (x = 0) and (y = 0) and (sw = 320) and (sh = 200) then
        Move(src^.getRawPixels^, ptr($A000, 0)^, sw * sh)
      else
      begin
        sw := src^.getWidth;
        sh := src^.getHeight;
        sr := src^.getRawPixels;
        sx := minword(320 - x, sw);      
        sy := minword(200 - y, sh);
        i := sy;
        tp := ptr($A000, y shl 8 + y shl 6 + x);
        sp := sr;
        while i>0 do
        begin
          Move(sp^, tp^, sw);
          dec(i);
          inc(tp, 320);
          inc(sp, sw);
        end;
      end;
    end else
      inherited merge(src, x, y);
  end;

  procedure TVGAMode13Bitmap.clear(color: TColor);
  begin
    fillchar(Ptr($A000,0)^, 64000, color);
  end;

  function TVGAMode13Bitmap.getPixel(x, y: word): TColor;
  begin
    if (x>319) or (y>199) then exit;
    getPixel := mem[$A000 : y shl 8 + y shl 6 + x];
  end;

  function TVGAMode13Bitmap.getColorCount: longint;
  begin
    getColorCount := 256;
  end;

  function TVGAMode13Bitmap.getBitsPerPixel: byte;
  begin
    getBitsPerPixel := 8;
  end;

  function TVGAMode13Bitmap.getClassName: string;
  begin
    getClassName := 'TVGAMode13Bitmap';
  end;

  function TVGAMode13Bitmap.getClassId: word;
  begin
    getClassId := C_CLASS_ID_VGAMode13Bitmap;
  end;

  { Other }

end.