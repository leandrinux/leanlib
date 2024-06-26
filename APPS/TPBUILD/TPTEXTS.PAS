{
  This unit contains all the text strings used by TPBUILD
}
{DEFINE Spanish}
unit
  tptexts;

interface

  const

    {$IFDEF Spanish}

    C_STR_WELCOME = 'TPBuild versi¢n %0 hecho por LRT en 2024';
    C_STR_TPC_NOT_INSTALLED = 'TPC no instalado o no definido en el PATH de DOS';
    C_STR_TPC_LOCATION = 'Ubicaci¢n del compilador Turbo Pascal: ';
    C_STR_PACKAGE_TO_BUILD = 'Paquete a compilar: ';
    C_STR_CURRENT_DIR = '(directorio actual)';
    C_STR_BUILD_ALL = 'Compilando todo';
    C_STR_SUCCESS = '... ­‚xito';
    C_STR_FAILED = '... ­fall¢!';
    C_STR_YES_MODIFIED_RECORDS = 'Se encontr¢ registro de archivos modificados - se compilar n solo lo que cambiaron';
    C_STR_NO_MODIFIED_RECORDS = 'No se encontr¢ registro de archivos modificados - se compilar  todo';
    C_STR_SAVE_MODIFIED_RECORDS = 'Se guard¢ registro de los archivos modificados';
    C_STR_BUILD_SUCCESS = '­Compilaci¢n exitosa!';
    C_STR_BUILD_FAILED = '­La compilaci¢n fall¢!';
    C_STR_DYNAMIC_UNIT_CREATE = 'Creando la unidad temporal con datos del build';
    C_STR_DYNAMIC_UNIT_DELETE = 'Borrando la unidad temporal con datos del build';
    C_STR_CREATED_BIN_DIR = 'Creando un directorio para archivos binarios';
    C_STR_NO_CONFIG_FILE = 'No se encontr¢ el archivo de configuracion "%0"';
    C_STR_CONFIG_FILE_LOADED = 'Se carg¢ el archivo de configuraci¢n';

    {$ELSE}

    C_STR_WELCOME = 'TPBuild version %0 made by LRT in 2024';
    C_STR_TPC_NOT_INSTALLED = 'TPC not installed or not set in the DOS path';
    C_STR_TPC_LOCATION = 'Turbo Pascal compiler location: ';
    C_STR_PACKAGE_TO_BUILD = 'Package to build: ';
    C_STR_CURRENT_DIR = '(current directory)';
    C_STR_BUILD_ALL = 'Building all';
    C_STR_SUCCESS = '... ok';
    C_STR_FAILED = '... fail!';
    C_STR_YES_MODIFIED_RECORDS = 'Record of modified files found - will only build what changed';
    C_STR_NO_MODIFIED_RECORDS = 'Record of modified files not found - will build everything';
    C_STR_SAVE_MODIFIED_RECORDS = 'modified records saved';
    C_STR_BUILD_SUCCESS = 'Build successful!';
    C_STR_BUILD_FAILED = 'Build failed!';
    C_STR_DYNAMIC_UNIT_CREATE = 'Creating the temporal unit with build data';
    C_STR_DYNAMIC_UNIT_DELETE = 'Deleting the temporal unit with build data';
    C_STR_CREATED_BIN_DIR = 'Creating a directory for binary files';
    C_STR_NO_CONFIG_FILE = 'The configuration file "%0" could not be found';
    C_STR_CONFIG_FILE_LOADED = 'Configuration file loaded';
    C_STR_CFG_SYNTAX_ERROR = 'Syntax error in %0 ln %1 pos %2. ';
    C_STR_CFG_EXPECTS = 'Expects "%0", got "%1"';

    {$ENDIF}

implementation

end.