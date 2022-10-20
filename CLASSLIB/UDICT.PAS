{
  udict Unit
  A dictionary implementation for (key, value) pairs
  2022 LRT
}
unit
  udict;

interface

  uses
    uexc, uclasses, consts, types, utils, locale, strings,
    uobject, ulist, unumber, ustring;

  type

    PDictionaryKey = ^TDictionaryKey;
    TDictionaryKey = string16;

    PDictionary = ^TDictionary;
    TDictionary = object (TObject)
    public
      constructor init;
      destructor done; virtual;
      procedure addObject(obj: PObject; key: TDictionaryKey);
      procedure addLong(value: longint; key: TDictionaryKey);
      procedure addString(value: string; key: TDictionaryKey);
      procedure getKeys(var list: PList);
      function keyExists(key: TDictionaryKey): boolean;
      function getObject(key: TDictionaryKey): PObject;
      function getLong(key: TDictionaryKey; alt: longint): longint;
      function getBool(key: TDictionaryKey; alt: boolean): boolean;
      function getString(key: TDictionaryKey; alt: string): string;
      function getObjectWithPath(path: string):PObject;
      function getLongWithPath(path: string; alt: longint): longint;
      function getBoolWithPath(path: string; alt: boolean): boolean;
      function getStringWithPath(path: string; alt: string): string;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
    private
      _nodes: PList;
    end;

implementation

  type
    PKeyValueNode = ^TKeyValueNode;

    TKeyValueNode = object (TObject)
      public
        constructor init(key: TDictionaryKey; obj: PObject);
        destructor done; virtual;
        function compare(value: PObject): ECompareResult; virtual;
        function getKeyPtr: PDictionaryKey;
        function getObject: PObject;
        function getClassName: string; virtual;
      private
        _key: TDictionaryKey;
        _obj: PObject;
    end;

  { utility functions and procs }

  function compareNodeKey(value: pointer; obj: PObject): ECompareResult; far;
  begin
    compareNodeKey := compareStr(PDictionaryKey(value), PKeyValueNode(obj)^.getKeyPtr);
  end;

  { TKeyValueNode }

  constructor TKeyValueNode.init(key: TDictionaryKey; obj: PObject);
  begin
    inherited init;
    _key := key;
    _obj := obj;
    _obj^.retain;
  end;

  destructor TKeyValueNode.done;
  begin
    _obj^.release;
    inherited done;
  end;

  function TKeyValueNode.compare(value: PObject): ECompareResult;
  begin
    compare := compareStr(@_key, PKeyValueNode(value)^.getKeyPtr);
  end;

  function TKeyValueNode.getKeyPtr: PDictionaryKey;
  begin
    getKeyPtr := @_key;
  end;

  function TKeyValueNode.getObject: PObject;
  begin
    getObject := _obj;
  end;

  function TKeyValueNode.getClassName: string;
  begin
    getClassName := 'TKeyValueNode';
  end;

  { TDictionary public }

  constructor TDictionary.init;
  begin
    inherited init;
    New(_nodes, init);
  end;

  destructor TDictionary.done;
  begin
    _nodes^.release;
    inherited done;
  end;

  procedure TDictionary.addObject(obj: PObject; key: TDictionaryKey);
  var
    node: PKeyValueNode;
  begin
    New(node, init(key, obj));
    _nodes^.addObjectInOrder(node);
    node^.release;
  end;

  procedure TDictionary.addLong(value: longint; key: TDictionaryKey);
  var number: PNumber;
  begin
    New(number, init);
    number^.setValue(value);
    addObject(number, key);
    number^.release;
  end;

  procedure TDictionary.addString(value: string; key: TDictionaryKey);
  var str: PString;
  begin
    New(str, init);
    str^.setValue(value);
    addObject(str, key);
    str^.release;
  end;

  function TDictionary.keyExists(key: TDictionaryKey): boolean;
  begin
    keyExists := _nodes^.find(@key, compareNodeKey) <> nil;
  end;

  function TDictionary.getObject(key: TDictionaryKey): PObject;
  var node: PKeyValueNode;
  begin
    node := PKeyValueNode(_nodes^.find(@key, compareNodeKey));
    if node <> nil then
      getObject := node^.getObject
    else
      getObject := nil;
  end;

  function TDictionary.getLong(key: TDictionaryKey; alt: longint): longint;
  var number: PNumber;
  begin
    number := PNumber(getObject(key));
    if number <> nil then getLong := number^.getValue else getLong := alt;
  end;

  function TDictionary.getBool(key: TDictionaryKey; alt: boolean): boolean;
  var number: PNumber;
  begin
    number := PNumber(getObject(key));
    if number <> nil then getBool := number^.getBoolValue else getBool := alt;
  end;

  function TDictionary.getString(key: TDictionaryKey; alt: string): string;
  var str: PString;
  begin
    str := PString(getObject(key));
    if str <> nil then getString := str^.getValue else getString := alt;
  end;

  function TDictionary.getObjectWithPath(path: string):PObject;
  var
    p: byte;
    obj: PObject;
    key, subpath: string;
  begin
    p := pos(C_DICTIONARY_PATH_SEPARATOR, path);
    if p = 0 then
      getObjectWithPath := GetObject(path)
    else begin
      key := subString(path,1,p-1);
      subpath := subString(path, p+1, length(path)-p);
      obj := getObject(key);
      if (obj <> nil) then
      begin
        if (length(subpath) > 0) and
          (obj^.getClassId = C_CLASS_ID_DICTIONARY) then
        begin
          getObjectWithPath := PDictionary(obj)^.GetObjectWithPath(subpath)
        end else
          getObjectWithPath := obj;
      end else
        getObjectWithPath := nil;
    end;
  end;

  function TDictionary.getLongWithPath(path: string; alt: longint): longint;
  var obj: PObject;
  begin
    obj := getObjectWithPath(path);
    if (obj <> nil) and (obj^.getClassId = C_CLASS_ID_NUMBER) then
      getLongWithPath := PNumber(obj)^.getValue
    else
      getLongWithPath := alt;
  end;

  function TDictionary.getBoolWithPath(path: string; alt: boolean): boolean;
  var obj: PObject;
  begin
    obj := getObjectWithPath(path);
    if (obj <> nil) and (obj^.getClassId = C_CLASS_ID_NUMBER) then
      getBoolWithPath := PNumber(obj)^.getBoolValue
    else
      getBoolWithPath := alt;
  end;

  function TDictionary.getStringWithPath(path: string; alt: string): string;
  var obj: PObject;
  begin
    obj := getObjectWithPath(path);
    if (obj <> nil) and (obj^.getClassId = C_CLASS_ID_STRING) then
      getStringWithPath := PString(obj)^.getValue
    else
      getStringWithPath := alt;
  end;

  procedure TDictionary.getKeys(var list: PList);
  var
    node: PKeyValueNode;
  begin
    _nodes^.moveToStart;
    node := PKeyValueNode(_nodes^.getObjectAtCursor);
    while node <> nil do
    begin
      list^.addString(node^.getKeyPtr^);
      _nodes^.moveForward;
      node := PKeyValueNode(_nodes^.getObjectAtCursor);
    end;
  end;

  function TDictionary.getClassName: string;
  begin
    getClassName := 'TDictionary';
  end;

  function TDictionary.getClassId: word;
  begin
    getClassId := C_CLASS_ID_Dictionary;
  end;

  { TDictionary private }

  { Other }

end.