{
  UDisplay Unit
  Implements the program interface to the video adapter, allowing to get
  video information, set video modes and access the display canvas
  2022 LRT
}
unit
  udisplay;

interface

  uses
    uexc, uclasses, types, locale, uobject, uviddrv, uvgadrv, ulog,
    ucanvas, ubitmap, ubitmap8, upalette;

  type
    PDisplayAdapter = ^TDisplayAdapter;
    TDisplayAdapter = object (TObject)
    public
      constructor init;
      destructor done; virtual;
      function detectAdapter: boolean;
      procedure getVideoModes(var list:PVideoMode; var count: word);
      procedure setVideoMode(index: word);
      procedure setTextMode;
      procedure setPalette(palette: PColorPalette);
      function isPaletteSupported: boolean;
      function getCurrentVideoMode: PVideoMode;
      function getCanvas: PCanvas;
      function getDriver: PVideoDriver;
      function getVideoDriverName: string;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
    private
      _driver: PVideoDriver;
      _canvas: PCanvas;
    end;

  var
    DisplayAdapter: PDisplayAdapter;

implementation

  { TDisplayAdapter }

  constructor TDisplayAdapter.init;
  begin
    _driver := nil;
    _canvas := nil;
    inherited init;
  end;

  destructor TDisplayAdapter.done;
  begin
    if _canvas <> nil then _canvas^.release;
    if _driver <> nil then _driver^.release;
    inherited done;
  end;

  function TDisplayAdapter.detectAdapter: boolean;
  var
    res: boolean;
    vgadrv: PVGADriver;
  begin
    res := false;
    new(vgadrv, init);
    if vgadrv^.isAvailable then
    begin
      _driver := vgadrv;
      vgadrv^.retain;
      res := true;
    end;
    vgadrv^.release;
    detectAdapter := res;
  end;

  procedure TDisplayAdapter.getVideoModes(var list:PVideoMode; var count: word);
  begin
    iassert(_driver <> nil, @self, 0, S_ERR_DRIVER_NOT_READY);
    _driver^.getVideoModes(list, count);
  end;

  procedure TDisplayAdapter.setVideoMode(index: word);
  begin
    iassert(_driver <> nil, @self, 0, S_ERR_DRIVER_NOT_READY);
    _driver^.setVideoMode(index);
    if _canvas <> nil then _canvas^.release;
    _canvas := new(PCanvas, initWithBitmap(_driver^.getBitmap));
  end;

  procedure TDisplayAdapter.setTextMode;
  begin
    iassert(_driver <> nil, @self, 0, S_ERR_DRIVER_NOT_READY);
    if _canvas <> nil then
    begin
      _canvas^.release;
      _canvas := nil;
    end;
    _driver^.setTextMode;
  end;

  procedure TDisplayAdapter.setPalette(palette: PColorPalette);
  begin
    iassert(_driver <> nil, @self, 0, S_ERR_DRIVER_NOT_READY);
    _driver^.setPalette(palette);
  end;

  function TDisplayAdapter.isPaletteSupported: boolean;
  begin
    iassert(_driver <> nil, @self, 0, S_ERR_DRIVER_NOT_READY);
    isPaletteSupported := _driver^.supportsPalette;
  end;

  function TDisplayAdapter.getCurrentVideoMode: PVideoMode;
  begin
    iassert(_driver <> nil, @self, 0, S_ERR_DRIVER_NOT_READY);
    getCurrentVideoMode := _driver^.getCurrentVideoMode;
  end;

  function TDisplayAdapter.getCanvas: PCanvas;
  begin
    getCanvas := _canvas;
  end;

  function TDisplayAdapter.getDriver: PVideoDriver;
  begin
    getDriver := _driver;
  end;

  function TDisplayAdapter.getVideoDriverName: string;
  begin
    iassert(_driver <> nil, @self, 0, S_ERR_DRIVER_NOT_READY);
    getVideoDriverName := _driver^.GetDriverName;
  end;

  function TDisplayAdapter.getClassName: string;
  begin
    getClassName := 'TDisplayAdapter';
  end;

  function TDisplayAdapter.getClassId: word;
  begin
    getClassId := C_CLASS_ID_DisplayAdapter;
  end;

  { private }

  { Other }

begin
  DisplayAdapter := new(PDisplayAdapter, init);
  DisplayAdapter^.detectAdapter;
end.