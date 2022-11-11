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
      procedure loadPalette;
    end;

    PBMPColorEntry = ^TBMPColorEntry;
    TBMPColorEntry = packed record b, g, r, x: byte; end;

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
  var
    res: word;
  begin
    if _bitmap <> nil then _bitmap^.release;
    _bitmap := new(PBitmap8, initWithSize(_infoHeader.width, _infoHeader.height));
    _stream^.seek(_initialPos + _fileHeader.pixelDataOffset);
    _stream^.read(_bitmap^.getPixels, _infoHeader.imageSize, res);
    loadPalette;
  end;

  procedure TBMPFile.loadPalette;
  var
    tablePosition: longint;
    colorTable, p: PBMPColorEntry;
    colorTableSize: longint;
    i: word;
    palette: PColorPalette;
    rgbColor: TRGBColor;
  begin
    tablePosition := _initialPos + sizeOf(TBMPFileHeader) + _infoHeader.size;
    colorTableSize := _infoHeader.colorsUsed * sizeof(TBMPColorEntry);
    getMem(colorTable, colorTableSize);
    _stream^.seek(tablePosition);
    _stream^.read(colorTable, colorTableSize, i);
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