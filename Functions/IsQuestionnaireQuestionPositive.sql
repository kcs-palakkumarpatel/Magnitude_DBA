CREATE FUNCTION [dbo].[IsQuestionnaireQuestionPositive]
(
    @AnswerMasterID BIGINT,
    @QuestionId BIGINT,
    @AnswerID BIGINT
)
RETURNS INT
AS
BEGIN
    DECLARE @IsPass INT = 0;
    SET @IsPass =
    (
        SELECT TOP 1 CASE
                   WHEN ISNULL(QR.EscalationValue, 0) > 0 THEN
            (CASE
                 WHEN ISNULL(SCO.Weight, 0) > QR.EscalationValue THEN
                     1
                 ELSE
                     2
             END
            )
                   ELSE
            (CASE
                 WHEN ISNULL(Q.EscalationValue, 0) > 0 THEN
                     CASE
                         WHEN ISNULL(SCO.Weight, 0) > ISNULL(Q.EscalationValue, 0) THEN
                             1
                         ELSE
                             2
                     END
                 ELSE
                     0
             END
            )
               END
        FROM dbo.AnswerMaster AM
            INNER JOIN dbo.Questionnaire QR
                ON AM.QuestionnaireId = QR.Id
            INNER JOIN dbo.Answers A
                ON A.QuestionId = @QuestionId
                   AND A.Id = @AnswerID
                   AND AM.Id = @AnswerMasterID
            INNER JOIN dbo.Questions Q
                ON Q.Id = @QuestionId
				INNER JOIN dbo.Options SCO
                ON SCO.QuestionId = Q.Id
                   AND SCO.Id IN (
                                     SELECT Data FROM dbo.Split(A.OptionId, ',')
                                 )
    );
    RETURN @IsPass;
END;
