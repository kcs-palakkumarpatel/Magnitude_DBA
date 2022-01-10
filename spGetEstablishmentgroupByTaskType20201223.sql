CREATE PROCEDURE [dbo].[spGetEstablishmentgroupByTaskType20201223]
@AppUserId	BIGINT
AS
BEGIN 
	SELECT DISTINCT 
	ISNULL (EG.EstablishmentGroupId,'0') AS 'Activity Id',EG.DisplaySequence AS 'Display Sequence',
	--AU.Id AS 'USER ID', AU.Name AS 'USER Name' , G.GroupName AS 'GROUP Name', 
	--AUE.EstablishmentId AS 'Establishment Id', E.EstablishmentName AS 'Establishment Name',
	EG.EstablishmentGroupName AS 'Activity Name', EG.EstablishmentGroupType AS 'Activity Type',
	AUE.NotificationStatus AS 'IsNotificationOn', EG.SeenClientId AS 'SeenClientId',
	EG.AllowRecurring AS 'IsAllowedRecurring',  
	ISNULL(CASE EG.EstablishmentGroupType
                          WHEN 'Customer' THEN
                              CAST(0 AS BIT)
                          ELSE
                              EG.AllowToChangeDelayTime
                      END,
                      0
           ) AS IsAllowToChangeDelayTime,
    ISNULL(AUE.DelayTime, EG.DelayTime) AS 'DelayTime',
	HW.HowItWorks AS 'HowItWorks', EG.QuestionnaireId AS 'MasterQuestionnaireId',
	QNR.QuestionnaireType AS 'QuestionnaireType','' AS 'SmileType',
	EG.SMSReminder AS 'SMSReminder',EG.EmailReminder AS 'EmailReminder',
	EG.ContactQuestion AS 'ContactQuestionID', 
	CASE ISNULL(EG.AttachmentLimit, 0)
                WHEN 0 THEN
                    10
                ELSE
                    EG.AttachmentLimit
    END AS AttachmentLimit,
	ISNULL(EG.AutoSaveLimit, 0) AS AutoSaveLimit,
	ISNULL(AUE.ActivityLastDays, 0) AS LastDays,
	ISNULL(AUE.StatusSettings, 0) AS StatusSettings, 0 AS INCount, 0 AS OUTCount, 0 AS Unresolved,
    0 AS ResponseCount, 0 AS BadgeCount

	FROM dbo.AppUser AS AU
	INNER JOIN dbo.[Group] AS G
	ON G.Id = AU.GroupId 
	INNER JOIN dbo.AppUserEstablishment AS AUE
	ON AU.GroupId = AUE.AppUserId
	INNER JOIN dbo.EstablishmentGroup AS EG
	ON G.Id = EG.GroupId
	INNER JOIN dbo.Establishment AS E
	ON G.Id = E.EstablishmentGroupId
	INNER JOIN dbo.HowItWorks AS HW
	ON EG.HowItWorksId = HW.Id
	INNER JOIN dbo.Questionnaire AS QNR
    ON QNR.Id = EG.QuestionnaireId

	WHERE AU.Id =@AppUserId 
	AND AU.IsDeleted=0  
	AND AUE.IsDeleted=0
	AND E.IsDeleted=0
	AND EG.IsDeleted=0
	AND EG.SeenClientId IS NOT NULL
	--AND EG.EstablishmentGroupType='Task'
	ORDER BY EG.DisplaySequence 

END

