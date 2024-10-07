{
  ulist Unit
  Implements a list of TObjects
  2022 LRT
}
unit
  ulist;

interface

  uses
    consts, uexc, uclasses, types, locale, uobject, ustring, unumber;

  type
    PListNode = ^TListNode;

    PList = ^TList;
    TList = object (TObject)
    public
      constructor init;
      constructor initWithClassFamily(fromClassId, toClassId: word);
      constructor initWithClassId(classId: word);
      destructor done; virtual;
      procedure addObject(obj: PObject);
      procedure addString(value: string);
      procedure addLong(value: longint);
      procedure addObjectAt(obj: PObject; index: longint);
      procedure addObjectInOrder(obj: PObject);
      procedure removeObjectAt(index: longint);
      procedure removeObject(obj: PObject);
      procedure removeObjectAtCursor;
      procedure removeFirst;
      procedure clear;
      procedure moveToStart;
      procedure moveToIndex(index: longint);
      procedure moveForward;
      function getObjectAtCursor: PObject;
      function getObjectAfterCursor: PObject;
      function getStringAtCursor: string;
      function getLongAtCursor: longint;
      function getFirst: PObject;
      function getLast: PObject;
      function getCount: longint;
      function getObjectAt(index: longint): PObject;
      function getStringAt(index: longint): string;
      function getLongAt(index: longint): longint;
      function getIndexOf(obj: PObject): longint;
      function find(value: pointer; func: TCompareFunc): PObject;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
      procedure setWeak(value: boolean);
    private
      _head: PListNode;
      _tail: PListNode;
      _cursor: PListNode;
      _count: longint;
      _enforceClassId: boolean;
      _fromClassId, _toClassId: word;
      _isWeak: boolean;
      procedure initializeList;
      procedure makeNode(var node: PListNode; obj: PObject);
      procedure killNode(var node: PListNode);
    end;

    TListNode = record
      obj: PObject;
      next: PListNode;
    end;

implementation

  { TList public }

  constructor TList.init;
  begin
    inherited init;
    initializeList;
    _enforceClassId := false;
    _isWeak := false;
  end;

  constructor TList.initWithClassFamily(fromClassId, toClassId: word);
  begin
    inherited init;
    initializeList;
    _enforceClassId := true;
    _fromClassId := fromClassId;
    _toClassId := toClassId;
    _isWeak := false;
  end;

  constructor TList.initWithClassId(classId: word);
  begin
    initWithClassFamily(classId, classId);
  end;

  destructor TList.done;
  begin
    clear;
    inherited done;
  end;

  procedure TList.addObject(obj: PObject);
  var
    node: PListNode;
    lastNode: PListNode;
  begin
    if _enforceClassId then
      iassert(
        (obj^.getClassId >= _fromClassId) and (obj^.getClassId <= _toClassId),
        @self, 0, S_ERR_INCORRECT_MEMBER_CLASS
      );
    makeNode(node, obj);
    if _count = 0 then
    begin
      _head := node;
      _tail := node;
      _cursor := node;
      _count := 1;
    end else begin
      _tail^.next := node;
      _tail := node;
      inc(_count);
    end;
  end;

  procedure TList.addString(value: string);
  var
    str: PString;
  begin
    str := new(PString, initWithValue(value));
    addObject(str);
    str^.release;
  end;

  procedure TList.addLong(value: longint);
  var
    number: PNumber;
  begin
    number := new(PNumber, init);
    number^.setValue(value);
    addObject(number);
    number^.release;
  end;

  procedure TList.addObjectAt(obj: PObject; index: longint);
  var
    node, current, previous: PListNode;
    i: longint;
  begin
    if _enforceClassId then
      iassert(
        (obj^.getClassId >= _fromClassId) and (obj^.getClassId <= _toClassId),
        @self, 0, S_ERR_INCORRECT_MEMBER_CLASS
      );
    makeNode(node, obj);
    if index = 0 then
    begin
      node^.next := _head;
      _head := node;
      if _count = 0 then _tail := node;
    end else
    begin
      if index = _count then
      begin
        _tail^.next := node;
        _tail := node;
      end else
      begin
        current := _head;
        previous := nil;
        for i:=1 to index do
        begin
          previous := current;
          current := current^.next;
        end;
        node^.next := current;
        previous^.next := node;
      end;
    end;
    inc(_count);
  end;

  procedure TList.addObjectInOrder(obj: PObject);
  var
    curr, prev, node: PListNode;
  begin
    if _enforceClassId then
      iassert(
        (obj^.getClassId >= _fromClassId) and (obj^.getClassId <= _toClassId),
        @self, 0, S_ERR_INCORRECT_MEMBER_CLASS
      );
    makeNode(node, obj);
    prev := nil;
    curr := _head;
    while (curr <> nil) and (node^.obj^.compare(curr^.obj) = ECompareGreater) do
    begin
      prev := curr;
      curr := curr^.next;
    end;
    if prev = nil then
      _head := node
    else
      prev^.next := node;
    node^.next := curr;
    inc(_count);
  end;

  procedure TList.removeObjectAt(index: longint);
  var
    previous, current, next: PListNode;
    i: longint;
  begin
    if index = 0 then
    begin
      current := _head;
      _head := _head^.next;
      if _head = nil then _tail := nil;
    end else
    begin
      previous := nil;
      current := _head;
      for i:=1 to index do
      begin
        previous := current;
        current := current^.next;
      end;
      if current = _tail then _tail := previous;
      previous^.next := current^.next;
    end;
      if _cursor = current then _cursor := current^.next;
      killNode(current);
      dec(_count);
  end;

  procedure TList.removeObject(obj: PObject);
  var
    curr, prev: PListNode;
  begin
    prev := nil;
    curr := _head;
    while (curr <> nil) and (curr^.obj <> obj) do
    begin
      prev := curr;
      curr := curr^.next;
    end;
    if curr <> nil then
    begin
      if _head = curr then
        _head := _head^.next
      else
        prev^.next := curr^.next;
      if _tail = curr then _tail := prev;
      if _cursor = curr then _cursor := curr^.next;
      killNode(curr);
      dec(_count);
    end;
  end;

  procedure TList.removeObjectAtCursor;
  begin
    removeObject(_cursor^.obj);
  end;

  procedure TList.removeFirst;
  begin
    removeObjectAt(0);
  end;

  procedure TList.clear;
  begin
    while _count > 0 do self.removeObjectAt(0);
    _cursor := _head;
  end;

  procedure TList.moveToStart;
  begin
    _cursor := _head;
  end;

  procedure TList.moveToIndex(index: longint);
  var i: longint;
  begin
    _cursor := _head;
    for i := 0 to index do _cursor := _cursor^.next;
  end;

  procedure TList.moveForward;
  begin
    if _cursor <> nil then _cursor := _cursor^.next;
  end;

  function TList.getObjectAtCursor: PObject;
  begin
    if _cursor <> nil then
      getObjectAtCursor := _cursor^.obj
    else
      getObjectAtCursor := nil;
  end;

  function TList.getObjectAfterCursor: PObject;
  begin
    if (_cursor <> nil) and (_cursor^.next <> nil) then
      getObjectAfterCursor := _cursor^.next^.obj
    else
      getObjectAfterCursor := nil;
  end;

  function TList.getStringAt(index: longint): string;
  begin
    getStringAt := PString(getObjectAt(index))^.getValue;
  end;

  function TList.getLongAt(index: longint): longint;
  begin
    getLongAt := PNumber(getObjectAt(index))^.getValue;
  end;

  function TList.getStringAtCursor: string;    
  begin
    if _cursor <> nil then
      getStringAtCursor := PString(_cursor^.obj)^.getValue
    else
      getStringAtCursor := '';
  end;

  function TList.getLongAtCursor: longint;
  begin
    if _cursor <> nil then
      getLongAtCursor := PNumber(_cursor^.obj)^.getValue
    else
      getLongAtCursor := 0;
  end;

  function TList.getFirst: PObject;
  begin
    if _head <> nil then
      getFirst := _head^.obj
    else
      getFirst := nil;
  end;

  function TList.getLast: PObject;
  begin
    if _tail <> nil then
      getLast := _tail^.obj
    else
      getLast := nil;
  end;

  function TList.getCount: longint;
  begin
    getCount := _count;
  end;

  function TList.getObjectAt(index: longint): PObject;
  var
    current: PListNode;
    i: longint;
  begin
    current := _head;
    i := 0;
    while (current <> nil) and (i < index) do
    begin
      current := current^.next;
      inc(i);
    end;
    if current = nil then
      getObjectAt := nil
    else
      getObjectAt := current^.obj;
  end;

  function TList.getIndexOf(obj: PObject): longint;
  var
    node: PListNode;
    index: longint;
  begin
    node := _head;
    index := 0;
    while (node <> nil) and (node^.obj <> obj) do
    begin
      inc(index);
      node := node^.next;
    end;
    if node = nil then index := C_NOT_FOUND;
    getIndexOf := index;
  end;

  function TList.find(value: pointer; func: TCompareFunc): PObject;
  var
    res: PObject;
    node: PListNode;
  begin
    res := nil;
    node := _head;
    while (node<>nil) and (func(value, node^.obj)<>ECompareEqual) do
      node := node^.next;
    if node<>nil then res := node^.obj;
    find := res;
  end;

  function TList.getClassName: string;
  begin
    getClassName := 'TList';
  end;

  function TList.getClassId: word;
  begin
    getClassId := C_CLASS_ID_List;
  end;

  procedure TList.setWeak(value: boolean);
  begin
    if _isWeak = value then exit;
    clear;
    _isWeak := value;
  end;

  { TList private }

  procedure TList.initializeList;
  begin
    _head := nil;
    _tail := nil;
    _cursor := nil;
    _count := 0;
  end;

  procedure TList.makeNode(var node: PListNode; obj: PObject);
  begin
    GetMem(node, SizeOf(TListNode));
    node^.obj := obj;
    node^.next := nil;
    if not _isWeak then obj^.retain;
  end;

  procedure TList.killNode(var node: PListNode);
  begin
    if not _isWeak then node^.obj^.release;
    FreeMem(node, SizeOf(TListNode));
    node := nil;
  end;

  { Other }

end.