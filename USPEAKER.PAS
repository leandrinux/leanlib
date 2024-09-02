{
  uspeaker Unit

  2022 LRT
}
unit
  uspeaker;

interface

  uses
    consts, utils, uexc, uclasses, types, locale, uobject, xcrt;

  type
    PTone = ^TTone;
    TTone = packed record
      samples: pword;
      sampleCount: byte;
      reverse: boolean;
    end;

    ETone = (
      EToneWah,
      EToneDing
    );

    PSpeaker = ^TSpeaker;
    TSpeaker = object (TObject)
    public
      constructor init;
      destructor done; virtual;
      procedure setTone(tone: ETone);
      procedure sound(hz: word);
      procedure silence;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
    private
      _tone: PTone;
      procedure play(hz: word);
    end;

implementation

const
  C_SAMPLE_DURATION = 3;

  C_TONE_WAH_SAMPLE_COUNT = 16;
  C_TONE_WAH_SAMPLES: array[0..C_TONE_WAH_SAMPLE_COUNT-1] of word = (
   500, 500, 500, 500, 500, 500, 500, 500,
   1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000
  );
  C_TONE_WAH: TTone = (
    samples: @C_TONE_WAH_SAMPLES;
    sampleCount: C_TONE_WAH_SAMPLE_COUNT;
    reverse: true
  );

  C_TONE_DING_SAMPLE_COUNT = 16;
  C_TONE_DING_SAMPLES: array[0..C_TONE_DING_SAMPLE_COUNT-1] of word = (
    2500, 1500, 1100, 600, 400, 300, 200, 250, 100, 70, 50, 40, 20, 15, 10, 5
  );
  C_TONE_DING: TTone = (
    samples: @C_TONE_DING_SAMPLES;
    sampleCount: C_TONE_DING_SAMPLE_COUNT;
    reverse: false
  );

  C_TONES : array[ETone] of PTone = (
    @C_TONE_WAH,
    @C_TONE_DING
  );

  { TSpeaker public }

  constructor TSpeaker.init;
  begin
    inherited init;
    _tone := C_TONES[ETone(0)];
  end;

  destructor TSpeaker.done;
  begin
    inherited done;
  end;

  procedure TSpeaker.setTone(tone: ETone);
  begin
    _tone := C_TONES[tone];
  end;

  procedure TSpeaker.sound(hz: word);
  begin
    play(hz);
  end;

  procedure TSpeaker.silence;
  begin
    nosound;
  end;

  function TSpeaker.getClassName: string;
  begin
    getClassName := 'TSpeaker';
  end;

  function TSpeaker.getClassId: word;
  begin
    getClassId := C_CLASS_ID_Speaker;
  end;

  { TSpeaker private }

  procedure TSpeaker.play(hz: word);
  var
    i: byte;
    p: pword;
    curr, prev: word;
  begin
    curr := $FFFF;
    with _tone^ do
    begin
      p := samples;
      for i:=0 to sampleCount-1 do
      begin
        prev := curr;
        curr := hz + p^;
        if prev <> curr then xcrt.sound(curr);
        delay(C_SAMPLE_DURATION);
        inc(p);
      end;
      if reverse then
        for i:=sampleCount-1 downto 0 do
        begin
          if prev <> curr then xcrt.sound(curr);
          delay(C_SAMPLE_DURATION);
          dec(p);
          prev := curr;
          curr := hz + p^;
        end;
    end;
  end;

  { Other }

end.