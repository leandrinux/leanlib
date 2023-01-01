{
  ubmpfile Unit
  8-bit palettized BMP file read-only implementation
  2022 LRT

  Info obtained from https://learn.microsoft.com/en-us/windows/win32/gdi/bitmap-header-types
}
unit
  ubmpfile;

interface

  uses
    consts, utils, uexc, uclasses, types, locale, math,
    uobject, ustream, ubitmap, ubitmap8, upalette;

  type
    PBMPCoreHeader = ^TBMPCoreHeader;
    TBMPCoreHeader = packed record
      signature: array[0..1] of char; { must be 'BM' }
      filesize: longint;              { size of the BMP file }
      reserved: longint;              { defined by file creator }
      pixelDataOffset: longint;       { offset to pixel data }
    end;

    PBMPInfoHeader = ^TBMPInfoHeader;
    TBMPInfoHeader = packed record
      infoHeaderSize: longint;        { size of the info header }
      width: longint;                 { bitmap width in pixels }
      height: longint;                { bitmap height in pixels }
      planes: word;                   { number of planes (usually 1) }
      bitsPerPixel: word;             { how many bits represent one pixel }
      compression: longint;           { compression algorithm (0=none) }
      imageSize: longint;             { full image size (0 if compression=0) }
      XpixelsPerM: longint;           { horizontal res in pixels per meter }
      YpixelsPerM: longint;           { vertical res in pixels per meter }
      colorsUsed: longint;            { number of actually used colors }
      importantColors: longint;       { number of important colors (0=all) }
    end;

    FXPT2DOT30 = longint;

    CIEXYZ = packed record
      ciexyzX: FXPT2DOT30;
      ciexyzY: FXPT2DOT30;
      ciexyzZ: FXPT2DOT30;
    end;

    CIEXYZTRIPLE = packed record
      ciexyzRed: CIEXYZ;
      ciexyzGreen: CIEXYZ;
      ciexyzBlue: CIEXYZ;
    end;  
{
    PBMPV4Header = ^TBMPV4Header;
    TBMPV4Header = packed record
      bV4Size: DWORD;
      bV4Width: LONG;
      bV4Height: LONG;
      bV4Planes: WORD;
      bV4BitCount: WORD;
      bV4V4Compression: DWORD;
      bV4SizeImage: DWORD;
      bV4XPelsPerMeter: LONG;
      bV4YPelsPerMeter: LONG;
      bV4ClrUsed: DWORD;
      bV4ClrImportant: DWORD;
      bV4RedMask: DWORD;
      bV4GreenMask: DWORD;
      bV4BlueMask: DWORD;
      bV4AlphaMask: DWORD;
      bV4CSType: DWORD;
      bV4Endpoints: CIEXYZTRIPLE;
      bV4GammaRed: DWORD;
      bV4GammaGreen: DWORD;
      bV4GammaBlue: DWORD;
    end;

    TBMPV5Header = packed record
      bV5Size: DWORD;
      bV5Width: LONG;
      bV5Height: LONG;
      bV5Planes: WORD;
      bV5BitCount: WORD;
      bV5Compression: DWORD;
      bV5SizeImage: DWORD;
      bV5XPelsPerMeter: LONG;
      bV5YPelsPerMeter: LONG;
      bV5ClrUsed: DWORD;
      bV5ClrImportant: DWORD;
      bV5RedMask: DWORD;
      bV5GreenMask: DWORD;
      bV5BlueMask: DWORD;
      bV5AlphaMask: DWORD;
      bV5CSType: DWORD;
      bV5Endpoints: CIEXYZTRIPLE;
      bV5GammaRed: DWORD;
      bV5GammaGreen: DWORD;
      bV5GammaBlue: DWORD;
      bV5Intent: DWORD;
      bV5ProfileData: DWORD;
      bV5ProfileSize: DWORD;
      bV5Reserved: DWORD;
    end;
}
    PBMPFile = ^TBMPFile;
    TBMPFile = object (TObject)
    public
      constructor initWithStream(stream: PStream);
      destructor done; virtual;
      function isValid: boolean;
      function getVersion: string10;
      function getBitmap: PBitmap;
      function getHeader: PBMPCoreHeader;
      function getInfo: PBMPInfoHeader;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
    private
      _stream: PStream;
      _CoreHeader: TBMPCoreHeader;
      _infoHeader: TBMPInfoHeader;
      _bitmap: PBitmap8;
      procedure loadHeaders;
      procedure loadBitmap;
      procedure loadPalette;
    end;

    PRGBQuad = ^TRGBQuad;
    TRGBQuad = packed record b, g, r, x: byte; end;

implementation

  { TBMPFile public }

  constructor TBMPFile.initWithStream(stream: PStream);
  begin
    inherited init;
    _stream := stream;
    _stream^.retain;
    _bitmap := nil;
    loadHeaders;
    if isValid then loadBitmap;
  end;

  destructor TBMPFile.done;
  begin
    if _bitmap <> nil then _bitmap^.release;
    _stream^.release;
    inherited done;
  end;

  function TBMPFile.isValid: boolean;
  begin
    isValid := (_CoreHeader.signature = 'BM')
      and (_infoHeader.compression = 0)
      and (_infoHeader.bitsPerPixel = 8);
  end;

  function TBMPFile.getVersion: string10;
  begin
    if _infoHeader.infoHeaderSize = sizeof(TBMPInfoHeader) then
      getVersion := 'Legacy'
    else if _infoHeader.infoHeaderSize = 108 { sizeof(TBMPV4Header) } then
      getVersion := 'v4'
    else if _infoHeader.infoHeaderSize = 124 { sizeof(TBMPV5Header) } then
      getVersion := 'v5'
    else 
      getVersion := 'Unknown';
  end;

  function TBMPFile.getBitmap: PBitmap;
  begin
    getBitmap := _bitmap;
  end;

  function TBMPFile.getHeader: PBMPCoreHeader;
  begin
    getHeader := @_CoreHeader;
  end;

  function TBMPFile.getInfo: PBMPInfoHeader;
  begin
    getInfo := @_infoHeader;
  end;

  function TBMPFile.getClassName: string;
  begin
    getClassName := 'TBMPFile';
  end;

  function TBMPFile.getClassId: word;
  begin
    getClassId := C_CLASS_ID_BMPFile;
  end;

  { TBMPFile private }

  procedure TBMPFile.loadHeaders;
  begin
    _stream^.read(@_CoreHeader, sizeof(TBMPCoreHeader));
    _stream^.read(@_infoHeader, sizeof(TBMPInfoHeader));
  end;

  procedure TBMPFile.loadBitmap;
  var
    src, dst, a, b: pbyte;
    w, h, line: word;
    tempBitmapSize: word;
    linePadding: byte;
  begin
    w := _infoHeader.width;
    h := _infoHeader.height;

    linePadding := 4 - (w mod 4);
    if linePadding = 4 then linePadding := 0;
    _bitmap := new(PBitmap8, initWithSize(w , h));
    tempBitmapSize := (w + linePadding) * h;
    getMem(src, tempBitmapSize);
    _stream^.seek(_CoreHeader.pixelDataOffset);
    _stream^.read(src, tempBitmapSize);
    dst := _bitmap^.getRawPixels;
    a := src;
    b := dst; 
    inc(b, w*h-w);
    for line := _infoHeader.height - 1 downto 0 do
    begin
      Move(a^, b^, w);
      dec(b, w);
      inc(a, w + linePadding);
    end;
    freeMem(src, tempBitmapSize);
    loadPalette;
  end;

  procedure TBMPFile.loadPalette;
  var
    tablePosition: longint;
    colorTable, p: PRGBQuad;
    colorTableSize: longint;
    i: word;
    palette: PColorPalette;
    rgbColor: TRGBColor;
  begin
    tablePosition := sizeOf(TBMPCoreHeader) + _infoHeader.infoHeaderSize;
    colorTableSize := _infoHeader.colorsUsed * sizeof(TRGBQuad);
    getMem(colorTable, colorTableSize);
    _stream^.seek(tablePosition);
    i := _stream^.read(colorTable, colorTableSize);
    palette := new(PColorPalette, initWithCount(_infoHeader.colorsUsed));
    p := colorTable;
    for i := 0 to _infoHeader.colorsUsed-1 do
    begin
      rgbColor.r := p^.r; 
      rgbColor.g := p^.g;
      rgbColor.b := p^.b;
      palette^.setColor(@rgbColor, i);
      inc(p);
    end;
    _bitmap^.setPalette(palette);
    palette^.release;
    freeMem(colorTable, colorTableSize);
  end;

  { Other }

end.