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
    gclasses, gtypes, gattribs, gcontrol, gpanel, glabel, gbutton;

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
      function createButton(data: PDictionary): PButton;
      procedure initControl(control: PControl; data: PDictionary);
      procedure initPanel(panel: PPanel; data: PDictionary);
      procedure initLabel(lbl: PLabel; data: PDictionary);
      procedure initButton(button: PButton; data: PDictionary);
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
    controlType := data^.getString(C_ATTR_TYPE, '');
    if controlType = C_CONTROL_TYPE_PANEL then 
      create := createPanel(data)
    else if controlType = C_CONTROL_TYPE_LABEL then 
      create := createLabel(data)
    else if controlType = C_CONTROL_TYPE_BUTTON then 
      create := createButton(data)
    else
      raise(@self, 0, S_ERR_UNEXPECTED_TYPE);
  end;

  { TControlFactory private }
  function TControlFactory.createPanel(data: PDictionary): PPanel;
  var
    panel: PPanel;
  begin
    panel := new(PPanel, initWithId(data^.getString(C_ATTR_ID, '')));
    initPanel(panel, data);
    createPanel := panel;
  end;

  function TControlFactory.createLabel(data: PDictionary): PLabel;
  var
    lbl: PLabel;
  begin
    lbl := new(PLabel, initWithId(data^.getString(C_ATTR_ID, '')));
    initLabel(lbl, data);
    createLabel := lbl;
  end;

  function TControlFactory.createButton(data: PDictionary): PButton;
  var
    button: PButton;
  begin
    button := new(PButton, initWithId(data^.getString(C_ATTR_ID, '')));
    initButton(button, data);
    createButton := button;
  end;

  procedure TControlFactory.initControl(control: PControl; data: PDictionary);
  var
    str: string;
  begin
    with control^.getFrame^ do
    begin
      point.x := data^.getLongWithPath(C_PATH_FRAME_X, 0);
      point.y := data^.getLongWithPath(C_PATH_FRAME_Y, 0);
      size.width := data^.getLongWithPath(C_PATH_FRAME_WIDTH, 0);
      size.height := data^.getLongWithPath(C_PATH_FRAME_HEIGHT, 0);
    end;  

    str := data^.getString(C_ATTR_BACKGROUND_COLOR, '');
    if str <> '' then control^.setBackgroundColor(hextolong(str));

    control^.setBackgroundStyle(EBackgroundStyleSolid);
    str := data^.getString(C_ATTR_BACKGROUND_STYLE, '');
    if str = C_ATTR_BACKGROUND_STYLE_TRANSPARENT then
      control^.setBackgroundStyle(EBackgroundStyleTransparent);
  end;

  procedure TControlFactory.initPanel(panel: PPanel; data: PDictionary);
  var
    str: string;
    list: PList;
    obj: PObject;
    control: PControl;
  begin
    initControl(panel, data);
 
    str := data^.getString(C_ATTR_BORDER_STYLE, '');
    if str = C_ATTR_BORDER_STYLE_RAISED then panel^.setBorderStyle(EBorderStyleRaised)
      else if str = C_ATTR_BORDER_STYLE_LOWERED then panel^.setBorderStyle(EBorderStyleLowered)
      else panel^.setBorderStyle(EBorderStyleNone);

    list := PList(data^.getObject(C_ATTR_CONTROLS));
    if list <> nil then
    begin
      list^.moveToStart;
      obj := list^.getObjectAtCursor;
      while obj <> nil do
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
  var
    str: string;
  begin
    initControl(lbl, data);
    lbl^.setText(data^.getString(C_ATTR_TEXT, ''));

    str := data^.getString(C_ATTR_TEXT_COLOR, '');
    if str <> '' then lbl^.setTextColor(hextolong(str));

    lbl^.setBackgroundStyle(EBackgroundStyleTransparent);
    str := data^.getString(C_ATTR_BACKGROUND_STYLE, '');
    if str = C_ATTR_BACKGROUND_STYLE_SOLID then
      lbl^.setBackgroundStyle(EBackgroundStyleSolid);

    str := data^.getString(C_ATTR_TEXT_ALIGN, '');
    if str = C_ATTR_TEXT_ALIGN_TL then lbl^.setTextAlign(ETextAlignTopLeft)
      else if str = C_ATTR_TEXT_ALIGN_TOP then lbl^.setTextAlign(ETextAlignTop)
      else if str = C_ATTR_TEXT_ALIGN_TR then lbl^.setTextAlign(ETextAlignTopRight)
      else if str = C_ATTR_TEXT_ALIGN_LEFT then lbl^.setTextAlign(ETextAlignLeft)
      else if str = C_ATTR_TEXT_ALIGN_CENTER then lbl^.setTextAlign(ETextAlignCenter)
      else if str = C_ATTR_TEXT_ALIGN_RIGHT then lbl^.setTextAlign(ETextAlignRight)
      else if str = C_ATTR_TEXT_ALIGN_BL then lbl^.setTextAlign(ETextAlignBottomLeft)
      else if str = C_ATTR_TEXT_ALIGN_BOTTOM then lbl^.setTextAlign(ETextAlignBottom)
      else if str = C_ATTR_TEXT_ALIGN_BR then lbl^.setTextAlign(ETextAlignBottomRight);
  end;

  procedure TControlFactory.initButton(button: PButton; data: PDictionary);
  begin
    initControl(button, data);
    button^.setCaption(data^.getString(C_ATTR_CAPTION, ''));
  end;

  { Other }

end.