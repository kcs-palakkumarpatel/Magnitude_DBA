
-- =============================================
-- Author:		<Vasudev Patel>
-- Create date: <23 Nov 2016>
-- Description:	<Description,,>
-- =============================================
/*
Exec: exec WsGetQuestionnerById_OfflineAPI 1931,'2019-07-15 11:16:07'

Drop procedure WsGetQuestionnerById_OfflineAPI
*/
CREATE PROCEDURE [dbo].[WsGetQuestionnerById_OfflineAPI]
    @Id BIGINT,
    @LastServerDate DATETIME
AS
BEGIN
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
    --SET @LastServerDate = '';
    DECLARE @SeenClientId BIGINT;
    DECLARE @QuestionnerId BIGINT;
    DECLARE @FeedbackChartType VARCHAR(15);
    DECLARE @CaptureChartType VARCHAR(15);
    DECLARE @SeenClientOption BIGINT;
    DECLARE @QuestionnerIdOption BIGINT;

    SELECT @QuestionnerId = ISNULL(QuestionnaireId, 0),
           @SeenClientId = ISNULL(SeenClientId, 0)
    FROM dbo.EstablishmentGroup
    WHERE Id = @Id;

    DECLARE @UpdateIdSeenClientId INT = 0;
    SET @UpdateIdSeenClientId =
    (
        SELECT COUNT(1)
        FROM dbo.SeenClient
        WHERE Id = @SeenClientId
        AND ISNULL(UpdatedOn, CreatedOn) >= @LastServerDate
    );
	
    IF (@UpdateIdSeenClientId <> 0)
    BEGIN
        SELECT @CaptureChartType = CASE CompareType WHEN 1 THEN 'Average' ELSE 'Benchmark' END
        FROM dbo.SeenClient
        WHERE Id = @SeenClientId;
    END;

    DECLARE @UpdateQuestionnerId BIGINT = 0;
    SET @UpdateQuestionnerId =
    (
        SELECT COUNT(1)
        FROM dbo.Questionnaire
        WHERE Id = @QuestionnerId
        AND ISNULL(UpdatedOn, CreatedOn) >= @LastServerDate
    );
    
	IF (@UpdateQuestionnerId <> 0)
    BEGIN
        SELECT @FeedbackChartType = CASE CompareType WHEN 1 THEN 'Average' ELSE 'Benchmark' END
        FROM dbo.SeenClient
        WHERE Id = @QuestionnerId;
    END;

    DECLARE @UpdateIdSeenClientIdOption INT = 0;
    SET @UpdateIdSeenClientIdOption =
    (
        SELECT COUNT(1)
        FROM dbo.SeenClientQuestions AS SCQ
        INNER JOIN dbo.SeenClientOptions AS SCO ON SCQ.Id = SCO.QuestionId
        WHERE SCQ.SeenClientId = @SeenClientId
        AND ISNULL(SCO.UpdatedOn, SCO.CreatedOn) >= @LastServerDate
    );
	
    IF (@UpdateIdSeenClientIdOption <> 0)
    BEGIN
        SELECT @CaptureChartType = CASE CompareType WHEN 1 THEN 'Average' ELSE 'Benchmark' END
        FROM dbo.SeenClient
        WHERE Id = @SeenClientId;
    END;

    DECLARE @UpdateQuestionnerIdOption INT = 0;
    SET @UpdateQuestionnerIdOption =
    (
        SELECT COUNT(1)
        FROM dbo.Questions AS SCQ
        INNER JOIN dbo.Options AS SCO ON SCQ.Id = SCO.QuestionId
        WHERE SCQ.QuestionnaireId = @QuestionnerId
        AND ISNULL(SCO.UpdatedOn, SCO.CreatedOn) >= @LastServerDate
    );
    
	IF (@UpdateQuestionnerIdOption <> 0)
    BEGIN
        SELECT @CaptureChartType = CASE CompareType WHEN 1 THEN 'Average' ELSE 'Benchmark' END
        FROM dbo.SeenClient
        WHERE Id = @SeenClientId;
    END;

	IF (@UpdateQuestionnerId = 0 AND @UpdateQuestionnerIdOption =0)
    BEGIN
        SET @QuestionnerId = 0;
    END;
   
    IF (@UpdateIdSeenClientId = 0 AND @UpdateIdSeenClientIdOption = 0)
    BEGIN
        SET @SeenClientId = 0;
    END;

    IF (@UpdateIdSeenClientId != 0)
    BEGIN
        SELECT @SeenClientId = ISNULL(SeenClientId, 0)
        FROM dbo.EstablishmentGroup
        WHERE Id = @Id;
    END;
    ELSE IF (@UpdateIdSeenClientIdOption != 0)
    BEGIN
        SELECT @SeenClientId = ISNULL(SeenClientId, 0)
        FROM dbo.EstablishmentGroup
        WHERE Id = @Id;
    END;
    ELSE IF (@UpdateQuestionnerId != 0)
    BEGIN
        SELECT @QuestionnerId = ISNULL(QuestionnaireId, 0)
		FROM dbo.EstablishmentGroup
        WHERE Id = @Id;
    END;
    ELSE IF (@UpdateQuestionnerIdOption != 0)
    BEGIN
        SELECT @QuestionnerId = ISNULL(QuestionnaireId, 0)
        FROM dbo.EstablishmentGroup
        WHERE Id = @Id;
    END;

    SELECT ISNULL(@SeenClientId, 0) AS SeenClientId,
           ISNULL(@QuestionnerId, 0) AS QuestionnerId,
           ISNULL(@CaptureChartType, '') AS CaptureChartType,
           ISNULL(@FeedbackChartType, '') AS FeedbackChartType;
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
         'dbo.WsGetQuestionnerById_OfflineAPI',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         ISNULL(@Id,0),
         @Id+','+@LastServerDate,
         GETUTCDATE(),
         ISNULL(@Id,0)
        );
END CATCH
END;
