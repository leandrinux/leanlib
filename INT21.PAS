{
  INT 21 - DOS Function Dispatcher
  Built with info from https://stanislavs.org/helppc/int_21.html
  2022 LRT
}
unit
  int21;

interface

  uses
    datetime;

  const

    { DOS error codes }
    C_DOS_ERROR_NONE                            = $00;
    C_DOS_ERROR_INVALID_FUNCTION                = $01;
    C_DOS_ERROR_FILE_NOT_FOUND                  = $02;
    C_DOS_ERROR_PATH_NOT_FOUND                  = $03;
    C_DOS_ERROR_TOO_MANY_OPEN_FILES             = $04;
    C_DOS_ERROR_ACCESS_DENIED                   = $05;
    C_DOS_ERROR_INVALID_HANDLE                  = $06;
    C_DOS_ERROR_MEMORY_CONTROL_BLOCKS_DESTROYED = $07;
    C_DOS_ERROR_INSUFFICIENT_MEMORY             = $08;
    C_DOS_ERROR_INVALID_MEMORY_BLOCK_ADDRESS    = $09;
    C_DOS_ERROR_INVALID_ENVIRONMENT             = $0A;
    C_DOS_ERROR_INVALID_FORMAT                  = $0B;
    C_DOS_ERROR_INVALID_ACCESS_MODE             = $0C;
    C_DOS_ERROR_INVALID_DATA                    = $0D;
    C_DOS_ERROR_INVALID_DRIVE_SPECIFIED         = $0F;
    C_DOS_ERROR_ATTEMPT_TO_REMOVE_CURRENT_DIR   = $10;
    C_DOS_ERROR_NOT_SAME_DEVICE                 = $11;
    C_DOS_ERROR_NO_MORE_FILES                   = $12;
    C_DOS_ERROR_WRITE_PROTECTED                 = $13;
    C_DOS_ERROR_UNKNOWN_UNIT                    = $14;
    C_DOS_ERROR_DRIVE_NOT_READY                 = $15;
    C_DOS_ERROR_UNKNOWN_COMMAND                 = $16;
    C_DOS_ERROR_CRC_ERROR                       = $17;
    C_DOS_ERROR_BAD_REQUEST_STRUCTURE_LENGTH    = $18;
    C_DOS_ERROR_SEEK_ERROR                      = $19;
    C_DOS_ERROR_UNKNOWN_MEDIA_TYPE              = $1A;
    C_DOS_ERROR_SECTOR_NOT_FOUND                = $1B;
    C_DOS_ERROR_PRINTER_OUT_OF_PAPER            = $1C;
    C_DOS_ERROR_WRITE_FAULT                     = $1D;
    C_DOS_ERROR_READ_FAULT                      = $1E;
    C_DOS_ERROR_GENERAL_FAILURE                 = $1F;
    C_DOS_ERROR_SHARING_VIOLATION               = $20;
    C_DOS_ERROR_LOCK_VIOLATION                  = $21;
    C_DOS_ERROR_INVALID_DISK_CHANGE             = $22;
    C_DOS_ERROR_FCB_UNAVAILABLE                 = $23;
    C_DOS_ERROR_SHARING_BUFFER_OVERFLOW         = $24;
    C_DOS_ERROR_UNABLE_TO_COMPLETE_FILE_OP      = $26;
    C_DOS_ERROR_NETWORK_REQUEST_NOT_SUPPORTED   = $32;
    C_DOS_ERROR_REMOTE_COMPUTER_NOT_LISTENING   = $33;
    C_DOS_ERROR_DUPLICATE_NAME_ON_NETWORK       = $34;
    C_DOS_ERROR_NETWORK_NAME_NOT_FOUND          = $35;
    C_DOS_ERROR_NETWORK_BUSY                    = $36;
    C_DOS_ERROR_NETWORK_DEVICE_DOESNT_EXIST     = $37;
    C_DOS_ERROR_NETBIOS_COMMAND_LIMIT_EXCEEDED  = $38;
    C_DOS_ERROR_NETWORK_ADAPTER_ERROR           = $39;
    C_DOS_ERROR_INCORRECT_NETWORK_RESPONSE      = $3A;
    C_DOS_ERROR_UNEXPECTED_NETWORK_ERROR        = $3B;
    C_DOS_ERROR_INCOMPATIBLE_REMOTE_ADAPTER     = $3C;
    C_DOS_ERROR_PRINT_QUEUE_FULL                = $3D;
    C_DOS_ERROR_NO_SPACE_FOR_PRINT_FILE         = $3E;
    C_DOS_ERROR_PRINT_FILE_DELETED              = $3F;
    C_DOS_ERROR_NETWORK_NAME_DELETED            = $40;
    C_DOS_ERROR_NETWORK_ACCESS_DENIED           = $41;
    C_DOS_ERROR_NETWORK_DEVICE_TYPE_INCORRECT   = $42;
    C_DOS_ERROR_NETWORK_NAME_NOT_FOUND_2        = $43;
    C_DOS_ERROR_NETWORK_NAME_LIMIT_EXCEEDED     = $44;
    C_DOS_ERROR_NETBIOS_SESSION_LIMIT_EXCEEDED  = $45;
    C_DOS_ERROR_TEMPORARILY_PAUSED              = $46;
    C_DOS_ERROR_NETWORK_REQUEST_NOT_ACCEPTED    = $47;
    C_DOS_ERROR_PRINT_OR_DISK_REDIRECTION_PAUSE = $48;
    C_DOS_ERROR_FILE_ALREADY_EXISTS             = $50;
    C_DOS_ERROR_CANNOT_MAKE_DIRECTORY_ENTRY     = $52;
    C_DOS_ERROR_FAIL_ON_INT_24                  = $53;
    C_DOS_ERROR_TOO_MANY_REDIRECTIONS           = $54;
    C_DOS_ERROR_DUPLICATE_REDIRECTION           = $55;
    C_DOS_ERROR_INVALID_PASSWORD                = $56;
    C_DOS_ERROR_INVALID_PARAMETER               = $57;
    C_DOS_ERROR_NETWORK_DEVICE_FAULT            = $58;
    C_DOS_ERROR_FUNCTION_NOT_SUPPORTED_BY_NET   = $59;
    C_DOS_ERROR_REQUIRED_COMPONENT_MISSING      = $5A;

    { file attribute masks }
    C_FILE_ATTR_NORMAL    = 0;
    C_FILE_ATTR_READONLY  = 1;
    C_FILE_ATTR_HIDDEN    = 2;
    C_FILE_ATTR_SYSTEM    = 4;
    C_FILE_ATTR_LABEL     = 8;
    C_FILE_ATTR_DIRECTORY = 16;
    C_FILE_ATTR_ARCHIVE   = 32;

    { timestamp component masks }
    C_TIME_FORMAT_SECS_MASK  = $001F;
    C_TIME_FORMAT_MIN_MASK   = $07E0;
    C_TIME_FORMAT_HOUR_MASK  = $F800;
    C_DATE_FORMAT_DAY_MASK   = $001F;
    C_DATE_FORMAT_MONTH_MASK = $01E0;
    C_DATE_FORMAT_YEAR_MASK  = $FE00;

  type

    {
      The DTA is a structure used to perform searches in the file system,
      get the list of files in a directory, etc.
    }
    PDiskTransferAddress = ^TDiskTransferAddress;
    TDiskTransferAddress = packed record
      searchAttribute       : byte;
      searchDrive           : byte;
      searchSpec            : array[0..10] of char;
      directoryEntryNumber  : word;
      startingCluster3x     : word;
      reserved              : word;
      startingCluster2x     : word;
      matchingFileAttribute : byte;
      fileTime              : word;
      fileDate              : word;
      fileSize              : longint;
      fileName              : array[0..12] of char;
    end;

  { *** int 21h services ************************************************** }

  { sets the Disk Transfer Address block }
  procedure setDiskTransferAddress(dta: PDiskTransferAddress);

  { returns a pointer to the Disk Transfer Address block }
  function getDiskTransferAddress: PDiskTransferAddress;

  {
    sets the current drive (zero based, 0 to 25, A: to Z:)
    returns the total number of logical drives (one based count)
  }
  function setCurrentDrive(drive: byte): byte;

  { returns the current default drive (zero based, 0 to 25, A: to Z:) }
  function getCurrentDrive: byte;

  {
    changes the current directory (cd command)
    returns a DOS error code
  }
  function setDirectory(path: PChar): word;

  {
    returns the full path of the current directory
    buffer is a pointer to a 64 byte buffer for a null-terminated string
    returns a DOS error code
  }
  function getDirectory(drive: byte; buffer: PChar): word;

  {
    receives a null-terminated string containing a file specification
    such as *.* or *.BMP, and a set of attributes (like C_FILE_ATTR_NORMAL
    or C_FILE_ATTR_DIRECTORY, and returns information for the first file
    that fits the criteria. This information is stored in the current
    DTA (Disk Transfer Address). The function returns a DOS error code.
  }
  function findFirstMatchingFile(attr: word; spec: PChar): word;

  {
    Uses the file specification pointed by spec and the information stored
    in the DTA to find the next file that complies with the previously
    defined criteria. The new data is written to the DTA. The function
    returns a DOS error code
  }
  function findNextMatchingFile(spec: PChar): word;

  { *** useful functions ************************************************** }

  {
    changes the current directory, moving up to its parent directory
    returns a DOS error code
  }
  function setParentDirectory: word;

  {
    changes the current directory up to the root
    returns a DOS error code
  }
  function setRootDirectory: word;

  {
    converts a DOS file date to a TDate structure
  }
  procedure fileDateToDate(fileDate: word; var date: TDate);

implementation

  procedure setDiskTransferAddress(dta: PDiskTransferAddress);
  begin
    asm
      push ds
      mov dx, word ptr dta + 2
      mov ds, dx
      mov dx, word ptr dta
      mov ah, $1A
      int $21
      pop ds
    end;
  end;

  function GetDiskTransferAddress: PDiskTransferAddress;
  var
    segm, offs: word;
  begin
    asm
      mov ah, $2f
      int $21
      mov segm, es
      mov offs, bx
    end;
    GetDiskTransferAddress := Ptr(segm, offs);
  end;

  function setCurrentDrive(drive: byte): byte;
  var
    count: byte;
  begin
    asm
      mov dl, drive
      mov ah, $0E
      int $21
      mov count, al
    end;
    setCurrentDrive := count;
  end;

  function getCurrentDrive: byte;
  var
    drive: byte;
  begin
    asm
      mov ah, $19
      int $21
      mov drive, al
    end;
    GetCurrentDrive := drive;
  end;

  function setDirectory(path: PChar): word;
  var code: word;
  begin
    asm
      push ds
      mov dx, word ptr path + 2
      mov ds, dx            { ds equals segment in pointer }
      mov dx, word ptr path { dx equals offset in pointer }
      mov ah, $3b { Change Current Directory }
      int $21
      pop ds
      mov code, ax
    end;
    SetDirectory := code;
  end;

  function setParentDirectory: word;
  const
    C_PARENT_DIRECTORY: array[0..2] of char = '..' + #0;
  begin
    SetParentDirectory := SetDirectory(@C_PARENT_DIRECTORY);
  end;

  function SetRootDirectory: word;
  const
    C_ROOT_DIRECTORY: array[0..1] of char = '\' + #0;
  begin
    SetRootDirectory := SetDirectory(@C_ROOT_DIRECTORY);
  end;

  function getDirectory(drive: byte; buffer: PChar): word;
  var
    len: byte;
    value: word;
  begin
    asm
      push ds        { save data segment }
      mov ax, word ptr buffer + 2
      mov ds, ax     { ds = segment of buffer to store null-term output }
      mov si, word ptr buffer { si = offset of buffer }
      mov dl, drive  { dl = drive number (0=current, 1=A:, 2=B:...) }
      mov ah, $47    { al = 47h (get current directory) }
      int $21        { call service }
      pop ds         { restore data segment }
      mov value, ax  { gets DOS error code }
    end;
    getDirectory := value;
  end;

  function findFirstMatchingFile(attr: word; spec: PChar): word;
  var code: word;
  begin
    asm
      push ds             { saves data segment }

      mov dx, word ptr spec + 2
      mov ds, dx          { data segment equal to segment in pointer  }

      mov dx, word ptr spec { dx equal to offset in pointer }

      mov cx, attr        { cx equal to search attributes }
      mov ah, $4E
      int $21             { call DOS service }
      pop ds              { restores data segment }
      mov code, ax
    end;
    findFirstMatchingFile := code;
  end;

  function findNextMatchingFile(spec: PChar): word;
  var code: word;
  begin
    asm
      push ds             { saves data segment }

      mov dx, word ptr spec + 2
      mov ds, dx          { data segment equal to segment in pointer  }

      mov dx, word ptr spec { dx equal to offset in pointer }

      mov ah, $4F
      int $21             { call DOS service }
      pop ds              { restores data segment }
      mov code, ax
    end;
    FindNextMatchingFile := code;
  end;

  procedure fileDateToDate(fileDate: word; var date: TDate);
  begin
    date.day := fileDate and C_DATE_FORMAT_DAY_MASK;
    date.month := (fileDate and C_DATE_FORMAT_MONTH_MASK) shr 5;
    date.year := 1980 + (fileDate and C_DATE_FORMAT_YEAR_MASK) shr 9;
    date.weekday := $FFFF;
  end;

end.