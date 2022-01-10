CREATE FUNCTION dbo.EmailBlackListCheck (@EmailId [NVARCHAR](1000))
RETURNS INT
WITH EXECUTE AS CALLER
AS
BEGIN
    DECLARE @count INT,
            @Return INT;

    DECLARE @EmailTable TABLE
    (
        Id BIGINT IDENTITY(1, 1),
        EmailId NVARCHAR(1000)
    );

    INSERT INTO @EmailTable
    SELECT DATA
    FROM dbo.SPLIT(@EmailId, ',');

    DECLARE @Counter INT,
            @TotalCount INT;
    SET @Counter = 1;
    SET @TotalCount =
    (
        SELECT COUNT(*) FROM @EmailTable
    );

    WHILE (@Counter <= @TotalCount)
    BEGIN

        DECLARE @RowEmailId NVARCHAR(1000);

        SELECT @RowEmailId = EmailId
        FROM @EmailTable
        WHERE Id = @Counter;

        SELECT @count = COUNT(1)
        FROM dbo.BlackListEmail
        WHERE UPPER(RTRIM(LTRIM(EmailId))) = UPPER(RTRIM(LTRIM(@RowEmailId)))
              AND IsDeleted = 0;

        SET @Counter = @Counter + 1;
        CONTINUE;
    END;

    IF @count > 0
    BEGIN
        SET @Return = 100;
    END;
    ELSE
    BEGIN
        SET @Return = 0;
    END;

    RETURN @Return;
END;
