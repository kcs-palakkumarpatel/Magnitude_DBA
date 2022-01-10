-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 26 May 2015>
-- Description:	<Description,,GetQuestionnaireById>
-- Call SP    :	GetQuestionnaireById
-- =============================================
CREATE PROCEDURE dbo.GetQuestionnaireById @Id BIGINT
AS
BEGIN
    DECLARE @SeenClientId BIGINT,
            @ContactId BIGINT;
    SELECT @SeenClientId = SQ.SeenClientId
    FROM dbo.Questions AS Q
        INNER JOIN dbo.SeenClientQuestions AS SQ
            ON Q.SeenClientQuestionIdRef = SQ.Id
    WHERE Q.QuestionnaireId = @Id;

    SELECT @ContactId = CQ.ContactId
    FROM dbo.Questions AS Q
        INNER JOIN dbo.ContactQuestions AS CQ
            ON Q.ContactQuestionIdRef = CQ.Id
    WHERE Q.QuestionnaireId = @Id
          AND Q.IsDeleted = 0;

    SELECT [Id] AS Id,
           [QuestionnaireTitle] AS QuestionnaireTitle,
           [QuestionnaireType] AS QuestionnaireType,
           [Description] AS Description,
           QuestionnaireFormType,
           ISNULL(@SeenClientId, 0) AS SeenClientId,
           ISNULL(CompareType, 0) AS CompareType,
           FixedBenchMark,
           LastTestDate,
           TestTime,
           EscalationValue,
           IsMultipleRouting,
           ISNULL(@ContactId, 0) AS ContactId,
           ISNULL(ControlStyleId, 1) AS ControlStyleId,
           (CASE
                WHEN ISNULL(
                     (
                         SELECT 1
                         FROM dbo.Questions Q
                         WHERE Q.QuestionnaireId = @Id
                               AND ISNULL(Q.IsForReminder, 0) = 1
							     AND ISNULL(Q.IsDeleted, 0) = 0
                     ),
                     0
                           ) = 0 THEN
                    0
                ELSE
                    1
            END
           ) AS IsForReminderavailable
    FROM dbo.[Questionnaire]
    WHERE [Id] = @Id;
END;
