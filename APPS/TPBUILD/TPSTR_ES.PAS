{
  This unit contains all the text strings used by TPBUILD
}
unit
  tpstr_es;

interface

  {$IFDEF spanish}
  const
    C_STR_VERSION = '0.1';
    C_STR_WELCOME = 'TPBuild ' + C_STR_VERSION + ' hecho por LRT en 2024';
    C_STR_TPC_NOT_INSTALLED = 'TPC no instalado o no definido en el PATH de DOS';
    C_STR_TPC_LOCATION = 'Ubicaci¢n del compilador Turbo Pascal: ';
    C_STR_PACKAGE_TO_BUILD = 'Paquete a compilar: ';
    C_STR_CURRENT_DIR = '(directorio actual)';
    C_STR_BUILD_ALL = 'Compilando todo';
    C_STR_SUCCESS = '... ‚xito';
    C_STR_FAILED = '... ­fall¢!';
    C_STR_YES_MODIFIED_RECORDS = 'Se encontr¢ registro de archivos modificados - se compilar  solo lo que cambi¢';
    C_STR_NO_MODIFIED_RECORDS = 'No se encontr¢ registro de archivos modificados - se compilar  todo';
    C_STR_SAVE_MODIFIED_RECORDS = 'Se guard¢ registro de los archivos modificados';
    C_STR_BUILD_SUCCESS = '­Compilaci¢n exitosa!';
    C_STR_BUILD_FAILED = '­La compilaci¢n fall¢!';
    C_STR_DYNAMIC_UNIT_CREATE = 'Creando la unidad temporal con datos del build';
    C_STR_DYNAMIC_UNIT_DELETE = 'Borrando la unidad temporal con datos del build';
    C_STR_CREATED_BIN_DIR = 'Creando un directorio para archivos binarios';
  {$ENDIF}
  
implementation

end.