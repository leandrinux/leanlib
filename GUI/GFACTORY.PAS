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
    gclasses, gtypes, gattribs, gcontrol, gpanel, glabel;

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
      function createLabel(data: PDictionary): PLabel;
      procedure initControl(control: PControl; data: PDictionary);
      procedure initPanel(panel: PPanel; data: PDictionary);
      procedure initLabel(lbl: PLabel; data: PDictionary);
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
    controlType: string16;
  begin
    controlType := data^.getString(C_ATTR_TYPE);
    if controlType = C_CONTROL_TYPE_PANEL then 
      create := createPanel(data)
    else if controlType = C_CONTROL_TYPE_LABEL then 
      create := createLabel(data)
    else
      raise(@self, 0, S_ERR_UNEXPECTED_TYPE);
  end;

  { TControlFactory private }
  function TControlFactory.createPanel(data: PDictionary): PPanel;
  var
    panel: PPanel;
  begin
    panel := new(PPanel, initWithId(data^.getString(C_ATTR_ID)));
    initPanel(panel, data);
    createPanel := panel;
  end;

  function TControlFactory.createLabel(data: PDictionary): PLabel;
  var
    lbl: PLabel;
  begin
    lbl := new(PLabel, initWithId(data^.getString(C_ATTR_ID)));
    initLabel(lbl, data);
    createLabel := lbl;
  end;

  procedure TControlFactory.initControl(control: PControl; data: PDictionary);
  begin
    with control^.getFrame^ do
    begin
      point.x := data^.getLongWithPath(C_ATTR_FRAME_X);
      point.y := data^.getLongWithPath(C_ATTR_FRAME_Y);
      size.width := data^.getLongWithPath(C_ATTR_FRAME_WIDTH);
      size.height := data^.getLongWithPath(C_ATTR_FRAME_HEIGHT);
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
 
    str := data^.getString(C_ATTR_BORDER_STYLE);
    if str = C_ATTR_BORDER_STYLE_RAISED then panel^.setBorderStyle(EBorderStyleRaised)
      else if str = C_ATTR_BORDER_STYLE_LOWERED then panel^.setBorderStyle(EBorderStyleLowered)
      else panel^.setBorderStyle(EBorderStyleNone);
 
    str := data^.getString(C_ATTR_BACKGROUND_COLOR);
    if str <> '' then panel^.setBackgroundColor(hextolong(str));

    list := PList(data^.getObject(C_ATTR_CONTROLS));
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

  procedure TControlFactory.initLabel(lbl: PLabel; data: PDictionary);
  begin
    initControl(lbl, data);
    lbl^.setText(data^.getString(C_ATTR_TEXT));
  end;

  { Other }

end.