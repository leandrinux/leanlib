{
  GFactory Unit

  2022 LRT
}
unit
  GFactory;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc, udict, 
    gclasses, gtypes, gcontrol, gpanel;

  type
    PControlFactory = ^TControlFactory;
    TControlFactory = object (TObject)
    public
      { constructors and destructors}
      constructor init;
      destructor done; virtual;
      { extended methods }
      function getClassName: string; virtual;
      function getClassId: word; virtual;
      { methods }
      function build(data: PDictionary): PControl;
    private
      function buildPanel(data: PDictionary): PPanel;
    end;

implementation

  { TControlFactory public }

  constructor TControlFactory.init;
  begin
    inherited init;
  end;

  destructor TControlFactory.done;
  begin
    inherited done;
  end;

  function TControlFactory.getClassName: string;
  begin
    getClassName := 'TControlFactory';
  end;

  function TControlFactory.getClassId: word;
  begin
    getClassId := C_CLASS_ID_ControlFactory;
  end;

  function TControlFactory.build(data: PDictionary): PControl;
  var
    id: TControlId;
  begin
    id := data^.getString('type');
    if id = C_CONTROL_TYPE_PANEL then 
      build := buildPanel(data)
    else
      raise(@self, 0, S_ERR_UNEXPECTED_TYPE);
  end;

  { TControlFactory private }

  function TControlFactory.buildPanel(data: PDictionary): PPanel;
  begin
    
  end;

  { Other }

end.
