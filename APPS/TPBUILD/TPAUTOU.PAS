{
  this unit's responsibility is to generate the temporary
  dynamic unit which is provided to make it easier to
  automate timestamping a build.
}
unit
  tpautou;

interface

  uses
    tptexts,
    tputil,
    tptpc,
    dos;

  const
    C_DYNAMIC_UNIT_NAME = 'AUTOUNIT';

  procedure createDynamicUnit;
  procedure deleteDynamicUnit;

implementation

  procedure createDynamicUnit;
  var 
    f: text;
    h, min, s, ms: word;
    y, m, d, dw: word;
    filename, errorMsg: string;
  begin
    getTime(h,min,s,ms);
    getDate(y,m,d,dw);
    log(C_STR_DYNAMIC_UNIT_CREATE);
    filename := C_DYNAMIC_UNIT_NAME + '.PAS';
    assign(f, filename);
    rewrite(f);
    writeln(f, 'unit ', C_DYNAMIC_UNIT_NAME, ';');
    writeln(f, 'interface');
    writeln(f, 'const');
    writeln(f, '  C_BUILD_TIME = ''', h, ':', min, ':', s, '.', ms, ''';');
    writeln(f, '  C_BUILD_DATE = ''', y, '/', m, '/', d, ''';');
    writeln(f, 'implementation');
    writeln(f, 'end.');
    close(f);
    compile('.', filename, errorMsg);
  end;

  procedure deleteDynamicUnit;
  begin
    log(C_STR_DYNAMIC_UNIT_DELETE);
    deleteFile(C_DYNAMIC_UNIT_NAME + '.PAS');
    deleteFile(C_DYNAMIC_UNIT_NAME + '.TPU');
  end;

end.