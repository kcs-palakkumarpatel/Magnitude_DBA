
-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,24 Jun 2015>
-- Description:	<Description,,>
-- Call SP:		WsGetContactGroupDetilsForFeedbackDetailById 21162
-- =============================================
CREATE PROCEDURE  [dbo].[WsGetContactGroupDetilsForFeedbackDetailById_111921]
    @SeenClientAnswerMasterId BIGINT
AS
    BEGIN
        SELECT  Cq.Id AS QuestionId ,
                Cq.QuestionTypeId ,
                QuestionTitle ,
                ISNULL(dbo.GetContactDetailsForGroupFeedback(@SeenClientAnswerMasterId, Cq.Id),'') AS Detail

        FROM   dbo.SeenClientAnswerMaster AM
				LEFT JOIN  dbo.SeenClientAnswerChild AC ON AC.SeenClientAnswerMasterId=AM.Id
				left JOIN dbo.ContactGroupRelation AS CGR ON CGR.ContactMasterId = ISNULL(AC.ContactMasterId,AM.ContactMasterId)
				INNER JOIN dbo.ContactMaster AS Cm ON Cm.Id=ISNULL(AC.ContactMasterId,AM.ContactMasterId) --CGR.ContactMasterId
				INNER JOIN dbo.ContactDetails AS Cd ON Cd.ContactMasterId =Cm.Id
				INNER JOIN dbo.ContactQuestions AS Cq ON Cq.Id=Cd.ContactQuestionId AND Cq.Id IN (SELECT ColumnValue AS ContactQuestionId FROM dbo.ConvertStringToTable(
								(SELECT ContactQuestion FROM dbo.EstablishmentGroup as EG INNER JOIN Establishment AS E ON EG.Id=E.EstablishmentGroupId
								WHERE E.Id=AM.EstablishmentId),','))
        WHERE   Cq.IsDeleted = 0
				AND Cq.IsDisplayInDetail=1
				AND AM.Id=@SeenClientAnswerMasterId
        GROUP BY Cq.Id ,
		Cq.Position,
                Cq.QuestionTypeId ,
                QuestionTitle
				ORDER BY Cq.Position ASC
    END;
