--	=============================================
--	Author:			Anant bhatt
--	Create date:	01-APR-2020
--	Description:	
--	Call SP:	dbo.GetTaskActivityListByAppUserId 18058
--	=============================================
CREATE PROCEDURE [dbo].[GetTaskActivityListByAppUserId]
    @AppUserId BIGINT,
    @LastServerDate DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @EstablishmentCountByActivityId BIGINT;
    SELECT @EstablishmentCountByActivityId = KeyValue
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'EstablishmentCountByActivityId';

    SELECT DISTINCT
        T.ActivityName,
        T.ActivityId,
        T.SeenClientId,
        ISNULL(T.Color, '') AS ActivityColor,
		T.IsTellUsSubmitted,
		T.AttachmentLimit
    FROM
    (
        SELECT DISTINCT
            EG.Id AS ActivityId,
            EG.EstablishmentGroupName AS ActivityName,
            EG.EstablishmentGroupId,
            ISNULL(EG.SeenClientId, 0) AS SeenClientId,
            EG.Color,
            ISNULL(EG.AutoSaveLimit, 0) AS AutoSaveLimit ,
                ( SELECT    dbo.IsTellUsSubmitted(@AppUserId, EG.Id)
                ) AS IsTellUsSubmitted ,
				EG.AttachmentLimit
        FROM dbo.EstablishmentGroup AS EG
            INNER JOIN dbo.Vw_Establishment AS EST
                ON EST.EstablishmentGroupId = EG.Id
            INNER JOIN dbo.AppUserEstablishment UE
                ON UE.EstablishmentId = EST.Id
            INNER JOIN dbo.Questionnaire AS QNR
                ON QNR.Id = EG.QuestionnaireId
        WHERE EG.IsDeleted = 0
              AND EST.IsDeleted = 0
              AND UE.AppUserId = @AppUserId
              AND UE.IsDeleted = 0
              AND EG.EstablishmentGroupType = 'Task'
    ) AS T
    OPTION (RECOMPILE);
    SET NOCOUNT OFF;

END;
