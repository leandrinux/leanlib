{
  GFactory Unit

  2022 LRT
}
unit
  GFactory;

interface

  uses
    consts, utils, uclasses, types, locale,
    uobject, uexc, udict, ulist,
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
      function create(data: PDictionary): PControl;
    private
      function createPanel(data: PDictionary): PPanel;
      procedure initControl(control: PControl; data: PDictionary);
      procedure initPanel(panel: PPanel; data: PDictionary);
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

  function TControlFactory.create(data: PDictionary): PControl;
  var
    id: TControlId;
  begin
    id := data^.getString('type');
    if id = C_CONTROL_TYPE_PANEL then 
      create := createPanel(data)
    else
      raise(@self, 0, S_ERR_UNEXPECTED_TYPE);
  end;

  { TControlFactory private }
  function TControlFactory.createPanel(data: PDictionary): PPanel;
  var
    panel: PPanel;
  begin
    panel := new(PPanel, initWithId(data^.getString('id')));
    initPanel(panel, data);
    createPanel := panel;
  end;

  procedure TControlFactory.initControl(control: PControl; data: PDictionary);
  begin
    with control^.getFrame^ do
    begin
      point.x := data^.getLongWithPath('frame.x');
      point.y := data^.getLongWithPath('frame.y');
      size.width := data^.getLongWithPath('frame.width');
      size.height := data^.getLongWithPath('frame.height');
    end;  
  end;

  procedure TControlFactory.initPanel(panel: PPanel; data: PDictionary);
  var
    str: string;
    list: PList;
    obj: PObject;
    control: PControl;
  begin
    initControl(panel, data);
 
    str := data^.getString('border-style');
    if str = 'raised' then panel^.setBorderStyle(EBorderStyleRaised)
      else if str = 'lowered' then panel^.setBorderStyle(EBorderStyleLowered)
      else panel^.setBorderStyle(EBorderStyleNone);
 
    str := data^.getString('background-color');
    if str <> '' then panel^.setBackgroundColor(hextolong(str));

    list := PList(data^.getObject('controls'));
    if list <> nil then
    begin
      list^.moveToStart;
      obj := list^.getObjectAtCursor;
      if obj <> nil then
      begin
        if obj^.getClassId = C_CLASS_ID_DICTIONARY then
        begin
          control := create(PDictionary(obj));
          control^.setParent(panel);
          panel^.getControls^.addObject(control);
          control^.release;
        end;
        list^.moveForward;
        obj := list^.getObjectAtCursor;
      end;
    end;
  end;

  { Other }

end.