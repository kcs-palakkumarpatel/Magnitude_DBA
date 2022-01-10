-- =============================================
-- Author:		<Vasudev Patel>
-- Create date: <23 Nov 2016>
-- Description:	<Description,,>
-- Exec: exec WsGetQuestionnerById 1931,'2019-07-15 11:16:07'
-- =============================================
CREATE PROCEDURE [dbo].[WsGetQuestionnerById]
    @Id BIGINT,
    @LastServerDate DATETIME
AS
BEGIN
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

    DECLARE @UpdateIdSeenClientId INT = NULL;
    SET @UpdateIdSeenClientId =
    (
        SELECT COUNT(1)
        FROM dbo.SeenClient
        WHERE Id = @SeenClientId
              AND ISNULL(UpdatedOn, CreatedOn) >= @LastServerDate
    );
	
    IF (@UpdateIdSeenClientId = 0)
    BEGIN
        SET @UpdateIdSeenClientId = 0;
    END;
    ELSE
    BEGIN
        SELECT @CaptureChartType = CASE CompareType
                                       WHEN 1 THEN
                                           'Average'
                                       ELSE
                                           'Benchmark'
                                   END
        FROM dbo.SeenClient
        WHERE Id = @SeenClientId;
    END;

    DECLARE @UpdateQuestionnerId BIGINT = NULL;
    SET @UpdateQuestionnerId =
    (
        SELECT COUNT(1)
        FROM dbo.Questionnaire
        WHERE Id = @QuestionnerId
              AND ISNULL(UpdatedOn, CreatedOn) >= @LastServerDate
    );
    IF (@UpdateQuestionnerId = 0)
    BEGIN
        SET @UpdateQuestionnerId = 0;
    END;
    ELSE
    BEGIN
        SELECT @FeedbackChartType = CASE CompareType
                                        WHEN 1 THEN
                                            'Average'
                                        ELSE
                                            'Benchmark'
                                    END
        FROM dbo.SeenClient
        WHERE Id = @QuestionnerId;
    END;

    DECLARE @UpdateIdSeenClientIdOption INT = NULL;
    SET @UpdateIdSeenClientIdOption =
    (
        SELECT COUNT(1)
        FROM dbo.SeenClientQuestions AS SCQ
            INNER JOIN dbo.SeenClientOptions AS SCO
                ON SCQ.Id = SCO.QuestionId
        WHERE SCQ.SeenClientId = @SeenClientId
              AND ISNULL(SCO.UpdatedOn, SCO.CreatedOn) >= @LastServerDate
    );
	
    IF (@UpdateIdSeenClientIdOption = 0)
    BEGIN
        SET @UpdateIdSeenClientIdOption = 0;
    END;
    ELSE
    BEGIN
        SELECT @CaptureChartType = CASE CompareType
                                       WHEN 1 THEN
                                           'Average'
                                       ELSE
                                           'Benchmark'
                                   END
        FROM dbo.SeenClient
        WHERE Id = @SeenClientId;
    END;

    DECLARE @UpdateQuestionnerIdOption INT = NULL;
    SET @UpdateQuestionnerIdOption =
    (
        SELECT COUNT(1)
        FROM dbo.Questions AS SCQ
            INNER JOIN dbo.Options AS SCO
                ON SCQ.Id = SCO.QuestionId
        WHERE SCQ.QuestionnaireId = @QuestionnerId
              AND ISNULL(SCO.UpdatedOn, SCO.CreatedOn) >= @LastServerDate
    );
    IF (@UpdateQuestionnerIdOption = 0)
    BEGIN
        SET @UpdateQuestionnerIdOption = 0;
    END;
    ELSE
    BEGIN
        SELECT @CaptureChartType = CASE CompareType
                                       WHEN 1 THEN
                                           'Average'
                                       ELSE
                                           'Benchmark'
                                   END
        FROM dbo.SeenClient
        WHERE Id = @SeenClientId;
    END;


    --IF NOT EXISTS
    --(
    --    SELECT 1
    --    FROM dbo.SeenClient
    --    WHERE Id = @SeenClientId
    --          AND ISNULL(UpdatedOn, CreatedOn) >= @LastServerDate
    --)
    --BEGIN
    --    PRINT 1;
    --    SET @SeenClientId = 0;
    --END;
    --ELSE
    --BEGIN
    --    PRINT 2;
    --    SELECT @CaptureChartType = CASE CompareType
    --                                   WHEN 1 THEN
    --                                       'Average'
    --                                   ELSE
    --                                       'Benchmark'
    --                               END
    --    FROM dbo.SeenClient
    --    WHERE Id = @SeenClientId;
    --END;


    --IF NOT EXISTS
    --(
    --    SELECT 1
    --    FROM dbo.Questionnaire
    --    WHERE Id = @QuestionnerId
    --          AND ISNULL(UpdatedOn, CreatedOn) >= @LastServerDate
    --)
    --BEGIN
    --    PRINT 3;
    --    SET @QuestionnerId = 0;
    --END;
    --ELSE
    --BEGIN
    --    PRINT 4;
    --    SELECT @FeedbackChartType = CASE CompareType
    --                                    WHEN 1 THEN
    --                                        'Average'
    --                                    ELSE
    --                                        'Benchmark'
    --                                END
    --    FROM dbo.SeenClient
    --    WHERE Id = @QuestionnerId;
    --END;

    --IF NOT EXISTS
    --(
    --    SELECT 1
    --    FROM dbo.SeenClientQuestions AS SCQ
    --        INNER JOIN dbo.SeenClientOptions AS SCO
    --            ON SCQ.Id = SCO.QuestionId
    --    WHERE SCQ.SeenClientId = @SeenClientId
    --          AND ISNULL(SCO.UpdatedOn, SCO.CreatedOn) >= @LastServerDate
    --)
    --BEGIN
    --    PRINT 5;
    --    SET @SeenClientOption = 0;
    --END;
    --ELSE
    --BEGIN
    --    PRINT 6;
    --    SELECT @CaptureChartType = CASE CompareType
    --                                   WHEN 1 THEN
    --                                       'Average'
    --                                   ELSE
    --                                       'Benchmark'
    --                               END
    --    FROM dbo.SeenClient
    --    WHERE Id = @SeenClientId;
    --END;

    --IF NOT EXISTS
    --(
    --    SELECT 1
    --    FROM dbo.Questions AS SCQ
    --        INNER JOIN dbo.Options AS SCO
    --            ON SCQ.Id = SCO.QuestionId
    --    WHERE SCQ.QuestionnaireId = @QuestionnerId
    --          AND ISNULL(SCO.UpdatedOn, SCO.CreatedOn) >= @LastServerDate
    --)
    --BEGIN
    --    PRINT 7;
    --    SET @QuestionnerIdOption = 0;
    --END;
    --ELSE
    --BEGIN
    --    PRINT 8;
    --    SELECT @CaptureChartType = CASE CompareType
    --                                   WHEN 1 THEN
    --                                       'Average'
    --                                   ELSE
    --                                       'Benchmark'
    --                               END
    --    FROM dbo.SeenClient
    --    WHERE Id = @SeenClientId;
    --END;
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
        PRINT 1;
        SELECT @SeenClientId = ISNULL(SeenClientId, 0)
        FROM dbo.EstablishmentGroup
        WHERE Id = @Id;
    END;
    ELSE IF (@UpdateIdSeenClientIdOption != 0)
    BEGIN
        PRINT 2;
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
        PRINT 4;
        SELECT @QuestionnerId = ISNULL(QuestionnaireId, 0)
        FROM dbo.EstablishmentGroup
        WHERE Id = @Id;
    END;

    SELECT ISNULL(@SeenClientId, 0) AS SeenClientId,
           ISNULL(@QuestionnerId, 0) AS QuestionnerId,
           ISNULL(@CaptureChartType, '') AS CaptureChartType,
           ISNULL(@FeedbackChartType, '') AS FeedbackChartType;
END;
