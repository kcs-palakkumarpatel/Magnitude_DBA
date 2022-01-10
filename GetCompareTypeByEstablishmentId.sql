-- =============================================
-- Author:		<Vasu Patel>
-- Create date: <28 Dec 2015>
-- Description:	<Get Compare Type by EstablishmentGroupId>
-- Call: GetCompareTypeByEstablishmentId 20043
-- =============================================
CREATE PROCEDURE [dbo].[GetCompareTypeByEstablishmentId]
    @EstablishmentId BIGINT ---- Establishment Group Id
AS
    BEGIN
        SELECT  TOP 1 CompareType,CONVERT(DATE,DATEADD(MINUTE,E.TimeOffSet,GETUTCDATE()),103) AS CurrentDate
        FROM    dbo.Questionnaire Q
                INNER JOIN dbo.EstablishmentGroup EG ON EG.QuestionnaireId = Q.Id
                INNER JOIN dbo.Establishment E ON E.EstablishmentGroupId = EG.Id
        WHERE   EG.Id = @EstablishmentId;
    END;