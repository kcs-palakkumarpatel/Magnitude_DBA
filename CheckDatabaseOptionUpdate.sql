-- =============================================
-- Author:      <Author, , Anant>
-- Create Date: <Create Date, , 02 jul-2019>
-- Description: <Description, , get Database refernce option List >
-- Call : EXEC CheckDatabaseOptionUpdate "32837", 'anant',0
-- =============================================
CREATE PROCEDURE dbo.CheckDatabaseOptionUpdate
    @QuestionsId BIGINT,
    @Detail NVARCHAR(MAX),
    @IsMobi BIT
AS
BEGIN
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
	SET NOCOUNT ON;

    DECLARE @IsCheck BIT;
    IF (@IsMobi = 0)
    BEGIN
        IF EXISTS
        (
            SELECT Data
            FROM dbo.Split(@Detail, ',')
            WHERE Data NOT IN (
                                  SELECT Name
                                  FROM dbo.SeenClientOptions
                                  WHERE QuestionId = @QuestionsId
                                        AND IsDeleted = 0
                              )
        )
        BEGIN
            SET @IsCheck = 'true';
			PRINT @IsCheck
            RETURN @IsCheck;
        END;
    END;
    ELSE
    BEGIN
        IF EXISTS
        (
            SELECT Data
            FROM dbo.Split(@Detail, ',')
            WHERE Data NOT IN (
                                  SELECT Name
                                  FROM dbo.Options
                                  WHERE QuestionId = @QuestionsId
                                        AND IsDeleted = 0
                              )
        )
        BEGIN
            SET @IsCheck = 'true';
			PRINT @IsCheck
            RETURN @IsCheck;
        END;
    END;
END TRY

BEGIN CATCH
	INSERT INTO dbo.ErrorLog
        (
            PageId,
            MethodName,
            ErrorType,
            ErrorMessage,
            ErrorDetails,
            ErrorDate,
            UserId,
            Solution,
            CreatedOn,
            CreatedBy
        )
        VALUES
        (ERROR_LINE(),
         'dbo.CheckDatabaseOptionUpdate',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         N'',
         @QuestionsId+','+@Detail+','+@IsMobi,
         GETUTCDATE(),
         N''
        );
END CATCH

    SET NOCOUNT OFF;


END;
