{
  INT 67 - Expanded Memory Specification
  Built with info from https://stanislavs.org/helppc/int_67.html
  http://www.techhelpmanual.com/651-emm_functions.html
  For extra info please check the bottom of this file
  2022 LRT
}
unit
  int67;

interface

  const
    { basic status codes }
    C_EMM_OK                   = 0;
    C_EMM_INTERNAL_ERROR       = $80;
    C_EMM_HARDWARE_ERROR       = $81;
    C_EMM_BUSY                 = $82;
    C_EMM_INVALID_HANDLE       = $83;
    C_EMM_UNDEFINED_FUNCTION   = $84;
    C_EMM_NO_MORE_HANDLES      = $85;
    C_EMM_ERROR_SAVE_RESTORE   = $86;
    C_EMM_ALLOC_LARGER_TOTAL   = $87;
    C_EMM_ALLOC_LARGER_PAGES   = $88;
    C_EMM_INVALID_PAGE_COUNT   = $89;
    C_EMM_INVALID_NUMBER_PAGES = $8A;
    C_EMM_ILLEGAL_MAPPING      = $8B;
    C_EMM_SAVE_AREA_FULL       = $8C;
    C_EMM_SAVE_ONCE_PER_HANDLE = $8D;
    C_EMM_CANT_RESTORE_WO_SAVE = $8E;
    C_EMM_FUNCTION_ARG_UNDEF   = $8F;

    { EMS 4.0 codes }
    C_EMM_ATTR_TYPE_UNDEF      = $90;
    C_EMM_NONVOLATILITY_UNSUP  = $91;
    C_EMM_SRC_DST_OVERLAP      = $92;
    C_EMM_DEST_AREA_TOO_SMALL  = $93;
    C_EMM_CONV_MEM_OVERLAP_EMS = $94;
    C_EMM_OFFSET_TOO_LARGE     = $95;
    C_EMM_BLOCKSIZE_TOO_LARGE  = $96;
    C_EMM_SRC_DST_HDLE_OVERLAP = $97;
    C_EMM_SRC_DST_TYPE_INVALID = $98;
    C_EMM_ALT_MAP_REG_UNSUPP   = $9A;
    C_EMM_ALL_REG_SETS_ALLOC   = $9B;
    C_EMM_ALL_REG_SETS_UNSUPP  = $9C;
    C_EMM_ALT_REG_USED_OR_INV  = $9D;
    C_EMM_DEDICATED_DMA_UNSUPP = $9E;
    C_EMM_DMA_CHANNEL_UNSUPP   = $9F;
    C_EMM_NO_HANDLES_W_NAME    = $A0;
    C_EMM_NAME_ALREADY_EXISTS  = $A1;
    C_EMM_SRC_OFF_REG_LARGE    = $A2;
    C_EMM_PACKET_CONTENT_INV   = $A3;
    C_EMM_ACCESS_DENIED        = $A4;

    C_EMM_PAGE_SIZE       = $4000;
    C_EMM_FRAME0_OFFSET   = $0000;
    C_EMM_FRAME1_OFFSET   = $4000;
    C_EMM_FRAME2_OFFSET   = $8000;
    C_EMM_FRAME3_OFFSET   = $C000;

  {
    Obtain the current status of the Expanded Memory Manager.
    Use this only after establishing the presence of EMM support
  }
  function EMM_Status: byte;

  {
    Obtains the segment at which the EMS frame is mapped.

    The EMS frame is a 64K area, often starting at d000:0.  Depending
    upon switches used when the driver is installed, the frame may
    actually start at any segment address from 8000H to 9000H (seen
    rarely) and c000H through e000H in increments of 400H.
    When you read or write to EMS memory, you will use INT 67H 4000H
    to map part of the EMS into this frame, then read or write to the
    64K starting at the segment returned in BX.
  }
  function EMM_FrameSegment(var segAddr: word): byte;

  {
    Obtains the total amount of EMS memory that is supported and the
    amount that is currently available.
  }
  function EMM_TotalMemory(var total, available: word): byte;

  {
    Allocates EMS memory.

    The handle returned in DX is used in subsequent calls to map the
    EMS into the page frame and other operations.
  }
  function EMM_OpenHandle(var handle: word; pages: word): byte;

  {
    Release memory allocated via INT 67H 4300H and makes the DX
    handle invalid for future calls.
  }
  function EMM_CloseHandle(handle: word): byte;

  {
    This moves the data associated with a particular 16K page of EMS
    memory into the physical frame (making that memory accessible).
    For instance, assuming that the page frame starts at d000:0, then
    calling this with AX=4401H will put the BXth page of your
    allocation into d000:0400.
    BX is the desired page of EMS memory.  It can range from 0 to n-1,
    where n is the size of the allocation (as used in INT 67H 4300H).
    With EMS spec 4.0, you can set BX=ffffH to unmap a 16K portion of
    the EMS frame.  For instance, if AX=4401H and BX=ffffH, then the
    data from EmsSeg:0400 through EmsSeg:07ff will be locked into
    place and cannot be read or written.  To remap a page, use the
    same parameters, specifying a valid logical page number in BX.
    Notes: You may remap only one 16K page at a time with this fn.  You may
    prefer INT 67H 50xxH to map multiple pages.
    Page size: 4000h (16KB, 16384 bytes)
    Frame addresses:
    0: 0000h - 3FFFh
    1: 4000h - 7FFFh
    2: 8000h - BFFFh
    3: C000h - FFFFh
  }
  function EMM_MapPageToFrame(physicalPage: byte; logicalPage: word; handle: word): byte;

  {
    Use this to ensure that the installed version supports any
    special features you wish to access.

    Notes: EMM 4.0 has been standard since 1987 and it is usually quite safe
    to assume 4.0 is present.  Furthermore, in most cases, you can
    get by without using any of the features unique to 4.0.
  }
  function EMM_Version(var version: byte): byte;

  {
    EMS 4.0+
    Resizes a handle, allowing to expand or shrink the number of pages
    requested. When increasing the number of handles, the data on the
    previous pages remains untouched.
  }
  function EMM_ResizeHandle(handle: word; pages: word): byte;

  {
    Some convenience functions to make this a little friendlier to use
  }
  function EMM_IsInstalled: boolean;

  function EMM_FreePages: word;

implementation

  function EMM_Status: byte;
  var
    _status: byte;
  begin
    asm
      mov ax, 4000h
      int 67h
      mov _status, ah
    end;
    EMM_Status := _status;
  end;

  function EMM_FrameSegment(var segAddr: word): byte;
  var
    _status: byte;
    _segAddr: word;
  begin
    asm
      mov ax, 4100h
      int 67h
      mov _status, ah
      mov _segAddr, bx
    end;
    EMM_FrameSegment := _status;
    segAddr := _segAddr;
  end;

  function EMM_TotalMemory(var total, available: word): byte;
  var
    _status: byte;
    _total: word;
    _available: word;
  begin
    asm
      mov ax, 4200h
      int 67h
      mov _status, ah
      mov _total, dx
      mov _available, bx
    end;
    EMM_TotalMemory := _status;
    total := _total;
    available := _available;
  end;

  function EMM_OpenHandle(var handle: word; pages: word): byte;
  var
    _status: byte;
    _handle: word;
  begin
    asm
      mov ax, 4300h
      mov bx, pages
      int 67h
      mov _status, ah
      mov _handle, dx
    end;
    EMM_OpenHandle := _status;
    handle := _handle;
  end;

  function EMM_CloseHandle(handle: word): byte;
  var
    _status: byte;
  begin
    asm
      mov ax, 4500h
      mov dx, handle
      int 67h
      mov _status, ah
    end;
    EMM_CloseHandle := _status;
  end;

  function EMM_MapPageToFrame(physicalPage: byte; logicalPage: word; handle: word): byte;
  var
    _status: byte;
  begin
    asm
      mov ah, 44h
      mov al, physicalPage
      mov bx, logicalPage
      mov dx, handle
      int 67h
      mov _status, ah
    end;
    EMM_MapPageToFrame := _status;
  end;

  function EMM_Version(var version: byte): byte;
  var
    _status: byte;
    _version: byte;
  begin
    asm
      mov ax, 4600h
      int 67h
      mov _status, ah
      mov _version, al
    end;
    EMM_Version := _status;
    version := _version;
  end;

  function EMM_ResizeHandle(handle: word; pages: word): byte;
  var
    status: byte;
  begin
    asm
      mov ax, $5100
      mov bx, pages
      mov dx, handle
      int $67
      mov status, ah
    end;
    EMM_ResizeHandle := status;
  end;

  function EMM_IsInstalled: boolean;
  const
    C_EXPECTED_DRIVER_NAME = 'EMMXXXX0';
  type
    TDeviceName = array[1..8] of char;
  var
    p: pointer;
  begin
    p := pointer(Ptr(0, $019c)^); { gets pointer to interrupt $67 handler 0000:$67*4 }
    p := Ptr(Seg(p^), $0A);       { offset $0A contains the driver device name }
    EMM_isInstalled := TDeviceName(p^) = C_EXPECTED_DRIVER_NAME;
  end;

  function EMM_FreePages: word;
  var
    total, available: word;
  begin
    if EMM_TotalMemory(total, available) = C_EMM_OK then
      EMM_freePages := available
    else
      EMM_freePages := 0;
  end;

end.

{
  This unit allows you to store data beyond conventional memory.
  It requires expanded memory which, in really old times, consisted of
  separate extension boards of memory that you physically connected in a
  expansion slot in the same way you would add a video card. In newer
  computers this is obtained thanks to EMM386 or similar drivers. EMM386
  emulates expanded memory by using extended memory, which is a completely
  different thing.

  There is a segment, that you obtain via EMM_FrameSegment, which becomes your
  point of access to that memory. This segment is divided in four frames, 16KB
  each. What you do is, you open a handle and tell EMM386 how many pages you
  need (a page is also 16KB). For instance, if you need 5MB (5120KB) you would
  ask for 320 pages. Then you simply ask to load page 0 into any of those
  frames, for instance, frame 0. You can load a completely different page in
  another frame, for instance page 300 in frame 3 (as you see, there aren't more
  than 4 frames, from 0 to 3). You read and write to this memory using pointers
  as usual and changing the content in those frames. When you're done, you close
  the frame. If you keep it open, later other programs might find out that there
  isn't enough memory and you would have to reboot the computer.
}
