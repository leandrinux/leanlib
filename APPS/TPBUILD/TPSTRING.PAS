unit
  tpstring;

interface

  const
    C_STR_VERSION = '0.1';
    C_STR_WELCOME = 'TPBuild ' + C_STR_VERSION + ' made by LRT in 2024';
    C_STR_TPC_NOT_INSTALLED = 'TPC not installed or not set in the DOS path';
    C_STR_TPC_LOCATION = 'Turbo Pascal compiler location: ';
    C_STR_PACKAGE_TO_BUILD = 'Package to build: ';
    C_STR_CURRENT_DIR = '(current directory)';
    C_STR_BUILD_ALL = 'Building all';
    C_STR_SUCCESS = '... ok';
    C_STR_FAILED = '... fail!';
    C_STR_YES_MODIFIED_RECORDS = 'modified records found - will only build new or modified files';
    C_STR_NO_MODIFIED_RECORDS = 'no modified records found - will build everything';
    C_STR_SAVE_MODIFIED_RECORDS = 'modified records saved';
    C_STR_BUILD_SUCCESS = 'Build successful!';
    C_STR_BUILD_FAILED = 'Build failed!';
    C_STR_DYNAMIC_UNIT_CREATE = 'Creating dynamic unit';
    C_STR_DYNAMIC_UNIT_DELETE = 'Deleting dynamic unit';
    C_STR_CREATED_BIN_DIR = 'Created directory for binaries';

implementation

end.