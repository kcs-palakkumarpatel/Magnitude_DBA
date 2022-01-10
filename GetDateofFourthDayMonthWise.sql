CREATE FUNCTION dbo.GetDateofFourthDayMonthWise
(
    @Day VARCHAR(100),
    @Date DATETIME,
    @No INT = 1
)
RETURNS DATETIME
AS
BEGIN
    DECLARE @FinalDate DATETIME,
            @CurrentDate DATETIME = @Date;

    DECLARE @FirstDate DATETIME = DATEADD(dd, (DATEPART(dd, @CurrentDate) * -1) + 1, @CurrentDate);
    DECLARE @DayName VARCHAR(20),
            @DayNo INT = 0,
            @DayToAdd INT = 21,
            @DayFor INT;
    SELECT @DayName = DATENAME(WEEKDAY, @FirstDate);

    DECLARE @Temp AS TABLE
    (
        Name VARCHAR(100),
        Number INT
    );
    INSERT INTO @Temp
    (
        Name,
        Number
    )
    SELECT 'Monday',
           1
    UNION
    SELECT 'Tuesday',
           2
    UNION
    SELECT 'Wednesday',
           3
    UNION
    SELECT 'Thursday',
           4
    UNION
    SELECT 'Friday',
           5
    UNION
    SELECT 'Saturday',
           6
    UNION
    SELECT 'Sunday',
           7;

    SELECT @DayNo = Number
    FROM @Temp
    WHERE Name = @DayName;
    SELECT @DayFor = Number
    FROM @Temp
    WHERE Name = @Day;

    IF (@DayFor < @DayNo)
    BEGIN
        IF (@No = 1)
        BEGIN
            SET @DayToAdd = 0;
        END;
        ELSE IF (@No = 2)
        BEGIN
            SET @DayToAdd = 7;
        END;
        ELSE IF (@No = 3)
        BEGIN
            SET @DayToAdd = 14;
        END;
        ELSE IF (@No = 4)
        BEGIN
            SET @DayToAdd = 21;
        END;
        ELSE IF (@No = 5)
        BEGIN
            SET @DayToAdd = 28;
        END;
        SELECT @FinalDate = DATEADD(DAY, (7 - @DayNo + @DayFor) + @DayToAdd, @FirstDate);
    END;
    ELSE
    BEGIN
        IF (@No = 1)
        BEGIN
            SELECT @FinalDate = DATEADD(DAY, (@DayFor - @DayNo), @FirstDate);
        END;
        ELSE IF (@No = 2)
        BEGIN
            SET @DayToAdd = 0;
            SELECT @FinalDate = DATEADD(DAY, (7 - @DayNo + @DayFor) + @DayToAdd, @FirstDate);
        END;
        ELSE IF (@No = 3)
        BEGIN
            SET @DayToAdd = 7;
            SELECT @FinalDate = DATEADD(DAY, (7 - @DayNo + @DayFor) + @DayToAdd, @FirstDate);
        END;
        ELSE IF (@No = 4)
        BEGIN
            SET @DayToAdd = 14;
            SELECT @FinalDate = DATEADD(DAY, (7 - @DayNo + @DayFor) + @DayToAdd, @FirstDate);
        END;
        ELSE IF (@No = 5)
        BEGIN
            SET @DayToAdd = 21;
            SELECT @FinalDate = DATEADD(DAY, (7 - @DayNo + @DayFor) + @DayToAdd, @FirstDate);
        END;
    END;

    IF (DATENAME(MONTH, @Date) != DATENAME(MONTH, @FinalDate))
    BEGIN
        SET @FinalDate = NULL;
    END;
    RETURN @FinalDate;
END;

