/*
=============================================
Author:		<Author,,GD>
Create date: <Create Date,,10 Jun 2015>
Description:	<Description,,>
Call SP:		WSGetAppUserActivityByAppUserId 1243, ''
=============================================
*/
CREATE PROCEDURE dbo.WSGetAppUserActivityByAppUserIdBackup
    @AppUserId BIGINT ,
    @LastServerDate DATETIME = NULL
AS
    BEGIN
        SET NOCOUNT OFF;

		DECLARE @EstablishmentCountByActivityId BIGINT;
        SELECT  @EstablishmentCountByActivityId = KeyValue
        FROM    dbo.AAAAConfigSettings
        WHERE   KeyName = 'EstablishmentCountByActivityId';

        SELECT  Eg.Id AS ActivityId ,
                Eg.EstablishmentGroupName AS ActivityName ,
                Eg.EstablishmentGroupType AS ActivityType ,
                UE.NotificationStatus AS IsNotificationOn ,
                ISNULL(Eg.SeenClientId, 0) AS SeenClientId ,
                Eg.AllowRecurring AS IsAllowedRecurring ,
                ISNULL(CASE Eg.EstablishmentGroupType
                         WHEN 'Customer' THEN CAST(0 AS BIT)
                         ELSE Eg.AllowToChangeDelayTime
                       END, 0) AS IsAllowToChangeDelayTime ,
                ISNULL(UE.DelayTime, Eg.DelayTime) AS DelayTime ,
                ISNULL(TellUs.QuestionnaireId, 0) AS QuestionnaireId ,
                CAST (CASE WHEN ISNULL(TellUs.QuestionnaireId, 0) = 0 THEN 0
                           ELSE dbo.IsTellUsSubmitted(@AppUserId, Eg.Id)
                      END AS BIT) AS IsTellUsSubmitted ,
                HowItWorks ,
                Eg.QuestionnaireId AS MasterQuestionnaireId ,
                Q.QuestionnaireType ,
                dbo.GetSmileFaceByActivityId(Eg.Id, Eg.SmileOn, @AppUserId) AS SmileType ,
                Eg.SMSReminder ,
                Eg.EmailReminder ,
                ISNULL(CAST(CASE WHEN TellUs.QuestionnaireId IS NOT NULL
                                 THEN 0
                                 ELSE 1
                            END AS BIT), 0) AS IsTellUsActivity ,
                Eg.ContactQuestion AS ContactQuestionID ,
                CASE WHEN ( SELECT  COUNT(1)
                            FROM    dbo.Establishment
                            WHERE   EstablishmentGroupId = Eg.Id
                          ) > @EstablishmentCountByActivityId
                     THEN CAST(1 AS BIT)
                     ELSE CAST(0 AS BIT)
                END IsPaging ,
                CASE WHEN UE.EstablishmentType = 'Sales' THEN CAST(1 AS BIT)
                     ELSE CAST(0 AS BIT)
                END AS IsDisplayForCapture ,
                ISNULL(DC.ContactId, 0) AS DefaultContactId ,
                ISNULL(DC.IsGroup, 'false') AS IsGroup,
				(SELECT dbo.GetBadgeCountForActivity(@AppUserId,Eg.Id)) AS BadgeCount,
				CASE ISNULL(Eg.AttachmentLimit,0) WHEN 0 THEN 10 ELSE Eg.AttachmentLimit end AS AttachmentLimit,
				Eg.AutoSaveLimit AS AutoSaveLimit,
				(CASE WHEN UE.EstablishmentType = 'Sales' THEN COUNT(DISTINCT SCA.Id)
				ELSE COUNT(DISTINCT AM.Id) END) AS Unresolved,
				(select dbo.GetBadgeCountINOUT(@AppUserId,Eg.Id,0,1)) AS OUTCount,
				(select dbo.GetBadgeCountINOUT(@AppUserId,Eg.Id,0,0)) AS InCount
				/*--dbo.GetContactQuestionbyUserIdAndActivityId(@AppUserId,Eg.Id,@LastServerDate) AS ContactQuestionID */
        FROM    dbo.AppUserEstablishment AS UE
                INNER JOIN dbo.Establishment AS E ON UE.EstablishmentId = E.Id
                INNER JOIN dbo.EstablishmentGroup AS Eg ON E.EstablishmentGroupId = Eg.Id
                INNER JOIN dbo.HowItWorks AS HIW ON Eg.HowItWorksId = HIW.Id
                LEFT OUTER JOIN dbo.EstablishmentGroup AS TellUs ON Eg.EstablishmentGroupId = TellUs.Id
				LEFT OUTER JOIN dbo.SeenClientAnswerMaster AS SCA ON SCA.EstablishmentId = E.Id AND SCA.IsDeleted = 0 AND SCA.IsResolved = 'Unresolved'
				LEFT OUTER JOIN dbo.AnswerMaster AS AM ON AM.EstablishmentId = E.Id AND AM.IsDeleted = 0 AND AM.IsResolved = 'Unresolved'
                INNER JOIN dbo.Questionnaire Q ON Q.Id = Eg.QuestionnaireId
                LEFT JOIN dbo.DefaultContact AS DC WITH ( NOLOCK ) ON Eg.Id = ISNULL(DC.ActivityId,
                                                              0)
                                                              AND ISNULL(DC.AppUserId,
                                                              0) = @AppUserId
                                                              AND DC.IsDeleted = 0
        WHERE   UE.AppUserId = @AppUserId
                AND UE.IsDeleted = 0
                AND ( ISNULL(UE.UpdatedOn, UE.CreatedOn) >= @LastServerDate
                      OR ISNULL(Eg.UpdatedOn, Eg.CreatedOn) >= @LastServerDate
                      OR ISNULL(HIW.UpdatedOn, HIW.CreatedOn) >= @LastServerDate
                      OR dbo.AnswerMaserLastCreatedorUpdatedDate(@AppUserId,
                                                              Eg.Id) >= @LastServerDate
                      OR @LastServerDate IS NULL
                    )
			GROUP BY Eg.Id ,
                Eg.EstablishmentGroupName ,
                Eg.EstablishmentGroupType ,
                UE.NotificationStatus ,
                Eg.SeenClientId ,
                Eg.AllowRecurring ,
                Eg.AllowToChangeDelayTime ,
                UE.DelayTime ,
                Eg.DelayTime ,
                TellUs.QuestionnaireId ,
                HowItWorks ,
                Eg.QuestionnaireId ,
                Q.QuestionnaireType ,
                Eg.SMSReminder ,
                Eg.EmailReminder ,
                Eg.SmileOn ,
                Eg.ContactQuestion ,
                UE.EstablishmentType ,
                DC.ContactId ,
                DC.IsGroup,
				EG.DisplaySequence,
				Eg.AttachmentLimit,
				Eg.AutoSaveLimit
				--E.Id
			ORDER BY CASE ISNULL(EG.DisplaySequence,0) WHEN 0 THEN 99999 ELSE Eg.DisplaySequence END , Eg.EstablishmentGroupName ASC;

        SET NOCOUNT ON;
    END;
