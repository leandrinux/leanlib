{
  uansiw Unit
  2022 LRT
}
unit
  uansiw;

interface

  uses
    consts, utils, uexc, uclasses, types, locale, uobject, ustream,
    ascii, strings;

  type
    EAnsiColor = (
      fgBlack,
      fgRed,
      fgGreen,
      fgYellow,
      fgBlue,
      fgMagenta,
      fgCyan,
      fgWhite,
      bgBlack,
      bgRed,
      bgGreen,
      bgYellow,
      bgBlue,
      bgMagenta,
      bgCyan,
      bgWhite,
      none,
      bold
    );

    EAnsiDirection = (
      up,
      down,
      right,
      left
    );

    PAnsiWriter = ^TAnsiWriter;
    TAnsiWriter = object (TStream)
    public
      constructor initWithStream(stream: PStream);
      destructor done; virtual;
      function read(buffer: pointer; count: word): word; virtual;
      procedure write(buffer: pointer; count: word); virtual;
      procedure seek(pos: longint); virtual;
      procedure clear;
      procedure gotoxy(x, y: byte);
      procedure setColor(color: EAnsiColor);
      procedure showCursor;
      procedure hideCursor;
      procedure move(direction: EAnsiDirection; n: byte);
      procedure setEnabled(enabled: boolean);
      function getPosition: longint; virtual;
      function isEOF: boolean; virtual;
      function getSize: longint; virtual;
      function isReadOnly: boolean; virtual;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
    private
      _stream: PStream;
      _enabled: boolean;
    end;

implementation

  const
    C_ANSI_COLORS : array [EAnsiColor] of byte = (
      30, 31, 32, 33, 34, 35, 36, 37,
      40, 41, 42, 43, 44, 45, 46, 47,
      0, 1
    );

    C_ANSI_DIRECTION : array [EAnsiDirection] of char = (
      'A', 'B', 'C', 'D'
    );

  { TAnsiWriter public }

  constructor TAnsiWriter.initWithStream(stream: PStream);
  begin
    inherited init;
    _stream := stream;
    _stream^.retain;
    _enabled := true;
  end;

  destructor TAnsiWriter.done;
  begin
    _stream^.done;
    inherited done;
  end;

  function TAnsiWriter.read(buffer: pointer; count: word): word;
  begin
    iassert(false, @self, 0, S_ERR_UNSUPPORTED_ACTION);
  end;

  procedure TAnsiWriter.write(buffer: pointer; count: word);
  begin
    _stream^.write(buffer, count);
  end;

  procedure TAnsiWriter.seek(pos: longint);
  begin
    iassert(false, @self, 0, S_ERR_UNSUPPORTED_ACTION);
  end;

  procedure TAnsiWriter.clear;
  begin
    if not _enabled then exit;
    _stream^.writestr(C_ESC + '[2J');
  end;

  procedure TAnsiWriter.gotoxy(x, y: byte);
  begin
    if not _enabled then exit;
    _stream^.writestr(C_ESC + '[' + inttostr(y) + ';' + inttostr(x) + 'H' );
  end;

  procedure TAnsiWriter.setColor(color: EAnsiColor);
  begin
    if not _enabled then exit;
    _stream^.writestr(C_ESC + '[' + inttostr(C_ANSI_COLORS[color]) + 'm');
  end;

  procedure TAnsiWriter.showCursor;
  begin
    if not _enabled then exit;
    _stream^.writestr(C_ESC + '[?25h');
  end;

  procedure TAnsiWriter.hideCursor;
  begin
    if not _enabled then exit;
    _stream^.writestr(C_ESC + '[?25l');
  end;

  procedure TAnsiWriter.move(direction: EAnsiDirection; n: byte);
  begin
    if not _enabled then exit;
    _stream^.writestr(C_ESC + '[' + inttostr(n) + C_ANSI_DIRECTION[direction]);
  end;

  procedure TAnsiWriter.setEnabled(enabled: boolean);
  begin
    _enabled := enabled;
  end;

  function TAnsiWriter.getPosition: longint;
  begin
    iassert(false, @self, 0, S_ERR_UNSUPPORTED_ACTION);
  end;

  function TAnsiWriter.isEOF: boolean;
  begin
    iassert(false, @self, 0, S_ERR_UNSUPPORTED_ACTION);
  end;

  function TAnsiWriter.getSize: longint;
  begin
    iassert(false, @self, 0, S_ERR_UNSUPPORTED_ACTION);
  end;

  function TAnsiWriter.isReadOnly: boolean;
  begin
    isReadOnly := false;
  end;

  function TAnsiWriter.getClassName: string;
  begin
    getClassName := 'TAnsiWriter';
  end;

  function TAnsiWriter.getClassId: word;
  begin
    getClassId := C_CLASS_ID_AnsiWriter;
  end;

  { TAnsiWriter private }

  { Other }

end.