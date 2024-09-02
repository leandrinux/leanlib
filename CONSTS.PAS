{
  Consts Unit
  Multiple useful typed and untyped constants
  2022 LRT
}
unit
  consts;

interface

  uses
    types;

  const
    C_POINT_ZERO: TPoint = ( x:0; y:0 );
    C_SIZE_MAX: TSize = ( width:$FFFF; height: $FFFF );
    C_NOT_FOUND = $FFFFFFFF;
    C_FILE_PATH_SEPARATOR = '\';
    C_DICTIONARY_PATH_SEPARATOR = '.';

    C_TICKS: plong = ptr(0, $046c); { 1 tick equals 54.925 ms }

implementation

end.