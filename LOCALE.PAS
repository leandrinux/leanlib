{
  Locale Unit
  Contains localized strings used all over the library.
  2022 LRT
}
unit
  locale;

interface

  const
    S_LOCALIZATION_LANGUAGE = 'English';
    S_LOCALIZATION_REGION = 'United States';
    S_YES = 'Yes';
    S_NO = 'No';
    S_TRUE = 'True';
    S_FALSE = 'False';

    { -------------  days of the week }

    S_SUNDAY = 'Sunday';
    S_MONDAY = 'Monday';
    S_TUESDAY = 'Tuesday';
    S_WEDNESDAY = 'Wednesday';
    S_THURSDAY = 'Thursday';
    S_FRIDAY = 'Friday';
    S_SATURDAY = 'Saturday';

    { -------------  month names }

    S_JANUARY = 'January';
    S_FEBRUARY = 'February';
    S_MARCH = 'March';
    S_APRIL = 'April';
    S_MAY = 'May';
    S_JUNE = 'June';
    S_JULY = 'July';
    S_AUGUST = 'August';
    S_SEPTEMBER = 'September';
    S_OCTOBER = 'October';
    S_NOVEMBER = 'November';
    S_DECEMBER = 'December';

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

    S_LONG_DATE_FS = '[5], [2] [6] [0]';     { Monday, 27 June 2022 }
    S_SHORT_DATE_FS = '[1]-[2]-[0]';         { 6-27-2022 }

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

    S_LONG_TIME_FS = '[0]:[7]:[8].[4]';   { 0:42:34.2 }
    S_SHORT_TIME_FS = '[0]:[7] [9]';      { 5:30 PM }

    { generic error messages }
    S_ERR_ABSTRACT_CLASS = 'Cannot init an abstract class';
    S_ERR_RESOURCE_NOT_FOUND = 'Resource not found';
    S_ERR_RESOURCE_NOT_OPEN = 'Resource not open';
    S_ERR_RESOURCE_CREATION_FAILED = 'Resource creation failed';
    S_ERR_INVALID_BOUNDS = 'Invalid bounds';
    S_ERR_NOT_ENOUGH_MEMORY = 'Not enough memory';
    S_ERR_TARGET_READ_ONLY = 'Target is read only';
    S_ERR_UNSUPPORTED_ACTION = 'Unsupported action';
    S_ERR_DRIVER_NOT_READY = 'Driver not ready';
    S_ERR_CANVAS_NOT_SET = 'Canvas not set';
    S_ERR_FONT_NOT_SET = 'Font not set';
    S_ERR_EMS_ERROR = 'Expanded memory error';
    S_ERR_EMS_NOT_PRESENT = 'Expanded memory unavailable';
    S_ERR_EMS_NOT_ENOUGH = 'Not enough expanded memory';
    S_ERR_PACKAGE_CORRUPT = 'Package file is corrupt';
    S_ERR_INVALID_JSON_FILE = 'Invalid JSON file';
    S_ERR_INCORRECT_MEMBER_CLASS = 'Incorrect member class';
    S_ERR_UNEXPECTED_TYPE = 'Unexpected type';

    { System and process related messages }
    S_ERR_APP_INFO_MISSING = 'App info is missing';
    S_ERR_PROCESS_UNDEFINED = 'Process is undefined';

    { TException strings }

    {
      Arguments for exception messages:
      0: String representation of the instance pointer in SEGMENT:OFFSET format
      1: Name of the class of the instance that has caused the error
      2: Error code
      3: Error message
    }
    S_EXCEPTION_ERROR_MSG_FS = 'Exception raised with code [2]: [3]';
    S_EXCEPTION_ERROR_MSG_NO_CODE_FS = 'Exception raised: [3]';
    S_EXCEPTION_INSTANCE_ERROR_MSG_FS = 'Exception raised by [1] ([0]) with code [2]: [3]';
    S_EXCEPTION_INSTANCE_ERROR_MSG_NO_CODE_FS = 'Exception raised by [1] ([0]): [3]';

    { debug strings (that must not be included in production releases) }
    {$IFDEF DEBUG}
    {$ENDIF}

implementation

end.