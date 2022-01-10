
-- =============================================
-- Author:		<Vasu Patel>
-- Create date: <05 Jan 2016>
-- Description:	<Questionnaire form Type by EstablishmentId>
-- Call: GetQuestionnaireFormTypeByEstablishMentId @EstablishmentId=10036
-- =============================================
CREATE PROCEDURE [dbo].[GetQuestionnaireFormTypeByEstablishMentId_111721] @EstablishmentId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Q.QuestionnaireFormType,
           Q.LastTestDate,
           Q.TestTime,
           E.ThankYouMessage,
           Q.FixedBenchMark,
           DateCheck = CASE
                           WHEN Q.LastTestDate >= CONVERT(DATE, DATEADD(MINUTE, E.TimeOffSet, GETUTCDATE()), 103) THEN
                               1
                           ELSE
                               0
                       END
    FROM dbo.Establishment AS E WITH (NOLOCK)
        INNER JOIN dbo.EstablishmentGroup EG WITH (NOLOCK)
            ON E.EstablishmentGroupId = EG.Id
        INNER JOIN dbo.Questionnaire AS Q WITH (NOLOCK)
            ON Q.Id = EG.QuestionnaireId
    WHERE E.Id = @EstablishmentId
    GROUP BY Q.QuestionnaireFormType,
             Q.LastTestDate,
             Q.TestTime,
             E.ThankYouMessage,
             Q.FixedBenchMark,
             Q.LastTestDate,
             E.TimeOffSet;
    SET NOCOUNT OFF;
END;
