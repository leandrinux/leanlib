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
      constructor initWithPath(path: TFilePath; readOnly: boolean);
      destructor done; virtual;
      procedure read(buffer: pointer; count: word; var result: word); virtual;
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
      _isReadOnly: boolean;
    end;

implementation

  constructor TFileStream.initWithPath(path: TFilePath; readOnly: boolean);
  begin
    inherited init;
    _filePath := path;
    _isReadOnly := readOnly;
    assign(_fileHandle, path);
    {$I-}
    if readOnly then
    begin
      reset(_fileHandle, 1);
      iassert(IOResult = 0, @self, 0, S_ERR_FILE_NOT_FOUND);
    end else begin
      rewrite(_fileHandle, 1);
      iassert(IOResult = 0, @self, 0, S_ERR_FILE_COULDNT_BE_CREATED);
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

  procedure TFileStream.read(buffer: pointer; count: word; var result: word);
  begin
    result := 0;
    iassert(_isOpen, @self, 0, S_ERR_FILE_NOT_OPEN);
    blockRead(_fileHandle, buffer^, count, result);
  end;

  procedure TFileStream.write(buffer: pointer; count: word);
  begin
    iassert(_isOpen, @self, 0, S_ERR_FILE_NOT_OPEN);
    iassert(not _isReadOnly, @self, 0, S_ERR_UNSUPPORTED_ACTION);
    blockWrite(_fileHandle, buffer^, count);
  end;

  procedure TFileStream.seek(pos: longint);
  begin
    iassert(_isOpen, @self, 0, S_ERR_FILE_NOT_OPEN);
    System.seek(_fileHandle, pos);
  end;

  function TFileStream.getPosition: longint;
  begin
    getPosition := System.FilePos(_fileHandle);
  end;

  function TFileStream.isEOF: boolean;
  begin
    iassert(_isOpen, @self, 0, S_ERR_FILE_NOT_OPEN);
    isEOF := EOF(_fileHandle);
  end;

  function TFileStream.isFileOpen: boolean;
  begin
    isFileOpen := _isOpen;
  end;

  function TFileStream.getSize: longint;
  begin
    iassert(_isOpen, @self, 0, S_ERR_FILE_NOT_OPEN);
    getSize := System.FileSize(_fileHandle);
  end;

  function TFileStream.isReadOnly: boolean;
  begin
    isReadOnly := _isReadOnly;
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