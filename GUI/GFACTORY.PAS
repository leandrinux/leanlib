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
    gclasses, gtypes, gattribs, gcontrol, gpanel, glabel, gbutton, gchkbox, gfield;

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
      function createControl(data: PDictionary): PControl;
      function createPanel(data: PDictionary): PPanel;
      function createLabel(data: PDictionary): PLabel;
      function createButton(data: PDictionary): PButton;
      function createCheckbox(data: PDictionary): PCheckbox;
      function createTextField(data: PDictionary): PTextField;
      procedure initControl(control: PControl; data: PDictionary);
      procedure initPanel(panel: PPanel; data: PDictionary);
      procedure initLabel(lbl: PLabel; data: PDictionary);
      procedure initButton(button: PButton; data: PDictionary);
      procedure initCheckbox(checkbox: PCheckbox; data: PDictionary);
      procedure initTextField(textField: PTextField; data: PDictionary);
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
    if controlType = C_CONTROL_TYPE_CONTROL then 
      create := createControl(data)
    else if controlType = C_CONTROL_TYPE_PANEL then 
      create := createPanel(data)
    else if controlType = C_CONTROL_TYPE_LABEL then 
      create := createLabel(data)
    else if controlType = C_CONTROL_TYPE_BUTTON then 
      create := createButton(data)
    else if controlType = C_CONTROL_TYPE_CHECKBOX then 
      create := createCheckbox(data)
    else if controlType = C_CONTROL_TYPE_TEXTFIELD then 
      create := createTextField(data)
    else
      raise(@self, 0, S_ERR_UNEXPECTED_TYPE);
  end;

  function TControlFactory.createControl(data: PDictionary): PControl;
  var
    control: PControl;
  begin
    control := new(PControl, init);
    control^.setId(data^.getString(C_ATTR_ID, ''));
    initControl(control, data);
    createControl := control;
  end;

  function TControlFactory.createPanel(data: PDictionary): PPanel;
  var
    panel: PPanel;
  begin
    panel := new(PPanel, init);
    panel^.setId(data^.getString(C_ATTR_ID, ''));
    initPanel(panel, data);
    createPanel := panel;
  end;

  function TControlFactory.createLabel(data: PDictionary): PLabel;
  var
    lbl: PLabel;
  begin
    lbl := new(PLabel, init);
    lbl^.setId(data^.getString(C_ATTR_ID, ''));
    initLabel(lbl, data);
    createLabel := lbl;
  end;

  function TControlFactory.createButton(data: PDictionary): PButton;
  var
    button: PButton;
  begin
    button := new(PButton, init);
    button^.setId(data^.getString(C_ATTR_ID, ''));
    initButton(button, data);
    createButton := button;
  end;

  function TControlFactory.createCheckbox(data: PDictionary): PCheckbox;
  var
    checkbox: PCheckbox;
  begin
    checkbox := new(PCheckbox, init);
    checkbox^.setId(data^.getString(C_ATTR_ID, ''));
    initCheckbox(checkbox, data);
    createCheckbox := checkbox;
  end;

  function TControlFactory.createTextField(data: PDictionary): PTextField;
  var
    textField: PTextField;
  begin
    textField := new(PTextField, init);
    textField^.setId(data^.getString(C_ATTR_ID, ''));
    initTextField(textField, data);
    createTextField := textField;
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

    str := data^.getString(C_ATTR_ALIGN, '');
    if str = C_ATTR_ALIGN_TL then control^.setAlignment(EAlignTopLeft)
      else if str = C_ATTR_ALIGN_TOP then control^.setAlignment(EAlignTop)
      else if str = C_ATTR_ALIGN_TR then control^.setAlignment(EAlignTopRight)
      else if str = C_ATTR_ALIGN_LEFT then control^.setAlignment(EAlignLeft)
      else if str = C_ATTR_ALIGN_CENTER then control^.setAlignment(EAlignCenter)
      else if str = C_ATTR_ALIGN_RIGHT then control^.setAlignment(EAlignRight)
      else if str = C_ATTR_ALIGN_BL then control^.setAlignment(EAlignBottomLeft)
      else if str = C_ATTR_ALIGN_BOTTOM then control^.setAlignment(EAlignBottom)
      else if str = C_ATTR_ALIGN_BR then control^.setAlignment(EAlignBottomRight);

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
      else panel^.setBorderStyle(C_DEFAULT_PANEL_BORDER_STYLE);

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
          panel^.addControl(control);
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
    if str = C_ATTR_ALIGN_TL then lbl^.setTextAlignment(EAlignTopLeft)
      else if str = C_ATTR_ALIGN_TOP then lbl^.setTextAlignment(EAlignTop)
      else if str = C_ATTR_ALIGN_TR then lbl^.setTextAlignment(EAlignTopRight)
      else if str = C_ATTR_ALIGN_LEFT then lbl^.setTextAlignment(EAlignLeft)
      else if str = C_ATTR_ALIGN_CENTER then lbl^.setTextAlignment(EAlignCenter)
      else if str = C_ATTR_ALIGN_RIGHT then lbl^.setTextAlignment(EAlignRight)
      else if str = C_ATTR_ALIGN_BL then lbl^.setTextAlignment(EAlignBottomLeft)
      else if str = C_ATTR_ALIGN_BOTTOM then lbl^.setTextAlignment(EAlignBottom)
      else if str = C_ATTR_ALIGN_BR then lbl^.setTextAlignment(EAlignBottomRight);
  end;

  procedure TControlFactory.initButton(button: PButton; data: PDictionary);
  begin
    initControl(button, data);
    button^.setCaption(data^.getString(C_ATTR_CAPTION, ''));
  end;

  procedure TControlFactory.initCheckbox(checkbox: PCheckbox; data: PDictionary);
  begin
    initControl(checkbox, data);
    with checkbox^.getFrame^ do
    begin
      size.width := 15;
      size.height := 15;
    end;
    checkbox^.setChecked(data^.getBool(C_ATTR_CHECKED, false));
  end;

  procedure TControlFactory.initTextField(textField: PTextField; data: PDictionary);
  begin
    initControl(textField, data);
    textField^.setText(data^.getString(C_ATTR_TEXT, ''));
    textField^.setPlaceholder(data^.getString(C_ATTR_PLACEHOLDER, ''));
  end;

  { Other }

end.