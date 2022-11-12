{
  UPath Unit

  2022 LRT
}
unit
  UPath;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc, math;

  type
    PPath = ^TPath;
    TPath = object (TObject)
    public
      constructor initWithSize(size: word);
      destructor done; virtual;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
      procedure addPoint(x, y: integer);
      procedure getPoints(var first: PPoint; var length: word);
    private
      _size: word;
      _length: word;
      _points: PPoint;
    end;

implementation

  { TPath public }

  constructor TPath.initWithSize(size: word);
  begin
    inherited init;
    _size := size;
    _length := 0;
    getMem(_points, sizeof(TPoint) * _size);
  end;

  destructor TPath.done;
  begin
    freeMem(_points, sizeof(TPoint) * _size);
    inherited done;
  end;

  procedure TPath.addPoint(x, y: integer);
  var
    p: PPoint;
  begin
    if _length = _size then exit;
    p := _points;
    inc(p, _length);
    p^.x := x;
    p^.y := y;
    inc(_length);
  end;

  procedure TPath.getPoints(var first: PPoint; var length: word);
  begin
    first := _points;
    length := _length;
  end;

  function TPath.getClassName: string;
  begin
    getClassName := 'TPath';
  end;

  function TPath.getClassId: word;
  begin
    getClassId := C_CLASS_ID_Path;
  end;

  { TPath private }

  { Other }

end.
