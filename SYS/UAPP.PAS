{
  uapp Unit
  Base class for applications
  2022 LRT
}
unit
  uapp;

interface

  uses
    consts, utils, uexc, uclasses, types, locale, uobject, uprocess;

  type
    PAppInfo = ^TAppInfo;
    TAppInfo = packed record
      appName: string32;          { name of the app }
      appVersion: word;           { app version (BCD) e.g. $0203 is 2.3 }
      appAuthor: string32;        { name of the app's author }
      appBuild: string32;         { specific info about the build }
(*
      requiresHardDisk: boolean;  { requires a hard disk? }
      requiresEMS: boolean;       { requires expanded memory? }
      requiresMouse: boolean;     { requires a mouse? }
      baseMemoryNeeded: word;     { how much base memory is required }
      expandedMemoryNeeded: word; { how much expanded memory is required }
*)
    end;

    PApp = ^TApp;
    TApp = object (TObject)
    public
      constructor init;
      destructor done; virtual;
      function getAppInfo: PAppInfo; virtual;
      function getRootProcess: PProcess; virtual;
      function getClassName: string; virtual;
      function getClassId: word; virtual;
    private
    end;

implementation

  { TApp public }

  constructor TApp.init;
  begin
    inherited init;
  end;

  destructor TApp.done;
  begin
    inherited done;
  end;

  function TApp.getAppInfo: PAppInfo;
  begin
    getAppInfo := nil;
  end;

  function TApp.getRootProcess: PProcess;
  begin
    getRootProcess := nil;
  end;

  function TApp.getClassName: string;
  begin
    getClassName := 'TApp';
  end;

  function TApp.getClassId: word;
  begin
    getClassId := C_CLASS_ID_App;
  end;

  { TApp private }

  { Other }

end.