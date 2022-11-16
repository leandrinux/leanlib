uses 
  xcrt, types, ubitmap, ufstream, ubmpfile, udisplay, ucomlog;

const
  C_BMP_PATH = 'RES\mini.BMP';

procedure displayBitmap(bitmap: PBitmap);
var
  display: PDisplayAdapter;
  cx, cy: word;
begin
  display := new(PDisplayAdapter, init);
  display^.detectAdapter;
  display^.setVideoMode(0);
  display^.setPalette(bitmap^.getPalette);
  cx := 160 - (bitmap^.getWidth div 2);
  cy := 100 - (bitmap^.getHeight div 2);
  display^.getCanvas^.getBitmap^.merge(bitmap, cx, cy);
  readkey;
  display^.setTextMode;
  display^.release;
end;

var
  fs: PFileStream;
  bmp: PBMPFile;

begin
  comlog('Hello World');
  fs := new(PFileStream, initWithPath(C_BMP_PATH, true));
  writeln('Loading bitmap ', C_BMP_PATH);
  bmp := new(PBMPFile, initWithStream(fs));
  writeln;
  writeln('   Total file size: ', fs^.getSize);
  with bmp^.getInfo^ do
  begin
    writeln('      file version: ', bmp^.getVersion);
    writeln(' pixel data offset: ', bmp^.getHeader^.pixelDataOffset);
    writeln('   info block size: ', infoHeaderSize);
    writeln('        resolution: ', width, ' x ', height);
    writeln('            planes: ', planes);
    writeln('    bits per pixel: ', bitsPerPixel);
    writeln('       compression: ', compression);
    writeln('        image size: ', imageSize);
    writeln('       colors used: ', colorsUsed);
    writeln;
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