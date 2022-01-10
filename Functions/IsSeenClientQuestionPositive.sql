--SELECT * FROM dbo.QuestionType WHERE Id IN ( 1, 2, 5, 6, 18, 21, 7, 14, 15 )

CREATE FUNCTION dbo.IsSeenClientQuestionPositive
(
    @SeenClientAnswerMasterID BIGINT,
    @QuestionId BIGINT,
    @SeenClientAnswers BIGINT
)
RETURNS INT
AS
BEGIN
    DECLARE @IsPass INT = 0;
    SET @IsPass =
    (
        SELECT CASE
                   WHEN ISNULL(SC.EscalationValue, 0) > 0 THEN
            (CASE
                 WHEN ISNULL(SUM(SCO.Weight), 0) > SC.EscalationValue THEN
                     1
                 ELSE
                     2
             END
            )
                   ELSE
            (CASE
                 WHEN ISNULL(SCQ.EscalationValue, 0) > 0 THEN
                     CASE
                         WHEN ISNULL(SUM(SCO.Weight), 0) > ISNULL(SCQ.EscalationValue, 0) THEN
                             1
                         ELSE
                             2
                     END
                 ELSE
                     0
             END
            )
               END
        FROM dbo.SeenClientAnswerMaster SCA
            INNER JOIN dbo.SeenClient SC
                ON SCA.SeenClientId = SC.Id
            INNER JOIN dbo.SeenClientAnswers SA
                ON SA.QuestionId = @QuestionId
                   AND SA.Id = @SeenClientAnswers
                   AND SCA.Id = @SeenClientAnswerMasterID
            INNER JOIN dbo.SeenClientQuestions SCQ
                ON SCQ.Id = @QuestionId
            INNER JOIN dbo.SeenClientOptions SCO
                ON SCO.QuestionId = SCQ.Id
                   AND SCO.Id IN (
                                     SELECT Data FROM dbo.Split(SA.OptionId, ',')
                                 )
        GROUP BY SA.Id,
                 SC.EscalationValue,
                 SCQ.EscalationValue
    );
    RETURN @IsPass;
END;
