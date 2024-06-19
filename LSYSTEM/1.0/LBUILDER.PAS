unit
  lbuilder;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc, ustream, ufstream;

  type
    PBuilder = ^TBuilder;
    TBuilder = object (TObject)
    public
      constructor init;
      destructor done; virtual;
      procedure setDelegate(obj: PObject);
      procedure setSource(stream: PStream);
      procedure setSourceFromFile(filename: string);
      procedure build;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
    private
      _delegate: PObject;
      _source: PStream;
    end;

  const
    C_CLASS_ID_BUILDER = $F00F;

implementation

  { TBuilder public }

  constructor TBuilder.init;
  begin
    inherited init;
    _delegate := nil;
    _source := nil;
  end;

  destructor TBuilder.done;
  begin
    if _source<>nil then _source^.release;
    inherited done;
  end;

  function TBuilder.getClassName: string;
  begin
    getClassName := 'TBuilder';
  end;

  function TBuilder.getClassId: word;
  begin
    getClassId := C_CLASS_ID_BUILDER;
  end;

  procedure TBuilder.setDelegate(obj: PObject);
  begin
    _delegate := obj;
  end;

  procedure TBuilder.build;
  begin
    
  end;

  procedure TBuilder.setSource(stream: PStream);
  begin
    if _source<>nil then _source^.release;
    _source := stream;
    _source^.retain;
  end;

  procedure TBuilder.setSourceFromFile(filename: string);
  var
    fs: PFileStream;
  begin
    fs := new(PFileStream, initWithPath(filename, EFileReadOnly));
    setSource(fs);
  end;

  { TBuilder private }

  { Other }

end.
