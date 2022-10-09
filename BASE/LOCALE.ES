{
  Locale Unit
  Contains localized strings used all over the library.
  2022 LRT
}
unit
  locale;

interface

  const

S_LOCALIZATION_LANGUAGE = 'Espa¤ol';
S_LOCALIZATION_REGION = 'Argentina';
S_YES = 's¡';
S_NO = 'no';
S_TRUE = 'verdadero';
S_FALSE = 'falso';

{ -------------  days of the week }

S_SUNDAY = 'domingo';
S_MONDAY = 'lunes';
S_TUESDAY = 'martes';
S_WEDNESDAY = 'mi‚rcoles';
S_THURSDAY = 'jueves';
S_FRIDAY = 'viernes';
S_SATURDAY = 's bado';

{ -------------  month names }

S_JANUARY = 'enero';
S_FEBRUARY = 'febrero';
S_MARCH = 'marzo';
S_APRIL = 'abril';
S_MAY = 'mayo';
S_JUNE = 'junio';
S_JULY = 'julio';
S_AUGUST = 'agosto';
S_SEPTEMBER = 'septiembre';
S_OCTOBER = 'octubre';
S_NOVEMBER = 'noviembre';
S_DECEMBER = 'diciembre';

{ ------------- date and time format strings }

{
  Arguments for date format strings:
   0: year (4 digits)
   1: month
   2: day
   3: month (with leading zero)
   4: day (with leading zero)
   5: name of the day of the week
   6: name of the month
   7: year (2 digits)
}

S_LONG_DATE_FORMAT = '[5] [2] de [6] de [0]'; { lunes 20 de junio de 2022 }
S_SHORT_DATE_FORMAT = '[2]/[1]/[0]';          { 20/6/2022 }

{
  Arguments for time format strings:
   0: hours
   1: hours (12 hour format)
   2: minutes
   3: seconds
   4: fractions of second
   5: hours (with leading zero)
   6: hours (12 hour format, with leading zero)
   7: minutes (with leading zero)
   8: seconds (with leading zero)
   9: AM or PM
}

S_LONG_TIME_FORMAT = '[0]:[7]:[8].[4]';   { 0:42:34.2 }
S_SHORT_TIME_FORMAT = '[1]:[7]';      { 17:30 }

{ generic error messages }
S_ERR_FILE_NOT_FOUND = 'El archivo no se encontr¢';
S_ERR_FILE_NOT_OPEN = 'El archivo no est  abierto';
S_ERR_FILE_IS_READ_ONLY = 'El archivo es de s¢lo lectura';
S_ERR_FILE_COULDNT_BE_CREATED = 'El archivo no se pudo crear';

{ TException strings }

{
  Arguments for exception messages:
  0: String representation of the instance pointer in SEGMENT:OFFSET format
  1: Name of the class of the instance that has caused the error
  2: Error code
  3: Error message
}
S_EXCEPTION_ERROR_MSG_FS = 'Ocurri¢ una excepci¢n con el c¢digo [2]: [3]';
S_EXCEPTION_ERROR_MSG_NO_CODE_FS = 'Ocurri¢ una excepci¢n: [3]';
S_EXCEPTION_INSTANCE_ERROR_MSG_FS = '[1] ([0]) elev¢ una excepci¢n con el c¢digo [2]: [3]';
S_EXCEPTION_INSTANCE_ERROR_MSG_NO_CODE_FS = '[1] ([0]) elev¢ una excepci¢n: [3]';

{ debug strings (that must not be included in production releases) }
{$IFDEF DEBUG}

{$ENDIF}
implementation

end.