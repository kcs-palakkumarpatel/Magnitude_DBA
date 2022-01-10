--	=============================================
--	Author:			D3
--	Create date:	30-Nov-2017
--	Description:	
--	Call SP: dbo.GetActivityDetailByActivityId 1243,1941
--	=============================================
CREATE PROCEDURE [dbo].[GetActivityDetailByActivityId_16Sept2021]
    (
      @AppUserId BIGINT ,
      @ActivityId BIGINT
    )
AS
    BEGIN
        SET NOCOUNT OFF;

        DECLARE @DraftsCount INT;

        SELECT  @DraftsCount = COUNT(1)
        FROM    dbo.SeenClientAnswerMaster AS SAM
                INNER JOIN dbo.Establishment AS ES ON ES.Id = SAM.EstablishmentId
        WHERE   SAM.AppUserId = @AppUserId
                AND ES.EstablishmentGroupId = @ActivityId
                AND SAM.IsDeleted = 1
                AND SAM.DraftEntry = 1
                AND ISNULL(SAM.DraftSave, 0) = 0;

        
        SELECT 
                EG.Id AS ActivityId ,
                EG.EstablishmentGroupName AS ActivityName ,
                EG.PIStatus AS PIStatus ,
                EG.PIOutStatus AS PIOutStatus ,
                UE.EstablishmentType AS ActivityType ,
                UE.NotificationStatus AS IsNotificationOn ,
                ISNULL(EG.SeenClientId, 0) AS SeenClientId ,
                EG.AllowRecurring AS IsAllowedRecurring ,
                ISNULL(CASE EG.EstablishmentGroupType
                         WHEN 'Customer' THEN CAST(0 AS BIT)
                         ELSE EG.AllowToChangeDelayTime
                       END, 0) AS IsAllowToChangeDelayTime ,
                EG.QuestionnaireId AS MasterQuestionnaireId ,
                QNR.QuestionnaireType ,
                CASE ISNULL(EG.AttachmentLimit, 0)
                  WHEN 0 THEN 10
                  ELSE EG.AttachmentLimit
                END AS AttachmentLimit ,
                ISNULL(EG.AutoSaveLimit, 0) AS AutoSaveLimit ,
                ( SELECT    dbo.IsTellUsSubmitted(@AppUserId, EG.Id)
                ) AS IsTellUsSubmitted ,
                EG.QuestionnaireId ,
                @DraftsCount AS DraftsCount ,
                ISNULL(EG.InFormRefNumber, 0) AS InFormRefNumber ,
                ISNULL(EG.IncludeEmailAttachments, 1) AS IncludeEmailAttachments,
				ISNULL(UE.StatusSettings, 0) AS StatusSettings
        FROM    dbo.EstablishmentGroup AS EG
                INNER JOIN dbo.Vw_Establishment AS EST ON EST.EstablishmentGroupId = EG.Id
                INNER JOIN dbo.AppUserEstablishment UE ON UE.EstablishmentId = EST.Id
                INNER JOIN dbo.Questionnaire AS QNR ON QNR.Id = EG.QuestionnaireId
        WHERE   EG.Id = @ActivityId
                AND EG.IsDeleted = 0
                AND EST.IsDeleted = 0
                AND UE.AppUserId = @AppUserId
                AND UE.IsDeleted = 0;
  
        SET NOCOUNT ON;
    END;
