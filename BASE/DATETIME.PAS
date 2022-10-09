{
  Datetime Unit
  Data types and datetime handling routines
  2022 LRT
}
unit
  datetime;

interface

  uses
    types, locale, utils, strings;

  type
    TDate = packed record
      year, month, day, weekday: word;
    end;

    TTime = packed record
      hour, minute, second, csec: word;
    end;

    TDateTime = packed record
      date: TDate;
      time: TTime;
    end;

  const
    C_DAY_NAMES: array[0..6] of string9 = (
      S_SUNDAY, S_MONDAY, S_TUESDAY, S_WEDNESDAY, S_THURSDAY, S_FRIDAY, S_SATURDAY
    );

    C_MONTH_NAMES: array[0..11] of string9 = (
      S_JANUARY, S_FEBRUARY, S_MARCH, S_APRIL, S_MAY, S_JUNE,
      S_JULY, S_AUGUST, S_SEPTEMBER, S_OCTOBER, S_NOVEMBER, S_DECEMBER
    );

    C_LONG_TIME_FORMAT    = S_LONG_TIME_FS;
    C_SHORT_TIME_FORMAT   = S_SHORT_TIME_FS;
    C_LONG_DATE_FORMAT    = S_LONG_DATE_FS;
    C_SHORT_DATE_FORMAT   = S_SHORT_DATE_FS;
    C_ISO8601_DATE_FORMAT = '[0]-[3]-[4]';
    C_ISO8601_TIME_FORMAT = '[5]:[7]:[8]';

  {
    returns the specified hours, minutes and seconds into milliseconds
  }
  function timeToMsec(time: TTime): longint;

  {
   Converts the specified date into a string using the specified format
   Use [x] to specify any of the following possible options
   0: year (4 digits)
   1: month
   2: day
   3: month (with leading zero)
   4: day (with leading zero)
   5: name of the day of the week
   6: name of the month
   7: year (2 digits)
  }
  function dateToStr(var date: TDate; format: string): string;

  {
   Converts the specified time into a string using the specified format
   Use [x] to specify any of the following possible options
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
  function timeToStr(var time: TTime; format: string): string;

  {
    returns the specified date and time following the ISO 8601
    standard. (note: since timezone info is not available, UTC will be used
  }
  function dateTimeToISO8601(var datetime: TDateTime): string;

  {
    returns the time difference (or delta) between two times in milliseconds
  }
  function timeDelta(A, B: TTime): longint;

implementation

  function timeToMsec(time: TTime): longint;
  begin
    TimeToMsec :=
      longint(time.csec) * 10 +
      (longint(time.second) + longint(time.minute) * 60 + longint(time.hour) * 3600) * 1000;
  end;

  function dateToStr(var date: TDate; format: string): string;
  var args: array[0..7] of string;
  begin
    args[0] := intToStr(date.year);           { year (4 digits) }
    args[1] := intToStr(date.month);          { month }
    args[2] := intToStr(date.day);            { day }
    args[3] := padw(date.month, '0', 2);      { month (with leading zero) }
    args[4] := padw(date.day, '0', 2);        { day (with leading zero) }
    args[5] := C_DAY_NAMES[date.weekday];     { name of the day of the week }
    args[6] := C_MONTH_NAMES[date.month - 1]; { name of the month }
    args[7] := intToStr(date.year div 100);   { year (2 digits) }
    dateToStr := strformat(format, @args);
  end;

  function timeToStr(var time: TTime; format: string): string;
  var args: array[0..9] of string;
  begin
    args[0] := intToStr(time.hour);       { hours }
    args[2] := intToStr(time.minute);     { minutes }
    args[3] := intToStr(time.second);     { seconds }
    args[4] := intToStr(time.csec);       { fractions of second }
    args[5] := padw(time.hour, '0', 2);   { hours (with leading zero) }
    args[7] := padw(time.minute, '0', 2); { minutes (w/leading zero) }
    args[8] := padw(time.second, '0', 2); { seconds (w/leading zero) }
    if time.hour>12 then
    begin
      args[1] := intToStr(time.hour - 12);     { hours (12-hour) }
      args[6] := padw(time.hour - 12, '0', 2); { hours (12-hour, leading zero) }
    end else begin
      args[1] := args[0];
      args[6] := args[5];
    end;
    if time.hour>11 then args[9] := 'PM' else args[9] := 'AM'; { AM or PM }
    timeToStr := strformat(format, @args);
  end;

  function dateTimeToISO8601(var datetime: TDateTime): string;
  begin
    dateTimeToISO8601 :=
      dateToStr(datetime.date, C_ISO8601_DATE_FORMAT) + 'T' +
      timeToStr(datetime.time, C_ISO8601_TIME_FORMAT) + 'Z';
  end;

  function timeDelta(A, B: TTime): longint;
  var
    lA, lB: longint;
  begin
    lA := TimeToMsec(A);
    lB := TimeToMsec(B);
    if lB  > lA then
      timeDelta := lB - lA
    else
      if lB  < lA then
        timeDelta := lB + (86400000 - lA)
      else
        timeDelta := 0;
  end;

end.