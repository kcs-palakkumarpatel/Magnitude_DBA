-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,18 Jun 2015>
-- Description:	<Description,,>
-- Call SP:		WSGetTellUsActivityDataByOriginalActivityId 1
-- =============================================
CREATE PROCEDURE [dbo].[WSGetTellUsActivityDataByOriginalActivityId] @ActivityId BIGINT
AS 
    BEGIN
        SELECT TOP 1 Eg.Id ,
                Eg.GroupId ,
                Eg.EstablishmentGroupName ,
                Eg.EstablishmentGroupType ,
                Eg.AboutEstablishmentGroup ,
                Eg.QuestionnaireId ,
                ISNULL(Eg.SeenClientId, 0) AS SeenClientId ,
                Eg.HowItWorksId ,
                Eg.SMSReminder ,
                Eg.EmailReminder ,
                Eg.EstablishmentGroupId ,
                Eg.AllowToChangeDelayTime ,
                Eg.DelayTime ,
                Eg.AllowRecurring,
				E.Id AS EstablishmentId
        FROM    EstablishmentGroup AS OEg
                INNER JOIN EstablishmentGroup AS Eg ON OEg.EstablishmentGroupId = Eg.Id
				INNER JOIN dbo.Establishment AS E ON Eg.Id = E.EstablishmentGroupId
				WHERE OEg.Id = @ActivityId AND E.IsDeleted = 0
    END