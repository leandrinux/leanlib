{
  This unit handles all the operations related
  to the build.cfg file
}
unit 
  tpconfig;
    
interface

  uses
    tputil,
    tptexts;

  procedure initConfiguration(const basedir: TPath);

implementation

  const
    C_CONFIG_FILE_NAME = 'BUILD.CFG';

  procedure openConfigFile(const basedir: TPath);
  var
    f: text;
  begin
    assign(f, basedir + '\' + C_CONFIG_FILE_NAME);
    {$I-} reset(f); {$I+}
    if IOResult <> 0 then error(strformat(C_STR_NO_CONFIG_FILE, C_CONFIG_FILE_NAME));
    log(C_STR_CONFIG_FILE_LOADED);
    close(f);
  end;
    
  procedure initConfiguration(const basedir: TPath);
  begin
    openConfigFile(basedir);
  end;

end.