--	=============================================
--	Author:			D3
--	Create date:	09-Nov-2017
--	Description:	
--	Call SP:	dbo.WSGetAppUserActivityByAppUserId 1615, ''
--	=============================================
CREATE PROCEDURE dbo.WSGetAppUserActivityByAppUserId_Final
    @AppUserId BIGINT ,
    @LastServerDate DATETIME = NULL
AS
    BEGIN
        SET NOCOUNT ON;

        DECLARE @EstablishmentCountByActivityId BIGINT;
        SELECT  @EstablishmentCountByActivityId = KeyValue
        FROM    dbo.AAAAConfigSettings
        WHERE   KeyName = 'EstablishmentCountByActivityId';

		CREATE TABLE #CountTable
		(
			ActivityId BIGINT,
			BadgeCount INT,
			InCount INT,
			OUTCount INT,
			ResponseCount INT,
			Unresolved INT
		)

		INSERT INTO #CountTable
		        EXEC dbo.GetActivityCountByAppUserId @AppUserId
		        

				             SELECT DISTINCT
                        IIF(ISNULL(T.DisplaySequence, 0) = 0, 99999, T.DisplaySequence) AS DisplaySequence ,
                        T.ActivityName ,
                        T.ActivityId ,
                        T.ActivityType ,
                        T.IsNotificationOn ,
                        T.SeenClientId ,
                        T.IsAllowedRecurring ,
                        T.IsAllowToChangeDelayTime ,
                        T.DelayTime ,
                        T.HowItWorks ,
                        T.MasterQuestionnaireId ,
                        T.QuestionnaireType ,
                        T.SmileType ,
                        T.SMSReminder ,
                        T.EmailReminder ,
                        T.IsTellUsActivity ,
                        T.ContactQuestionID ,
                        T.IsPaging ,
                        T.IsDisplayForCapture ,
                        T.AttachmentLimit ,
                        T.AutoSaveLimit ,
                        ISNULL(( SELECT QuestionnaireId
                                 FROM   dbo.EstablishmentGroup
                                 WHERE  Id = T.EstablishmentGroupId
                               ), 0) AS QuestionnaireId ,
                        T.IsTellUsSubmitted ,
                       T.BadgeCount ,
                        T.Unresolved ,
                        ISNULL(( SELECT TOP 1
                                        DC.ContactId
                                 FROM   dbo.DefaultContact AS DC WITH ( NOLOCK )
                                 WHERE  DC.ActivityId = T.ActivityId
                                        AND DC.AppUserId = @AppUserId
                                        AND DC.IsDeleted = 0
                               ), 0) AS DefaultContactId ,
                        ISNULL(( SELECT TOP 1
                                        DC.IsGroup
                                 FROM   dbo.DefaultContact AS DC WITH ( NOLOCK )
                                 WHERE  DC.ActivityId = T.ActivityId
                                        AND DC.AppUserId = @AppUserId
                                        AND DC.IsDeleted = 0
                               ), 0) AS IsGroup ,
                        T.OUTCount ,
                        T.InCount ,
                        T.LastDays ,
                        T.ResponseCount
						FROM (
						 SELECT DISTINCT EG.Id AS ActivityId ,
                                    EG.EstablishmentGroupName AS ActivityName ,
                                    EG.EstablishmentGroupType AS ActivityType ,
                                    EG.EstablishmentGroupId ,
                                    UE.NotificationStatus AS IsNotificationOn ,
                                    ISNULL(EG.SeenClientId, 0) AS SeenClientId ,
                                    EG.AllowRecurring AS IsAllowedRecurring ,
                                    ISNULL(CASE EG.EstablishmentGroupType
                                             WHEN 'Customer' THEN CAST(0 AS BIT) ELSE EG.AllowToChangeDelayTime END, 0) AS IsAllowToChangeDelayTime ,
                                    ISNULL(UE.DelayTime, EG.DelayTime) AS DelayTime ,
                                    HW.HowItWorks ,
                                    EG.QuestionnaireId AS MasterQuestionnaireId ,
                                    QNR.QuestionnaireType ,
                                    '' AS SmileType ,
                                    EG.SMSReminder ,
                                    EG.EmailReminder ,
                                       ISNULL(CAST(CASE WHEN EG.QuestionnaireId IS NOT NULL
                                                     THEN 0
                                                     ELSE 1
                                                END AS BIT), 0) AS IsTellUsActivity ,
                                    EG.ContactQuestion AS ContactQuestionID ,
                                      CASE WHEN ( SELECT  COUNT(1)
                                                FROM    dbo.Establishment
                                                WHERE   EstablishmentGroupId = EG.Id
                                              ) > @EstablishmentCountByActivityId
                                         THEN CAST(1 AS BIT)
                                         ELSE CAST(0 AS BIT)
                                    END IsPaging ,
                                    CASE WHEN UE.EstablishmentType = 'Sales'
                                         THEN CAST(1 AS BIT)
                                         ELSE CAST(0 AS BIT)
                                    END AS IsDisplayForCapture ,
                                    CASE ISNULL(EG.AttachmentLimit, 0)
                                      WHEN 0 THEN 10
                                      ELSE EG.AttachmentLimit
                                    END AS AttachmentLimit ,
                                    ISNULL(EG.AutoSaveLimit, 0) AS AutoSaveLimit ,
		                                    ( SELECT    ISNULL(MAX(ActivitySequence),
                                                       EG.DisplaySequence)
                                      FROM      dbo.AppUserEstablishment
                                      WHERE     AppUserId = @AppUserId
                                                AND EstablishmentId IN (
                                                SELECT  Id
                                                FROM    dbo.Establishment
                                                WHERE   EstablishmentGroupId = EG.Id
                                                        AND IsDeleted = 0 )
                                    ) AS DisplaySequence ,
                                    ( SELECT    dbo.IsTellUsSubmitted(@AppUserId,EG.Id)
                                    ) AS IsTellUsSubmitted ,
                                    ISNULL(UE.ActivityLastDays, 0) AS LastDays,
								   CT.INCount,
								   CT.OUTCount,
								   CT.Unresolved,
								   CT.ResponseCount,
								   CT.BadgeCount
                          FROM      dbo.EstablishmentGroup AS EG
                                    INNER JOIN dbo.Establishment AS EST ON EST.EstablishmentGroupId = EG.Id
                                    INNER JOIN dbo.AppUserEstablishment UE ON UE.EstablishmentId = EST.Id
                                    INNER JOIN dbo.HowItWorks AS HW ON HW.Id = EG.HowItWorksId
                                    INNER JOIN dbo.Questionnaire AS QNR ON QNR.Id = EG.QuestionnaireId
									INNER JOIN #CountTable AS CT ON EG.Id = CT.ActivityId
                          WHERE     EG.IsDeleted = 0
                                    AND EST.IsDeleted = 0
                                    AND UE.AppUserId = @AppUserId
                                    AND UE.IsDeleted = 0) AS T
            END;
        SET NOCOUNT OFF;

