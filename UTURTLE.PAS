{
  uturtle Unit
  Turtle graphics (LOGO style) using canvas
  2022 LRT
}
unit
  uturtle;

interface

  uses
    consts, utils, uexc, uclasses, types, locale, uobject, ubitmap,
    ucanvas;

  type
    PTurtle = ^TTurtle;
    TTurtle = object (TObject)
    public
      constructor initWithBitmap(bitmap: PBitmap);
      destructor done; virtual;
      procedure move(x, y: word);
      procedure line(x, y: word);
      procedure rline(x, y: integer);
      procedure setColor(color: TColor);
      procedure setPresetColor(color: EColor);
      function getClassName: string; virtual;
      function getClassId: word; virtual;
    private
      _bitmap: PBitmap;
      _canvas: PCanvas;
      _x, _y: word;
    end;

implementation

  { TTurtle public }

  constructor TTurtle.initWithBitmap(bitmap: PBitmap);
  begin
    inherited init;
    _bitmap := bitmap;
    _canvas := new(PCanvas, initWithBitmap(bitmap));
    setPresetColor(EWhite);
    move(_bitmap^.getWidth div 2, _bitmap^.getHeight div 2);
  end;

  destructor TTurtle.done;
  begin
    _canvas^.release;
    _bitmap^.release;
    inherited done;
  end;

  procedure TTurtle.move(x, y: word);
  begin
    _x := x;
    _y := y;
  end;

  procedure TTurtle.line(x, y: word);
  begin
    _canvas^.line(_x, _y, x, y);
    _x := x;
    _y := y;
  end;

  procedure TTurtle.rline(x, y: integer);
  begin
    x := x + _x;
    y := y + _y;
    line(x, y);
  end;

  procedure TTurtle.setColor(color: TColor);
  begin
    _canvas^.getStrokeBrush^.color := color;
  end;

  procedure TTurtle.setPresetColor(color: EColor);
  begin
    _canvas^.getStrokeBrush^.color := _bitmap^.getPresetColor(color);
  end;

  function TTurtle.getClassName: string;
  begin
    getClassName := 'TTurtle';
  end;

  function TTurtle.getClassId: word;
  begin
    getClassId := C_CLASS_ID_Turtle;
  end;

  { TTurtle private }

  { Other }

end.