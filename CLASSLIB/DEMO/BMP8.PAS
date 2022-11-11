uses 
  xcrt, types, ubitmap, ufstream, ubmpfile, udisplay, ulog, userial;

const
  C_BMP_PATH = 'RES\PATTERN.BMP';

procedure initLog;
var
  com: PSerial;
  log: PLog;
begin
  com := new(PSerial, initWithPort(COM2));
  log := new(PLog, initWithStream(com));
  log^.setAsDefault;
  log^.release;
  com^.release;
end;

procedure displayBitmap(bitmap: PBitmap);
var
  display: PDisplayAdapter;
begin
  display := new(PDisplayAdapter, init);
  display^.detectAdapter;
  display^.setVideoMode(0);
  display^.setPalette(bitmap^.getPalette);
  display^.getCanvas^.getBitmap^.merge(bitmap, 0, 0);
  readkey;
  display^.setTextMode;
  display^.release;
end;

var
  fs: PFileStream;
  bmp: PBMPFile;

begin
  initLog;
  fs := new(PFileStream, initWithPath(C_BMP_PATH, true));
  writeln('Loading bitmap ', C_BMP_PATH);
  bmp := new(PBMPFile, initWithStream(fs));
  writeln('File: ', C_BMP_PATH);
  writeln('Size: ', fs^.getSize);
  with bmp^.getInfo^ do
  begin
    writeln('BMP Info:');
    writeln('             size: ', size);
    writeln('       resolution: ', width, ' x ', height);
    writeln('           planes: ', planes);
    writeln('   bits per pixel: ', bitsPerPixel);
    writeln('      compression: ', compression);
    writeln('      colors used: ', colorsUsed);
  end; 
  if bmp^.isValid then 
  begin
    writeln('File is supported. Press key to display');
    readkey;
    displayBitmap(bmp^.getBitmap);
  end else 
  begin
    writeln('File is not supported');
    readkey;
  end;
  fs^.release;
  bmp^.release;
end.