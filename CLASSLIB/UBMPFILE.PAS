{
  ubmpfile Unit
  8-bit palettized BMP file read-only implementation
  2022 LRT
}
unit
  ubmpfile;

interface

  uses
    consts, utils, uexc, uclasses, types, locale, uobject, ustream,
    ubitmap, ubitmap8, upalette;

  type

    TBMPFileHeader = packed record
      signature: array[0..1] of char; { must be 'BM' }
      filesize: longint;              { size of the BMP file }
      reserved: longint;              { defined by file creator }
      pixelDataOffset: longint;       { offset to pixel data }
    end;

    PBMPInfoHeader = ^TBMPInfoHeader;
    TBMPInfoHeader = packed record
      size: longint;                  { size of the info header }
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

    PBMPFile = ^TBMPFile;
    TBMPFile = object (TObject)
    public
      constructor initWithStream(stream: PStream);
      destructor done; virtual;
      function isValid: boolean;
      function getBitmap: PBitmap;
      function getInfo: PBMPInfoHeader;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
    private
      _stream: PStream;
      _initialPos: longint;
      _fileHeader: TBMPFileHeader;
      _infoHeader: TBMPInfoHeader;
      _bitmap: PBitmap8;
      procedure loadMetadata;
      procedure loadBitmap;
    end;

    PBMPColor = ^TBMPColor;
    TBMPColor = packed record b, g, r, x: byte; end;

implementation

  { TBMPFile public }

  constructor TBMPFile.initWithStream(stream: PStream);
  begin
    inherited init;
    _stream := stream;
    _stream^.retain;
    _bitmap := nil;
    loadMetadata;
  end;

  destructor TBMPFile.done;
  begin
    if _bitmap <> nil then _bitmap^.release;
    _stream^.release;
    inherited done;
  end;

  function TBMPFile.isValid: boolean;
  begin
    isValid := (_fileHeader.signature = 'BM')
      and (_infoHeader.compression = 0)
      and (_infoHeader.bitsPerPixel = 8);
  end;

  function TBMPFile.getBitmap: PBitmap;
  begin
    if _bitmap = nil then loadBitmap;
    getBitmap := _bitmap;
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

  procedure TBMPFile.loadMetadata;
  var res: word;
  begin
    _initialPos := _stream^.getPosition;
    _stream^.read(@_fileHeader, sizeof(TBMPFileHeader), res);
    _stream^.read(@_infoHeader, sizeof(TBMPInfoHeader), res);
    if not isValid then exit;
  end;

  procedure TBMPFile.loadBitmap;
  const
    C_COLOR_COUNT = 256;
  var
    bmpColors: array[0..255] of TBMPColor;
    bmpColor: PBMPColor;
    rgbColors: PRGBColor;
    rgbColor: PRGBColor;
    palette: PColorPalette;
    paletteSize: word;
    res: word;
  begin
    if _bitmap <> nil then _bitmap^.release;

    _bitmap := new(PBitmap8, initWithSize(_infoHeader.width, _infoHeader.height));

    { read pixel data and set it to bitmap}
    _stream^.seek(_initialPos + _fileHeader.pixelDataOffset);
    _stream^.read(_bitmap^.getPixels, _infoHeader.imageSize, res);

    {
      read palette and set it to bitmap
      BMP files contain 4 bytes per pixel (b,g,r and reserved) while
      our palette control expects only r, g, b values
    }
    _stream^.seek(_initialPos + sizeOf(TBMPFileHeader) + sizeOf(TBMPInfoHeader));
    _stream^.read(@bmpColors, sizeof(bmpColors), res);
    paletteSize := sizeof(TRGBColor) * C_COLOR_COUNT;
    getMem(rgbColors, paletteSize);
    bmpColor := @bmpColors;
    rgbColor := rgbColors;
    res := C_COLOR_COUNT;
    while res>0 do
    begin
      rgbColor^.r := bmpColor^.r;
      rgbColor^.g := bmpColor^.g;
      rgbColor^.b := bmpColor^.b;
      dec(res);
      inc(bmpColor);
      inc(rgbColor);
    end;
    palette := new(PColorPalette, initWithColors(rgbColors, 256, 0));
    freeMem(rgbColors, paletteSize);
    _bitmap^.setPalette(palette);
    palette^.release;
  end;

  { Other }

end.