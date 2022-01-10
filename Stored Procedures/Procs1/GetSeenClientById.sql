-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,, 28 May 2015>
-- Description:	<Description,,GetSeenClientById>
-- Call SP    :	GetSeenClientById 3738
-- =============================================
CREATE PROCEDURE dbo.GetSeenClientById @Id BIGINT
AS
BEGIN
    DECLARE @ContactId BIGINT;

    SELECT @ContactId = Cq.ContactId
    FROM dbo.SeenClientQuestions AS SQ
        INNER JOIN dbo.ContactQuestions AS Cq
            ON Cq.Id = SQ.ContactQuestionId
    WHERE SQ.SeenClientId = @Id;

    SELECT [Id] AS Id,
           [SeenClientTitle] AS SeenClientTitle,
           [Description] AS Description,
           ISNULL(@ContactId, 0) AS ContactId,
           ISNULL(CompareType, 0) AS CompareType,
           FixedBenchMark,
           EscalationValue,
           ISNULL(IsForTender, 0) AS IsForTender,
           ISNULL(
           (
               SELECT 1
               FROM dbo.SeenClientQuestions
               WHERE SeenClientId = @Id
                     AND ISNULL(TenderQuestionType, 0) = 1
           ),
           0
                 ) AS IsReleasedQueAllow,
           ISNULL(
           (
               SELECT 1
               FROM dbo.SeenClientQuestions
               WHERE SeenClientId = @Id
                     AND ISNULL(TenderQuestionType, 0) = 2
           ),
           0
                 ) AS IsMobiExpiredQueAllow,
           ISNULL(
           (
               SELECT 1
               FROM dbo.SeenClientQuestions
               WHERE SeenClientId = @Id
                     AND ISNULL(TenderQuestionType, 0) = 3
           ),
           0
                 ) AS IsGrayoutQueAllow,
           ISNULL(
           (
               SELECT 1
               FROM dbo.SeenClientQuestions
               WHERE SeenClientId = @Id
                     AND ISNULL(TenderQuestionType, 0) = 4
           ),
           0
                 ) AS IsReminderQueAllow
    FROM dbo.[SeenClient]
    WHERE [Id] = @Id;
END;
