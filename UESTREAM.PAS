{
  uestream Unit
  An EMS (expanded memory) stream implementation
  This requires an expanded memory card or an emulator such as EMM386.exe
  2022 LRT
}
unit
  uestream;

interface

  uses
    uexc, uclasses, types, locale, uobject, ustream, math;

  type
    PEMSStream = ^TEMSStream;
    TEMSStream = object (TStream)
    public
      constructor initWithSize(memorySize: longint);
      destructor done; virtual;
      function read(buffer: pointer; count: word): word; virtual;
      procedure write(buffer: pointer; count: word); virtual;
      procedure seek(pos: longint); virtual;
      function getPosition: longint; virtual;
      function isEOF: boolean; virtual;
      function getSize: longint; virtual;
      function getMaximumSize: longint;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
    private
      _size: longint;        { amount of memory reserved for the stream }
      _position: longint;    { current position }
      _pageCount: word;      { number of EMS memory 16k pages used }
      _handle: word;         { the EMS handle }
      _segmentAddr: word;    { position of the EMS window frame }
      _maxPosition: longint; { highest position ever accessed in the stream }

      { verifies that EMM calls return C_EMM_OK or else creates an exception }
      procedure assertErrorCode(code: byte);
    end;

implementation

  uses
    int67;

  { TEMSStream public }

  constructor TEMSStream.initWithSize(memorySize: longint);
  var
    freePages: word;
  begin
    inherited init;
    _size := memorySize;
    _position := 0;
    _maxPosition := 0;
    { verify that ems is available and we have enough memory pages }
    _pageCount := memorySize div C_EMM_PAGE_SIZE;
    if (memorySize mod C_EMM_PAGE_SIZE) > 0 then inc(_pageCount);
    iassert(EMM_isInstalled, @self, 0, S_ERR_EMS_NOT_PRESENT);
    iassert(EMM_freePages >= _pageCount, @self, 0, S_ERR_EMS_NOT_ENOUGH);
    { get the EMM frame segment address }
    assertErrorCode(EMM_FrameSegment(_segmentAddr));
    assertErrorCode(EMM_OpenHandle(_handle, _pageCount));
  end;

  destructor TEMSStream.done;
  begin
    EMM_CloseHandle(_handle);
    inherited done;
  end;

  function TEMSStream.read(buffer: pointer; count: word): word;
  var
    currentPage: word;
    currentPageOfs: word;
    frame: ^byte;
    remainingBytes: word;
    byteCount: word;
  begin
    remainingBytes := minlong(count, _size - _position);
    count := remainingBytes;
    currentPage := _position div C_EMM_PAGE_SIZE;
    while (currentPage < _pageCount) and (remainingBytes > 0) do
    begin
      currentPageOfs := _position mod C_EMM_PAGE_SIZE;
      assertErrorCode(EMM_MapPageToFrame(0, currentPage, _handle));
      frame := ptr(_segmentAddr, C_EMM_FRAME0_OFFSET);
      frame := incptr(frame, currentPageOfs);
      byteCount := minword(remainingBytes, C_EMM_PAGE_SIZE - currentPageOfs);
      Move(frame^, buffer^, byteCount);
      buffer := incptr(buffer, byteCount);
      dec(remainingBytes, byteCount);
      inc(_position, byteCount);
      _maxPosition := maxlong(_position, _maxPosition);
      currentPage := _position div C_EMM_PAGE_SIZE;
    end;
    read := count - remainingBytes;
  end;

  procedure TEMSStream.write(buffer: pointer; count: word);
  var
    currentPage: word;
    currentPageOfs: word;
    frame: ^byte;
    remainingBytes: word;
    byteCount: word;
    errorCode: byte;
  begin
    remainingBytes := minlong(count, _size - _position);
    currentPage := _position div C_EMM_PAGE_SIZE;
    while (currentPage < _pageCount) and (remainingBytes > 0) do
    begin
      currentPageOfs := _position mod C_EMM_PAGE_SIZE;
      assertErrorCode(EMM_MapPageToFrame(0, currentPage, _handle));
      frame := ptr(_segmentAddr, C_EMM_FRAME0_OFFSET);
      frame := incptr(frame, currentPageOfs);
      byteCount := minword(remainingBytes, C_EMM_PAGE_SIZE - currentPageOfs);
      Move(buffer^, frame^, byteCount);
      buffer := incptr(buffer, byteCount);
      dec(remainingBytes, byteCount);
      inc(_position, byteCount);
      _maxPosition := maxlong(_maxPosition, _position);
      currentPage := _position div C_EMM_PAGE_SIZE;
    end;
  end;

  procedure TEMSStream.seek(pos: longint);
  begin
    _position := pos;
    _maxPosition := maxlong(_maxPosition, _position);
  end;

  function TEMSStream.getPosition: longint;
  begin
    getPosition := _position;
  end;

  function TEMSStream.isEOF: boolean;
  begin
    isEOF := _position = _maxPosition;
  end;

  function TEMSStream.getSize: longint;
  begin
    getSize := _maxPosition;
  end;

  function TEMSStream.getMaximumSize: longint;
  begin
    getMaximumSize := _size;
  end;

  function TEMSStream.getClassName: string;
  begin
    getClassName := 'TEMSStream';
  end;

  function TEMSStream.getClassId: word;
  begin
    getClassId := C_CLASS_ID_MemoryStream;
  end;

  { TEMSStrem private }

  procedure TEMSStream.assertErrorCode(code: byte);
  begin
    iassert(code = C_EMM_OK, @self, code, S_ERR_EMS_ERROR);
  end;

  { Other }

end.