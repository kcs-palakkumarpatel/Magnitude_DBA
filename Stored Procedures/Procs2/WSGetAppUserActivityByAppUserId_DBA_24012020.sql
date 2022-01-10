
--	=============================================
--	Author:			D3
--	Create date:	09-Nov-2017
--	Description:	
--	Call SP:	dbo.WSGetAppUserActivityByAppUserId 2876, ''
--	=============================================
CREATE PROCEDURE [dbo].[WSGetAppUserActivityByAppUserId_DBA_24012020]
    @AppUserId BIGINT,
    @LastServerDate DATETIME = NULL
AS  
    BEGIN  
        SET NOCOUNT OFF;  
  
		DECLARE @EstablishmentCountByActivityId BIGINT;  
        SELECT  @EstablishmentCountByActivityId = KeyValue  
        FROM    dbo.AAAAConfigSettings  
        WHERE   KeyName = 'EstablishmentCountByActivityId';  

		DECLARE  @Last30DaysDate DATETIME;
		SET @Last30DaysDate = DATEADD(DAY,-(SELECT  TOP 1 CAST(KeyValue AS BIGINT) FROM dbo.AAAAConfigSettings WHERE KeyName = 'LastFormDays'),GETUTCDATE());


IF OBJECT_ID('tempdb..#EstablishmentId','U') IS NOT NULL
DROP TABLE #EstablishmentId
CREATE TABLE #EstablishmentId (id BIGINT,ActivityId BIGINT,ActivityType NVARCHAR(40))


IF OBJECT_ID('tempdb..#UserId', 'U') IS NOT NULL
		DROP TABLE #UserId
		CREATE TABLE #UserId (UserId BIGINT,ActityvityId BIGINT,ActivityType NVARCHAR(40))

	INSERT INTO #EstablishmentId
    SELECT EST.Id,EG.Id AS ActivityId,EstablishmentGroupType AS ActivityType
	FROM  dbo.EstablishmentGroup AS EG WITH(NOLOCK) 
	INNER JOIN dbo.Establishment AS EST  WITH(NOLOCK) ON EST.EstablishmentGroupId = EG.Id  
	INNER JOIN dbo.AppUserEstablishment WITH(NOLOCK) ON  AppUserEstablishment.AppUserId = @AppUserId 
	AND AppUserEstablishment.EstablishmentId = EST.Id  AND appuserestablishment.IsDeleted = 0 
	--est.EstablishmentGroupId = @ActivityId 

	--INSERT INTO #EstablishmentId
 --   SELECT EST.Id
	--FROM   dbo.Establishment AS EST  WITH(NOLOCK)
	--INNER JOIN dbo.AppUserEstablishment WITH(NOLOCK) ON  AppUserEstablishment.AppUserId = @AppUserId 
	--AND AppUserEstablishment.EstablishmentId = EST.Id  AND appuserestablishment.IsDeleted = 0 
	--est.EstablishmentGroupId = @ActivityId 
	



DECLARE @Count BIGINT = 0;
        DECLARE @IsManager BIT;
        
        SELECT  @IsManager = IsAreaManager
        FROM    dbo.AppUser
        WHERE   Id = @AppUserId;


			IF EXISTS ( SELECT 1
                    FROM  dbo.AppUserEstablishment
                    INNER JOIN dbo.AppUser ON AppUser.Id = AppUserEstablishment.AppUserId AND  IsAreaManager = 0 AND IsActive = 1
					AND AppUser.IsDeleted = 0 and   dbo.AppUserEstablishment.IsDeleted = 0
					INNER JOIN dbo.Establishment AS E ON E.Id = AppUserEstablishment.EstablishmentId --AND E.EstablishmentGroupId = @ActivityId
                    UNION
					SELECT 1
                    FROM  dbo.AppUserEstablishment
                    INNER JOIN dbo.AppUser ON AppUser.Id = AppUserEstablishment.AppUserId AND  AppUserId = @AppUserId AND AppUser.IsDeleted = 0 
					AND IsActive = 1 AND   dbo.AppUserEstablishment.IsDeleted = 0
					INNER JOIN dbo.Establishment AS E ON E.Id = AppUserEstablishment.EstablishmentId --AND E.EstablishmentGroupId = @ActivityId
                    
                   )
		BEGIN
			SET @Count = 1
		END

		IF @Count = 0
		BEGIN
			IF EXISTS (SELECT 1
                    FROM AppManagerUserRights
                    INNER JOIN dbo.AppUser ON dbo.AppUser.Id = AppManagerUserRights.ManagerUserId AND AppManagerUserRights.UserId = @AppUserId
					AND AppManagerUserRights.IsDeleted = 0
					AND IsActive = 1
					INNER JOIN #EstablishmentId e ON e.id=AppManagerUserRights.EstablishmentId)
            BEGIN
                SET @Count = 1
            END
		END
	
		IF ( @IsManager = 1 )
						BEGIN
							IF (@Count > 0)
						BEGIN
							INSERT INTO #UserId
							 SELECT  AppUserId,ActivityId,ActivityType
							 FROM    dbo.AppUserEstablishment
							 INNER JOIN dbo.AppUser ON AppUser.Id = AppUserEstablishment.AppUserId 
							 AND AppUserId = @AppUserId AND AppUser.IsDeleted = 0 AND dbo.AppUserEstablishment.IsDeleted = 0 AND IsActive = 1
							 INNER JOIN #EstablishmentId e ON e.id=dbo.AppUserEstablishment.EstablishmentId
							 UNION
							 SELECT  AppUserId,ActivityId,ActivityType
							 FROM    dbo.AppUserEstablishment
							 INNER JOIN dbo.AppUser ON AppUser.Id = AppUserEstablishment.AppUserId 
							 AND  IsAreaManager = 0 AND AppUser.IsDeleted = 0 AND dbo.AppUserEstablishment.IsDeleted = 0 AND IsActive = 1
							 INNER JOIN #EstablishmentId e ON e.id=dbo.AppUserEstablishment.EstablishmentId
							 UNION
							 SELECT  ManagerUserId ,ActivityId,ActivityType
							 FROM    AppManagerUserRights
							 INNER JOIN dbo.AppUser ON dbo.AppUser.Id = AppManagerUserRights.ManagerUserId AND AppManagerUserRights.UserId = @AppUserId AND AppUser.IsDeleted = 0
							 AND AppManagerUserRights.IsDeleted = 0 AND IsActive = 1
							 INNER JOIN #EstablishmentId e ON e.id=AppManagerUserRights.EstablishmentId
							 INNER JOIN dbo.AppUserEstablishment ON AppManagerUserRights.EstablishmentId = AppUserEstablishment.EstablishmentId
             
						END
						ELSE
						BEGIN
                        INSERT  INTO #UserId
						SELECT DISTINCT U.Id AS UserId,Eg.Id,EstablishmentGroupType
                        FROM    dbo.AppUserEstablishment AS UE
						INNER JOIN dbo.AppUser AS LoginUser ON UE.AppUserId = LoginUser.Id AND LoginUser.Id = @AppUserId AND LoginUser.IsDeleted = 0
						AND UE.IsDeleted = 0 
                        INNER JOIN dbo.Establishment AS E ON UE.EstablishmentId = E.Id AND   E.IsDeleted = 0
                        INNER JOIN dbo.EstablishmentGroup AS Eg ON Eg.Id = E.EstablishmentGroupId
                        INNER JOIN dbo.AppUserEstablishment AS AppUser ON E.Id = AppUser.EstablishmentId
						AND ( UE.EstablishmentType = AppUser.EstablishmentType OR LoginUser.IsAreaManager = 1)
                        INNER JOIN dbo.AppUser AS U ON AppUser.AppUserId = U.Id AND ( U.IsAreaManager = 0 OR U.Id = @AppUserId) AND U.IsDeleted = 0
						AND AppUser.IsDeleted = 0
                        
						END;

						END
					 ELSE
						BEGIN
INSERT  INTO #UserId 
SELECT U.Id AS UserId,Eg.Id,EstablishmentGroupType
FROM dbo.AppUserEstablishment AS UE
    INNER JOIN dbo.AppUser AS LoginUser
        ON UE.AppUserId = LoginUser.Id
           AND LoginUser.Id = @AppuserId
           AND LoginUser.IsDeleted = 0
    INNER JOIN dbo.Establishment AS E
        ON UE.EstablishmentId = E.Id
    INNER JOIN dbo.EstablishmentGroup AS Eg
        ON Eg.Id = E.EstablishmentGroupId
    INNER JOIN dbo.AppUserEstablishment AS AppUser
        ON E.Id = AppUser.EstablishmentId
           AND (
                   UE.EstablishmentType = AppUser.EstablishmentType
                   OR LoginUser.IsAreaManager = 1
               )
    INNER JOIN dbo.AppUser AS U
        ON AppUser.AppUserId = U.Id
           AND (
                   U.IsAreaManager = 0
                   OR U.Id = @AppuserId
               )
WHERE U.Id = @AppuserId
      AND E.IsDeleted = 0
      AND UE.IsDeleted = 0
      AND AppUser.IsDeleted = 0
      AND U.IsDeleted = 0
END;
    
            
SELECT DISTINCT   
      CASE ISNULL(T.DisplaySequence,0) WHEN 0 THEN 99999 ELSE T.DisplaySequence END AS DisplaySequence, 
				T.ActivityName,   
				 T.ActivityId ,  
                  --T.ActivityName ,  
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
                  T.AutoSaveLimit,
				 
ISNULL((SELECT  QuestionnaireId FROM dbo.EstablishmentGroup WHERE  Id = T.EstablishmentGroupId), 0) AS QuestionnaireId ,  
T.IsTellUsSubmitted,  
(SELECT dbo.GetBadgeCountForActivity(@AppUserId, T.ActivityId)) AS BadgeCount,  
--(SELECT dbo.GetBadgeCountUnresolve(@AppUserId,T.ActivityId,T.ActivityType)) AS Unresolved,
--dbo.GetBadgeCountUnresolve_DBA1(@AppUserId,T.ActivityId,T.ActivityType) AS Unresolved, 

CASE 
WHEN T.ActivityType='Sales'
THEN 
(SELECT    COUNT(1)
                                      FROM   dbo.Establishment E WITH(NOLOCK)
									  INNER JOIN dbo.AppUserEstablishment Aue WITH(NOLOCK) ON Aue.EstablishmentId=E.Id AND Aue.IsDeleted = 0 
									  INNER JOIN  dbo.SeenClientAnswerMaster AS SCA WITH(NOLOCK) ON E.Id = SCA.EstablishmentId
									  AND SCA.IsDeleted = 0 AND SCA.IsResolved = 'Unresolved'	 AND E.IsDeleted = 0
									  INNER JOIN  #UserId u ON u.UserId = SCA.AppUserId AND U.ActityvityId=T.ActivityId AND U.ActivityType=T.ActivityType
									  --INNER JOIN (SELECT  Data FROM    dbo.Split(( SELECT  dbo.AllUserSelected(@AppuserId,0,T.ActivityId)), ',')) AS U ON U.Data = SCA.AppUserId
									  --INNER JOIN  #UserId u ON u.UserId = SCA.AppUserId
												WHERE Aue.AppUserId = @AppuserId AND EstablishmentGroupId = T.ActivityId 
												--AND SCA.AppUserId IN ( SELECT  dbo.AllUserSelected(@AppuserId,0,T.ActivityId))
												AND CAST(SCA.CreatedOn AS DATE) BETWEEN CAST(@Last30DaysDate AS DATE) AND CAST(GETUTCDATE() AS DATE)) 
ELSE
(SELECT    COUNT(1)
                                      FROM dbo.Establishment E WITH	(NOLOCK)
									  INNER JOIN dbo.AnswerMaster AS AM WITH(NOLOCK) ON E.Id=Am.EstablishmentId 
									  AND E.IsDeleted = 0 AND AM.IsDeleted = 0 AND AM.IsResolved = 'Unresolved'
									  INNER JOIN dbo.AppUserEstablishment Aue ON Aue.EstablishmentId=E.Id AND Aue.IsDeleted = 0 
                                      --INNER JOIN dbo.Establishment ON Establishment.Id = Aue.EstablishmentId
                                      WHERE Aue.AppUserId = @AppuserId AND EstablishmentGroupId = T.ActivityId 
									  AND CAST(AM.CreatedOn AS DATE) BETWEEN CAST(@Last30DaysDate AS DATE) AND CAST(GETUTCDATE() AS DATE) )												
END AS Unresolved, 



 
 ISNULL( (SELECT  TOP 1 DC.ContactId FROM dbo.DefaultContact AS DC WITH ( NOLOCK ) WHERE  DC.ActivityId = T.ActivityId AND DC.AppUserId = @AppUserId AND DC.IsDeleted = 0  ), 0) AS  DefaultContactId,  ISNULL( (SELECT  TOP 1 DC.IsGroup FROM dbo.DefaultContact AS DC WITH ( NOLOCK ) WHERE  DC.ActivityId = T.ActivityId AND DC.AppUserId = @AppUserId AND DC.IsDeleted = 0 ), 0) AS IsGroup,  
0 AS OUTCount, --  (SELECT dbo.GetBadgeCountINOUT(@AppUserId, T.ActivityId,T.LastDays,1)) AS OUTCount,  
0 AS INCount, --(SELECT dbo.GetBadgeCountINOUT(@AppUserId, T.ActivityId,T.LastDays,0)) AS InCount,  
T.LastDays AS LastDays, 
T.StatusSettings AS StatusSettings,
0 AS ResponseCount,
		  T.ActivityImagePath,
        ISNULL(T.InFormRefNumber, 0) AS [InFormRefNumber],
        ISNULL(T.IncludeEmailAttachments, 1) AS [IncludeEmailAttachments] 
FROM (  
SELECT DISTINCT EG.Id AS ActivityId ,  
        EG.EstablishmentGroupName AS ActivityName ,  
        EG.EstablishmentGroupType AS ActivityType ,  
		EG.EstablishmentGroupId,  
        UE.NotificationStatus AS IsNotificationOn ,  
        ISNULL(EG.SeenClientId, 0) AS SeenClientId ,  
        EG.AllowRecurring AS IsAllowedRecurring ,  
        ISNULL(CASE EG.EstablishmentGroupType WHEN 'Customer' THEN CAST(0 AS BIT) ELSE EG.AllowToChangeDelayTime END, 0) AS IsAllowToChangeDelayTime ,  
        ISNULL(UE.DelayTime, EG.DelayTime) AS DelayTime ,  
        HW.HowItWorks ,  
        EG.QuestionnaireId  AS MasterQuestionnaireId,  
        QNR.QuestionnaireType ,  
        --dbo.GetSmileFaceByActivityId(EG.Id, EG.SmileOn, @AppUserId) AS SmileType ,  
  '' AS SmileType,  
        EG.SMSReminder ,  
        EG.EmailReminder ,  
        ISNULL(CAST(CASE WHEN EG.QuestionnaireId IS NOT NULL THEN 0 ELSE 1 END AS BIT), 0) AS IsTellUsActivity ,   
        EG.ContactQuestion AS ContactQuestionID ,  
        CASE WHEN ( SELECT  COUNT(1) FROM    dbo.Establishment WHERE   EstablishmentGroupId = EG.Id ) > @EstablishmentCountByActivityId THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END IsPaging ,  
  CASE WHEN UE.EstablishmentType = 'Sales' THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS IsDisplayForCapture ,  
        CASE ISNULL(EG.AttachmentLimit, 0) WHEN 0 THEN 10 ELSE EG.AttachmentLimit END AS AttachmentLimit,  
  ISNULL(EG.AutoSaveLimit, 0) AS AutoSaveLimit,  
  ISNULL(UE.ActivitySequence,EG.DisplaySequence) AS DisplaySequence,  
  (SELECT dbo.IsTellUsSubmitted(@AppUserId, EG.Id)) AS IsTellUsSubmitted,  
       ISNULL(UE.ActivityLastDays, 0) AS LastDays,
	ISNULL(UE.StatusSettings, 0) AS StatusSettings,
   0 AS INCount,
            0 AS OUTCount,
            0 AS Unresolved,
            0 AS ResponseCount,
            0 AS BadgeCount,
            EG.ActivityImagePath,
		           CASE EG.EstablishmentGroupType
                WHEN 'Customer' THEN
                    CAST(1 AS BIT)
                ELSE
                    ISNULL(EG.InFormRefNumber, CAST(0 AS BIT))
            END AS [InFormRefNumber],
            EG.IncludeEmailAttachments
FROM    dbo.EstablishmentGroup AS EG  
        INNER JOIN dbo.Establishment AS EST ON EST.EstablishmentGroupId = EG.Id  
        INNER JOIN dbo.AppUserEstablishment UE ON UE.EstablishmentId = EST.Id  
        INNER JOIN dbo.HowItWorks AS HW ON HW.Id = EG.HowItWorksId  
        INNER JOIN dbo.Questionnaire AS QNR ON QNR.Id = EG.QuestionnaireId  
WHERE   EG.IsDeleted = 0  
        AND EST.IsDeleted = 0  
        AND UE.AppUserId = @AppUserId  
        AND UE.IsDeleted = 0  
 ) AS T    
  
  
        SET NOCOUNT ON;  
    END;  



