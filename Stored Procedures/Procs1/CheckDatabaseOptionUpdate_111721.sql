
-- =============================================
-- Author:      <Author, , Anant>
-- Create Date: <Create Date, , 02 jul-2019>
-- Description: <Description, , get Database refernce option List >
-- Call : EXEC CheckDatabaseOptionUpdate "32837", 'anant',0
-- =============================================
CREATE PROCEDURE [dbo].[CheckDatabaseOptionUpdate_111721]
    @QuestionsId BIGINT,
    @Detail NVARCHAR(MAX),
    @IsMobi BIT
AS
BEGIN
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

END;
