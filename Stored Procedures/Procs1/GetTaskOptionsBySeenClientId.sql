-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,20 Jun 2015>
-- Description:	<Description,,>
-- Call SP:		GetTaskOptionsBySeenClientId 0,7915, 1
-- =============================================
CREATE PROCEDURE dbo.GetTaskOptionsBySeenClientId
    @SeenClientId BIGINT,
    @ActivityId BIGINT = 0,
	@IsWeb BIT = 0
AS
BEGIN
    DECLARE @ID BIGINT = @SeenClientId;
    IF (@SeenClientId <= 0 AND @ActivityId > 0)
    BEGIN
	  PRINT '1'
        SELECT @ID = SeenClientId
        FROM dbo.EstablishmentGroup
        WHERE Id = @ActivityId;
    END;
	PRINT @ID
    SELECT O.Id AS OptionId,
           RTRIM(LTRIM(O.Name)) AS OptionName,
           Q.Id AS QuestionId,
           RTRIM(LTRIM(O.Value)) AS OptionValue,
		   Q.QuestionTypeId
    FROM dbo.SeenClientOptions AS O
        INNER JOIN dbo.SeenClientQuestions AS Q
            ON O.QuestionId = Q.Id
    WHERE Q.SeenClientId = @ID
          AND O.IsDeleted = 0
          AND Q.IsDeleted = 0
          AND Q.QuestionTypeId <> 26 AND (O.Value <> '-- Select --' OR @IsWeb = 0)
    ORDER BY Q.Id,
             O.Position;
END;
