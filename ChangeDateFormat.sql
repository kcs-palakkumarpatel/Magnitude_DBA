-- =============================================
-- Author:		<Author,,Nirav / GD>
-- Create date: <Create Date, , 20 Oct 2014>
-- Description:	<Description, ,>
-- Call Function: SELECT [dbo].[ChangeDateFormat] (GETDATE(), 'mm/dd/yyyy')
-- =============================================
CREATE FUNCTION dbo.ChangeDateFormat
    (
      @Date DATETIME ,
      @fORMAT VARCHAR(80)
    )
RETURNS NVARCHAR(80)
AS
    BEGIN
        DECLARE @Dateformat INT;
        DECLARE @ReturnedDate VARCHAR(80);
        DECLARE @TwelveHourClock INT;
        DECLARE @Before INT;
        DECLARE @pos INT;
        DECLARE @Escape INT;
-- (c) Pinal Dave http://www.SQLAuthority.com
        SELECT  @ReturnedDate = 'error! unrecognised format ' + @fORMAT;
        SELECT  @Dateformat = CASE @fORMAT
                                WHEN 'mmm dd yyyy hh:mm AM/PM' THEN 100
                                WHEN 'mm/dd/yy' THEN 1
                                WHEN 'mm/dd/yyyy' THEN 101
                                WHEN 'yy.mm.dd' THEN 2
                                WHEN 'dd/mm/yy' THEN 3
                                WHEN 'dd.mm.yy' THEN 4
                                WHEN 'dd-mm-yy' THEN 5
                                WHEN 'dd Mmm yy' THEN 6
                                WHEN 'Mmm dd, yy' THEN 7
                                WHEN 'hh:mm:ss' THEN 8
                                WHEN 'yyyy.mm.dd' THEN 102
                                WHEN 'dd/mm/yyyy' THEN 103
                                WHEN 'dd.mm.yyyy' THEN 104
                                WHEN 'dd-mm-yyyy' THEN 105
                                WHEN 'dd Mmm yyyy' THEN 106
                                WHEN 'Mmm dd, yyyy' THEN 107
                                WHEN 'Mmm dd yyyy hh:mm:ss:ms AM/PM' THEN 9
                                WHEN 'Mmm dd yyyy hh:mi:ss:mmm AM/PM' THEN 9
                                WHEN 'Mmm dd yy hh:mm:ss:ms AM/PM' THEN 109
                                WHEN 'mm-dd-yy' THEN 10
                                WHEN 'mm-dd-yyyy' THEN 110
                                WHEN 'yy/mm/dd' THEN 11
                                WHEN 'yyyy/mm/dd' THEN 111
                                WHEN 'yymmdd' THEN 12
                                WHEN 'yyyymmdd' THEN 112
                                WHEN 'dd Mmm yyyy hh:mm:ss:Ms' THEN 113
                                WHEN 'hh:mm:ss:Ms' THEN 14
                                WHEN 'yyyy-mm-dd hh:mm:ss' THEN 120
                                WHEN 'yyyy-mm-dd hh:mm:ss.Ms' THEN 121
                                WHEN 'yyyy-mm-ddThh:mm:ss.Ms' THEN 126
                                WHEN 'dd Mmm yyyy hh:mm:ss:ms AM/PM' THEN 130
                                WHEN 'dd/mm/yy hh:mm:ss:ms AM/PM' THEN 131
                                WHEN 'RFC822' THEN -2
                                WHEN 'dd Mmm yyyy hh:mm' THEN -4
                                ELSE -1
                              END;
        SELECT  @ReturnedDate = 'error! unrecognised format ' + @fORMAT
                + CONVERT(VARCHAR(10), @Dateformat);
        IF @Dateformat >= 0
            SELECT  @ReturnedDate = CONVERT(VARCHAR(80), @Date, @Dateformat);
--check for favourite and custom formats that can be done quickly
        ELSE
            IF @Dateformat = -2--then it is RFC822 format
                SELECT  @ReturnedDate = LEFT(DATENAME(dw, @Date), 3) + ', '
                        + STUFF(CONVERT(NVARCHAR, @Date, 113), 21, 4, ' GMT');
            ELSE
                IF @Dateformat = -4--then it is european day format with minutes
                    SELECT  @ReturnedDate = CONVERT(CHAR(17), @Date, 113);
                ELSE
                    BEGIN
                        SELECT  @Before = LEN(@fORMAT);
                        SELECT  @fORMAT = REPLACE(REPLACE(REPLACE(@fORMAT,
                                                              'AM/PM', '#'),
                                                          'AM', '#'), 'PM',
                                                  '#');
                        SELECT  @TwelveHourClock = CASE WHEN @Before > LEN(@fORMAT)
                                                        THEN 109
                                                        ELSE 113
                                                   END ,
                                @ReturnedDate = '';
                        WHILE ( 1 = 1 )--forever
                            BEGIN
                                SELECT  @pos = PATINDEX('%[yqmidwhs:#]%',
                                                        @fORMAT + ' ');
                                IF @pos = 0--no more date format strings
                                    BEGIN
                                        SELECT  @ReturnedDate = @ReturnedDate
                                                + @fORMAT;
                                        BREAK;
                                    END;
                                IF @pos > 1--some stuff to pass through first
                                    BEGIN
                                        SELECT  @Escape = CHARINDEX('\',
                                                              @fORMAT + '\'); --is it a literal character that is escaped?
                                        IF @Escape < @pos
                                            BEGIN
                                                SET @ReturnedDate = @ReturnedDate
                                                    + SUBSTRING(@fORMAT, 1,
                                                              @Escape - 1)
                                                    + SUBSTRING(@fORMAT,
                                                              @Escape + 1, 1);
                                                SET @fORMAT = RTRIM(SUBSTRING(@fORMAT,
                                                              @Escape + 2, 80));
                                                CONTINUE;
                                            END;
                                        SET @ReturnedDate = @ReturnedDate
                                            + SUBSTRING(@fORMAT, 1, @pos - 1);
                                        SET @fORMAT = RTRIM(SUBSTRING(@fORMAT,
                                                              @pos, 80));
                                    END;
                                SELECT  @pos = PATINDEX('%[^yqmidwhs:#]%',
                                                        @fORMAT + ' ');--get the end
                                SELECT  @ReturnedDate = @ReturnedDate
                                        + --'('+substring(@Format,1,@pos-1)+')'+
CASE SUBSTRING(@fORMAT, 1, @pos - 1)
--Mmmths as 1--12
  WHEN 'M' THEN CONVERT(VARCHAR(2), DATEPART(MONTH, @Date))
--Mmmths as 01--12
  WHEN 'Mm' THEN CONVERT(CHAR(2), @Date, 101)
--Mmmths as Jan--Dec
  WHEN 'Mmm' THEN CONVERT(CHAR(3), DATENAME(MONTH, @Date))
--Mmmths as January--December
  WHEN 'Mmmm' THEN DATENAME(MONTH, @Date)
--Mmmths as the first letter of the Mmmth
  WHEN 'Mmmmm' THEN CONVERT(CHAR(1), DATENAME(MONTH, @Date))
--Days as 1--31
  WHEN 'D' THEN CONVERT(VARCHAR(2), DATEPART(DAY, @Date))
--Days as 01--31
  WHEN 'Dd' THEN CONVERT(CHAR(2), @Date, 103)
--Days as Sun--Sat
  WHEN 'Ddd' THEN CONVERT(CHAR(3), DATENAME(WEEKDAY, @Date))
--Days as Sunday--Saturday
  WHEN 'Dddd' THEN DATENAME(WEEKDAY, @Date)
--Years as 00--99
  WHEN 'Yy' THEN CONVERT(CHAR(2), @Date, 12)
--Years as 1900--9999
  WHEN 'Yyyy' THEN DATENAME(YEAR, @Date)
  WHEN 'hh:mm:ss'
  THEN SUBSTRING(CONVERT(CHAR(30), @Date, @TwelveHourClock), 13, 8)
  WHEN 'hh:mm'
  THEN SUBSTRING(CONVERT(CHAR(30), @Date, @TwelveHourClock), 13, 5)
  WHEN 'hh:mm:ss:ms'
  THEN SUBSTRING(CONVERT(CHAR(30), @Date, @TwelveHourClock), 13, 12)
  WHEN 'h:mm:ss'
  THEN SUBSTRING(CONVERT(CHAR(30), @Date, @TwelveHourClock), 13, 8)
--tthe SQL Server BOL syntax, for compatibility
  WHEN 'hh:mi:ss:mmm'
  THEN SUBSTRING(CONVERT(CHAR(30), @Date, @TwelveHourClock), 13, 12)
  WHEN 'h:mm:ss:ms'
  THEN SUBSTRING(CONVERT(CHAR(30), @Date, @TwelveHourClock), 13, 12)
  WHEN 'H:m:s'
  THEN SUBSTRING(REPLACE(':' + SUBSTRING(CONVERT(CHAR(30), @Date, @TwelveHourClock),
                                         13, 8), ':0', ':'), 2, 30)
  WHEN 'H:m:s:ms'
  THEN SUBSTRING(REPLACE(':' + SUBSTRING(CONVERT(CHAR(30), @Date, @TwelveHourClock),
                                         13, 12), ':0', ':'), 2, 30)
--Hours as 00--23
  WHEN 'hh'
  THEN REPLACE(SUBSTRING(CONVERT(CHAR(30), @Date, @TwelveHourClock), 13, 2),
               ' ', '0')
--Hours as 0--23
  WHEN 'h'
  THEN LTRIM(SUBSTRING(CONVERT(CHAR(30), @Date, @TwelveHourClock), 13, 2))
--Minutes as 00--59
  WHEN 'Mi' THEN DATENAME(MINUTE, @Date)
  WHEN 'mm' THEN DATENAME(MINUTE, @Date)
  WHEN 'm' THEN CONVERT(VARCHAR(2), DATEPART(MINUTE, @Date))
--Seconds as 0--59
  WHEN 'ss' THEN DATENAME(SECOND, @Date)
--Seconds as 0--59
  WHEN 'S' THEN CONVERT(VARCHAR(2), DATEPART(SECOND, @Date))
--AM/PM
  WHEN 'ms' THEN DATENAME(MILLISECOND, @Date)
  WHEN 'mmm' THEN DATENAME(MILLISECOND, @Date)
  WHEN 'dy' THEN DATENAME(dy, @Date)
  WHEN 'qq' THEN DATENAME(qq, @Date)
  WHEN 'ww' THEN DATENAME(ww, @Date)
  WHEN '#'
  THEN REVERSE(SUBSTRING(REVERSE(CONVERT(CHAR(26), @Date, 109)), 1, 2))
  ELSE SUBSTRING(@fORMAT, 1, @pos - 1)
END;
                                SET @fORMAT = RTRIM(SUBSTRING(@fORMAT, @pos,
                                                              80));
                            END;
                    END;
          IF @Date = ''
            BEGIN
                SET @ReturnedDate = NULL;
            END;

        RETURN ISNULL(@ReturnedDate, '');
    END;
