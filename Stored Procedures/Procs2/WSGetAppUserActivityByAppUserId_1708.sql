--	=============================================
--	Author:			D3
--	Create date:	09-Nov-2017
--	Description:	
--	Call SP:	dbo.WSGetAppUserActivityByAppUserId_1708 1615, ''
--	=============================================
CREATE PROCEDURE dbo.WSGetAppUserActivityByAppUserId_1708
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
			ActivityId INT,
			BadgeCount INT,
			Unresolved INT,
			ResponseCount INT,
			OUTCount INT,
			InCount INT
		)

		INSERT INTO #CountTable
		        EXEC GetActivityCountByAppUserId_2308 @AppUserId
		        
						 SELECT DISTINCT
                                    EG.Id AS ActivityId ,
                                    EG.EstablishmentGroupName AS ActivityName ,
                                    EG.EstablishmentGroupType AS ActivityType ,
                                    EG.EstablishmentGroupId ,
                                    UE.NotificationStatus AS IsNotificationOn ,
                                    ISNULL(EG.SeenClientId, 0) AS SeenClientId ,
                                    EG.AllowRecurring AS IsAllowedRecurring ,
                                    ISNULL(CASE EG.EstablishmentGroupType
                                             WHEN 'Customer' THEN 0 ELSE EG.AllowToChangeDelayTime END, 0) AS IsAllowToChangeDelayTime ,
                                    ISNULL(UE.DelayTime, EG.DelayTime) AS DelayTime ,
                                    HW.HowItWorks ,
                                    EG.QuestionnaireId AS MasterQuestionnaireId ,
                                    QNR.QuestionnaireType ,
                                    '' AS SmileType ,
                                    EG.SMSReminder ,
                                    EG.EmailReminder ,
                                    ISNULL(CASE WHEN EG.QuestionnaireId IS NOT NULL
                                                     THEN 0
                                                     ELSE 1
                                                END , 0) AS IsTellUsActivity ,
                                    EG.ContactQuestion AS ContactQuestionID ,
                                    CASE WHEN ( SELECT  COUNT(1)
                                                FROM    dbo.Establishment
                                                WHERE   EstablishmentGroupId = EG.Id
                                              ) > @EstablishmentCountByActivityId
                                         THEN 1 ELSE 0 
                                    END IsPaging ,
                                    CASE WHEN UE.EstablishmentType = 'Sales'
                                         THEN 1 
                                         ELSE 0 
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
                                    AND UE.IsDeleted = 0
            END;
        SET NOCOUNT OFF;

