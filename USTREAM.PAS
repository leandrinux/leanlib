{
  Stream Unit
  An abstract object representing a stream of data you can read or write.
  2022 LRT
}
unit
  ustream;

interface

  uses
    ascii, math, locale, utils,
    uobject, uclasses, uexc, umsgs;

  type
    PCopyProgressData = ^TCopyProgressData;
    TCopyProgressData = packed record
      copied: longint;
      remaining: longint;
    end;

    PStream = ^TStream;
    TStream = object (TObject)
    public
      function read(buffer: pointer; count: word): word; virtual;
      procedure write(buffer: pointer; count: word); virtual;
      procedure seek(pos: longint); virtual;
      procedure copyTo(stream: PStream; count: longint);
      procedure copyAllTo(stream: PStream);
      procedure writeln(line: string);
      procedure writestr(str: string);
      procedure writepchar(str: string);
      function readUntilChar(c: char): string;
      function readln: string;
      function readpchar: string;
      function getPosition: longint; virtual;
      function isEOF: boolean; virtual;
      function getSize: longint; virtual;
      function isReadOnly: boolean; virtual;
      function getChecksum: longint;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
    private
      procedure notifyCopyProgress(copied, remaining: longint);
    end;

implementation

  const
    C_COPY_BUFFER_SIZE = 16384;
    C_CHECKSUM_BUFFER_SIZE = 16384;

  { TStream public }

  function TStream.read(buffer: pointer; count: word): word;
  begin
    read := 0;
  end;

  procedure TStream.write(buffer: pointer; count: word); begin end;

  procedure TStream.seek(pos: longint); begin end;

  procedure TStream.copyTo(stream: PStream; count: longint);
  var
    buffer: pointer;
    result: word;
    copied, remaining: longint;
  begin
    iassert(not stream^.isReadOnly, @self, 0, S_ERR_TARGET_READ_ONLY);
    GetMem(buffer, C_COPY_BUFFER_SIZE);
    remaining := count;
    copied := 0;
    while remaining > 0 do
    begin
      count := minlong(C_COPY_BUFFER_SIZE, remaining);
      result := read(buffer, count);
      stream^.write(buffer, result);
      inc(copied, result);
      dec(remaining, count);
      notifyCopyProgress(copied, remaining);
    end;
    FreeMem(buffer, C_COPY_BUFFER_SIZE);
  end;

  procedure TStream.copyAllTo(stream: PStream);
  begin
    seek(0);
    { stream^.seek(0); }
    copyTo(stream, getSize);
  end;

  procedure TStream.writeln(line: string);
  const C_CRLF: array[0..1] of char = (C_CR, C_LF);
  begin
    write(incptr(@line, 1), length(line));
    write(@C_CRLF, 2);
  end;

  procedure TStream.writestr(str: string);
  begin
    write(incptr(@str, 1), length(str));
  end;

  procedure TStream.writepchar(str: string);
  const C_ZERO: byte = 0;
  begin
    if length(str) > 0 then 
      write(incptr(@str, 1), length(str));
    write(@C_ZERO, 1);
  end;

  function TStream.readUntilChar(c: char): string;
  var
    character: char;
    output: string;
    result: word;
  begin
    output := '';
    result := read(@character, 1);
    while (length(output)<255) and (result>0) and (character<>c)  do
    begin
      output := output + character;
      result := read(@character, 1);
    end;
    readUntilChar := output;
  end;

  function TStream.readln: string;
  begin
    readln := readUntilChar(C_LF);
  end;

  function TStream.readpchar: string;
  begin
    readpchar := readUntilChar(#0);
  end;

  function TStream.getPosition: longint;
  begin
    getPosition := 0;
  end;

  function TStream.isReadOnly: boolean;
  begin
    isReadOnly := false;
  end;

  function TStream.getChecksum: longint;
  var
    res: longint;
    totalRead: word;
    buffer, p: ^byte;
    i: word;
  begin
    seek(0);
    res := 0;
    GetMem(buffer, C_CHECKSUM_BUFFER_SIZE);
    while not isEOF do
    begin
      totalRead := read(buffer, C_CHECKSUM_BUFFER_SIZE);
      p := buffer;
      for i:= totalRead-1 downto 0 do
      begin
        system.write(byteToHex(p^), ' ');
        inc(res, p^);
        inc(p);
      end;
    end;
    FreeMem(buffer, C_CHECKSUM_BUFFER_SIZE);
    getChecksum := res;
  end;

  function TStream.isEOF: boolean;
  begin
    isEOF := true;
  end;

  function TStream.getSize: longint;
  begin
    getSize := 0;
  end;

  function TStream.getClassName: string;
  begin
    getClassName := 'TStream';
  end;

  function TStream.getClassId: word;
  begin
    getClassId := C_CLASS_ID_STREAM;
  end;

  { TStream private }

  procedure TStream.notifyCopyProgress(copied, remaining: longint);
  var
    msg: TObjectMessage;
    data: TCopyProgressData;
  begin
    if getDelegate = nil then exit;
    data.copied := copied;
    data.remaining := remaining;
    with msg do
    begin
      opcode := C_MSG_STREAM_COPY_PROGRESS;
      sender := @self;
      target := getDelegate;
      payload := @data;
      size := sizeOf(data);
    end;
    getDelegate^.receiveMessage(@msg);
  end;

end.