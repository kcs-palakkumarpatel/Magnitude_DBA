CREATE function dbo.GetLastDateByMonth
(
    @Day VARCHAR(100),
	@Date DATETIME 
)
RETURNS DATETIME
AS
BEGIN
    DECLARE @LasDateOfMonth DATETIME = DATEADD(d, -1, DATEADD(m, DATEDIFF(m, 0, @Date) + 1, 0)),
            @ReturnDate DATETIME;
    DECLARE @TempLastWeek AS TABLE
    (
        LastDate DATETIME,
        Name VARCHAR(50)
    );
    INSERT INTO @TempLastWeek
    (
        LastDate,
        Name
    )
    SELECT DATEADD(DAY, -6, @LasDateOfMonth),
           DATENAME(WEEKDAY, DATEADD(DAY, -6, @LasDateOfMonth))
    UNION
    SELECT DATEADD(DAY, -5, @LasDateOfMonth),
           DATENAME(WEEKDAY, DATEADD(DAY, -5, @LasDateOfMonth))
    UNION
    SELECT DATEADD(DAY, -4, @LasDateOfMonth),
           DATENAME(WEEKDAY, DATEADD(DAY, -4, @LasDateOfMonth))
    UNION
    SELECT DATEADD(DAY, -3, @LasDateOfMonth),
           DATENAME(WEEKDAY, DATEADD(DAY, -3, @LasDateOfMonth))
    UNION
    SELECT DATEADD(DAY, -2, @LasDateOfMonth),
           DATENAME(WEEKDAY, DATEADD(DAY, -4, @LasDateOfMonth))
    UNION
    SELECT DATEADD(DAY, -1, @LasDateOfMonth),
           DATENAME(WEEKDAY, DATEADD(DAY, -1, @LasDateOfMonth))
    UNION
    SELECT @LasDateOfMonth,
           DATENAME(WEEKDAY, @LasDateOfMonth);
    SELECT @ReturnDate = LastDate
    FROM @TempLastWeek
    WHERE Name = @Day;
    RETURN @ReturnDate;
END;

