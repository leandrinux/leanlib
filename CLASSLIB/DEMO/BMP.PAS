uses
  xcrt, types, utils, uexc, uobject, umsgs,
  udisplay, ubitmap, ucanvas, ufstream, ubmpfile;

var
  display: PDisplayAdapter;

{ --- Start custom exception manager }
type
  PExceptionMgr = ^TExceptionMgr;
  TExceptionMgr = object (TObject)
    procedure receiveMessage(msg: PObjectMessage); virtual;
  end;

procedure TExceptionMgr.receiveMessage(msg: PObjectMessage);
begin
  if (msg^.opcode = C_MSG_EXCEPTION) then
  begin
    display^.setTextMode;
    writeln('Error: ', PException(msg^.sender)^.getErrorMessage);
    beep;
  end;
end;

{ --- End custom exception manager }

const
  C_TEST_FILE = 'RES\CAPYBARA.BMP'; { full path to a 320x200x256 BMP file }

var
  fs: PFileStream;
  bmp: PBMPFile;
  image: PBitmap;

begin
  setExceptionHandler(new(PExceptionMgr, init));

  display := new(PDisplayAdapter, init);
  if not display^.detectAdapter then exit;
  display^.setVideoMode(0);

  fs := new(PFileStream, initWithPath(C_TEST_FILE, EFileReadOnly));
  bmp := new(PBMPFile, initWithStream(fs));
  image := bmp^.getBitmap;
  display^.setPalette(image^.getPalette);
  display^.getCanvas^.getBitmap^.merge(image, 0, 0);
  readkey;

  bmp^.release;
  fs^.release;

  display^.setTextMode;
  display^.release;
end.