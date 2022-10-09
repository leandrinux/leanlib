{
  ufont Unit
  Abstract class representing graphic fonts that are later used to write
  text to a canvas
  2022 LRT
}
unit
  ufont;

interface

  uses
    consts, utils, uexc, uclasses, types, locale, uobject, ucanvas;

  type
    PFont = ^TFont;
    TFont = object (TObject)
    public
      constructor init;
      destructor done; virtual;
      procedure getCharSize(ch: char; scale: byte; var width, height: word); virtual;
      procedure drawChar(ch: char; scale: byte; x, y: word; canvas: PCanvas); virtual;
      function getName: string; virtual;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
    private
    end;

implementation

  { TFont public }

  constructor TFont.init;
  begin
    inherited init;
  end;

  destructor TFont.done;
  begin
    inherited done;
  end;

  procedure TFont.getCharSize(ch: char; scale: byte; var width, height: word);
  begin
    width := 0;
    height := 0;
  end;

  procedure TFont.drawChar(ch: char; scale: byte; x, y: word; canvas: PCanvas);
  begin
  end;

  function TFont.getName: string;
  begin
    getName := '';
  end;

  function TFont.getClassName: string;
  begin
    getClassName := 'TFont';
  end;

  function TFont.getClassId: word;
  begin
    getClassId := C_CLASS_ID_Font;
  end;

  { TFont private }

  { Other }

end.