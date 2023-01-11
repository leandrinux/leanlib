{
  UHashMap Unit

  2022 LRT
}
unit
  UHashMap;

interface

  uses
    consts, utils, uclasses, types, locale, math,
    uobject, uexc;

  type
    THashValue = longint;

    PHashMapNode = ^THashMapNode;
    THashMapNode = packed record
      id: THashValue;
      obj: PObject;
    end;

    PHashMap = ^THashMap;
    THashMap = object (TObject)
    public
      constructor initWithSize(size: word);
      destructor done; virtual;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
      procedure add(id: THashValue; obj: PObject);
      function get(id: THashValue): PObject;
      procedure clear;
    private
      _size: word;
      _totalSize: word;
      _data: PHashMapNode;
      _count: word;
    end;

implementation

  { THashMap public }

  constructor THashMap.initWithSize(size: word);
  begin
    inherited init;
    _size := size;
    iassert(size <= ($FFFF div sizeof(THashMapNode)), @self, 0, S_ERR_NOT_ENOUGH_MEMORY);
    _totalSize := size * sizeof(THashMapNode);
    getMem(_data, _totalSize);
    _count := 0;
  end;

  destructor THashMap.done;
  begin
    clear;
    freeMem(_data, _totalSize);
    inherited done;
  end;

  function THashMap.getClassName: string;
  begin
    getClassName := 'THashMap';
  end;

  function THashMap.getClassId: word;
  begin
    getClassId := C_CLASS_ID_HashMap;
  end;

  procedure THashMap.add(id: THashValue; obj: PObject);
  var 
    p: PHashMapNode;
  begin
    iassert(_count < _size, @self, 0, S_ERR_NOT_ENOUGH_MEMORY);
    p := incptr(_data, _count * sizeOf(THashMapNode));
    p^.id := id;
    p^.obj := obj;
    obj^.retain;
    inc(_count);
  end;

  function THashMap.get(id: THashValue): PObject;
  var
    i: word;
    p: PHashMapNode;
  begin
    i := 0;
    p := _data;
    while (i < _count) and (p^.id <> id) do
    begin
      inc(i);
      inc(p);
    end;
    if (i = _count) then
      get := nil
    else
      get := p^.obj;
  end;

  procedure THashMap.clear;
  var
    i: word;
    p: PHashMapNode;
  begin
    i := 0;
    p := _data;
    while (i < _count) do
    begin
      p^.obj^.release;
      inc(i);
      inc(p);
    end;
  end;

  { THashMap private }

  { Other }

end.
