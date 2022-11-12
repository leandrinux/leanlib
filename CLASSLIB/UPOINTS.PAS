{
  UPoints Unit
  2022 LRT
}
unit
  UPoints;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc, math;

  type
    PPoints = ^TPoints;
    TPoints = object (TObject)
    public
      constructor initWithSize(size: word);
      destructor done; virtual;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
      procedure add(x, y: integer);
      procedure get(var first: PPoint; var length: word);
    private
      _size: word;
      _length: word;
      _points: PPoint;
    end;

implementation

  { TPoints public }

  constructor TPoints.initWithSize(size: word);
  begin
    inherited init;
    _size := size;
    _length := 0;
    getMem(_points, sizeof(TPoint) * _size);
  end;

  destructor TPoints.done;
  begin
    freeMem(_points, sizeof(TPoint) * _size);
    inherited done;
  end;

  procedure TPoints.add(x, y: integer);
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

  procedure TPoints.get(var first: PPoint; var length: word);
  begin
    first := _points;
    length := _length;
  end;

  function TPoints.getClassName: string;
  begin
    getClassName := 'TPoints';
  end;

  function TPoints.getClassId: word;
  begin
    getClassId := C_CLASS_ID_Path;
  end;

  { TPoints private }

  { Other }

end.
