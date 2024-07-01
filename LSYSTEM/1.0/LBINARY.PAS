{
  This unit is in charge of storing all binary info
  related to the build, including the code and also the data.
}
unit
  lbinary;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc,
    lcommon, lcbase;

  const
    C_CLASS_ID_Binary = $F012;

  type
    EMetadataKey = (
      EMetadataKeyName,
      EMetadataKeyAuthor,
      EMetadataKeyCompany,
      EMetadataKeyBuildTimestamp,
      EMetadataKeyDescription,
      EMetadataKeyOther
    );

    TMetadataEntry = string[100];

    PBinary = ^TBinary;
    TBinary = object (TObject)
    public
      constructor init;
      destructor done; virtual;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
      procedure addSentence(const sentence: TSentence);
      procedure addData(data: pointer; size: longint);
      procedure addMetadata(const key: EMetadataKey; const value: TMetadataEntry);
      procedure save(const filename: string);
    private
    end;

implementation

  { TBinary public }

  constructor TBinary.init;
  begin
    inherited init;
  end;

  destructor TBinary.done;
  begin
    inherited done;
  end;

  function TBinary.getClassName: string;
  begin
    getClassName := 'TBinary';
  end;

  function TBinary.getClassId: word;
  begin
    getClassId := C_CLASS_ID_Binary;
  end;

  procedure TBinary.addSentence(const sentence: TSentence);
  begin
  end;

  procedure TBinary.addData(data: pointer; size: longint);
  begin
  end;

  procedure TBinary.addMetadata(const key: EMetadataKey; const value: TMetadataEntry);
  begin
  end;

  procedure TBinary.save(const filename: string);
  begin
  end;

  { TBinary private }

  { Other }

end.
