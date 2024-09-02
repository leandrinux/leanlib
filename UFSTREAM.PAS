{
  UFStream Unit
  A stream that can read and write to files
  2022 LRT
}
unit
  ufstream;

interface

  uses
    uexc, uclasses, types, uobject, ustream, locale;

  type
    PFileStream = ^TFileStream;
    TFileStream = object (TStream)
    public
      constructor initWithPath(path: TFilePath; mode: EFileOpenMode);
      destructor done; virtual;
      function read(buffer: pointer; count: word): word; virtual;
      procedure write(buffer: pointer; count: word); virtual;
      procedure seek(pos: longint); virtual;
      function getPosition: longint; virtual;
      function isEOF: boolean; virtual;
      function isFileOpen: boolean;
      function getSize: longint; virtual;
      function isReadOnly: boolean; virtual;
      function getFilePath: string;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
    private
      _fileHandle: file;
      _filePath: TFilePath;
      _isOpen: boolean;
      _mode: EFileOpenMode;
    end;

implementation

  constructor TFileStream.initWithPath(path: TFilePath; mode: EFileOpenMode);
  begin
    inherited init;
    _filePath := path;
    _mode := mode;
    assign(_fileHandle, path);
    {$I-}
    case mode of
      EFileReadOnly, EFileReadWrite:
      begin
        reset(_fileHandle, 1);
        { iassert(IOResult = 0, @self, 0, S_ERR_RESOURCE_NOT_FOUND); }
      end;

      EFileCreate:
      begin
        rewrite(_fileHandle, 1);
        { iassert(IOResult = 0, @self, 0, S_ERR_RESOURCE_CREATION_FAILED); }
      end;
    end;
    {$I+}
    _isOpen := IOResult = 0;
  end;

  destructor TFileStream.done;
  begin
    if _isOpen then
    begin
      System.close(_fileHandle);
      _isOpen := false;
    end;
    inherited done;
  end;

  function TFileStream.read(buffer: pointer; count: word): word;
  var
    result: word;
  begin
    result := 0;
    iassert(_isOpen, @self, 0, S_ERR_RESOURCE_NOT_OPEN);
    blockRead(_fileHandle, buffer^, count, result);
    read := result;
  end;

  procedure TFileStream.write(buffer: pointer; count: word);
  begin
    iassert(_isOpen, @self, 0, S_ERR_RESOURCE_NOT_OPEN);
    iassert(_mode <> EFileReadOnly, @self, 0, S_ERR_UNSUPPORTED_ACTION);
    blockWrite(_fileHandle, buffer^, count);
  end;

  procedure TFileStream.seek(pos: longint);
  begin
    iassert(_isOpen, @self, 0, S_ERR_RESOURCE_NOT_OPEN);
    System.seek(_fileHandle, pos);
  end;

  function TFileStream.getPosition: longint;
  begin
    getPosition := System.FilePos(_fileHandle);
  end;

  function TFileStream.isEOF: boolean;
  begin
    iassert(_isOpen, @self, 0, S_ERR_RESOURCE_NOT_OPEN);
    isEOF := EOF(_fileHandle);
  end;

  function TFileStream.isFileOpen: boolean;
  begin
    isFileOpen := _isOpen;
  end;

  function TFileStream.getSize: longint;
  begin
    iassert(_isOpen, @self, 0, S_ERR_RESOURCE_NOT_OPEN);
    getSize := System.FileSize(_fileHandle);
  end;

  function TFileStream.isReadOnly: boolean;
  begin
    isReadOnly := _mode = EFileReadOnly;
  end;

  function TFileStream.getFilePath: string;
  begin
    getFilePath := _filePath;
  end;

  function TFileStream.getClassName: string;
  begin
    getClassName := 'TFileStream';
  end;

  function TFileStream.getClassId: word;
  begin
    getClassId := C_CLASS_ID_FILESTREAM;
  end;

end.