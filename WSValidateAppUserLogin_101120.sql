-- =============================================
-- Author:			D3
-- Create date:	24-Jan-2018
--	Description:	
--	=============================================
/*
drop procedure WSValidateAppUserLogin_101120

Exec WSValidateAppUserLogin 'vasudevp', '67cfE4x5Ra18G7LA1pRAXA=='
*/
CREATE PROCEDURE [dbo].[WSValidateAppUserLogin_101120]
    @UserName NVARCHAR(50),
    @Password NVARCHAR(100)
AS
BEGIN
	
	SET NOCOUNT ON;

    DECLARE @Url NVARCHAR(500);
	DECLARE @UrlVal NVARCHAR(500);
	Declare @iLoginFlag Int = 0

    SELECT @Url = KeyValue + 'AppUser/'
		,@UrlVal = KeyValue
    FROM dbo.AAAAConfigSettings WITH (NOLOCK)
    WHERE KeyName = 'DocViewerRootFolderPathCMS';

	SELECT @iLoginFlag = LoginFlag FROM dbo.ClientInfo

    DECLARE @GroupId BIGINT;
    DECLARE @AppUserId BIGINT;
    DECLARE @Id BIGINT;
    
	SELECT @GroupId = GroupId,
           @AppUserId = Id
    FROM dbo.AppUser
    WHERE (UserName = @UserName)
    AND ([Password] = @Password)
    AND (IsDeleted = 0)
    AND IsActive = 1;

    IF NOT EXISTS (	SELECT 1 FROM dbo.HeaderSetting WHERE GroupId = @GroupId)
    BEGIN
        IF @GroupId > 0 AND @GroupId IS NOT NULL
        BEGIN
            INSERT INTO dbo.HeaderSetting
            (
                GroupId,
                EstablishmentGroupId,
                HeaderId,
                HeaderName,
                HeaderValue,
                CreatedOn,
                CreatedBy
            )
            SELECT EG.GroupId,
                   EG.Id AS ActivityId,
                   WAH.Id AS HeaderId,
                   LabelName AS HeaderName,
                   CASE
                       WHEN LabelName = 'OUT Form Section' THEN
                           'OUT'
                       WHEN LabelName = 'IN Form Section' THEN
                           'IN'
                       WHEN LabelName = 'Action Screen' THEN
                           'Action'
                       WHEN LabelName = 'Map Screen' THEN
                           'Map'
                       WHEN LabelName = 'Select Establishment' THEN
                           'Establishment'
                       WHEN LabelName = 'Select User' THEN
                           'User'
                       ELSE
                           LabelName
                   END AS HeaderValue,
                   GETDATE() AS CreatedOn,
                   @AppUserId AS CreatedBy
            FROM dbo.WebAppHeaders AS WAH
                INNER JOIN dbo.EstablishmentGroup AS EG
                    ON EG.GroupId = @GroupId
            WHERE WAH.IsDeleted = 0
                  AND EG.IsDeleted = 0
            ORDER BY EG.Id,
                     WAH.Id ASC;
        END;
    END;

    SELECT TOP 1
        U.Id AS UserId,
        U.Name,
        U.Email,
        U.Mobile,
        U.IsAreaManager,
        ISNULL(U.SupplierId, 0) AS SupplierId,
        U.UserName,
        G.ThemeId,
        @UrlVal As ThemeURL,
		EG.GroupId,
        G.GroupName,
        G.ContactId AS ContactFormId,
        ISNULL(@Url + U.ImageName, '') AS ImageUrl,
        U.AccessBulkSMS AS AccessBulkSMS,
        U.AccessRemoveFromStatistics AS Access,
        U.AllowDeleteFeedback,
        ISNULL(DC.ContactId, 0) AS DefaultContactId,
        ISNULL(DC.IsGroup, 'false') AS IsGroup,
        ISNULL(U.IsDefaultContact, 0) AS IsDefaultContact,
        ISNULL(U.ResolveAllRights, 0) AS ResolveAllRights,
        ISNULL(U.DatabaseReferenceOption, 0) AS IsNewOptionAllow,
        ISNULL(U.AllowImportContacts, 0) AS IsAllowImportContacts,
        ISNULL(U.AutoSave, 0) AS IsAutoSave,
        ISNULL(U.AllowChangeContact, 0) AS AllowChangeContact,
		ISNULL(U.AllowExportData, 0) AS AllowExportData,
		ISNULL(U.AllowUpdateContact, 0) AS AllowUpdateContact,
        ISNULL(LANG.LanguageName, 'en') AS [Language],
        @iLoginFlag AS LoginFlag,
		dbo.fn_IsContactMasterExists(EG.GroupId, U.Email, U.Mobile) as ContactMasterId
    FROM AppUser AS U WITH (NOLOCK)
    INNER JOIN dbo.AppUserEstablishment AS UE WITH (NOLOCK) ON U.Id = UE.AppUserId
               AND UE.IsDeleted = 0
        INNER JOIN dbo.Establishment AS E WITH (NOLOCK)
            ON UE.EstablishmentId = E.Id
        INNER JOIN dbo.EstablishmentGroup AS EG WITH (NOLOCK)
            ON E.EstablishmentGroupId = EG.Id
        INNER JOIN dbo.[Group] AS G WITH (NOLOCK)
            ON EG.GroupId = G.Id
        LEFT JOIN dbo.DefaultContact AS DC WITH (NOLOCK)
            ON EG.GroupId = ISNULL(DC.GroupId, 0)
               AND ISNULL(DC.AppUserId, 0) = UE.AppUserId
               AND DC.IsDeleted = 0
        LEFT JOIN dbo.LanguageMaster AS LANG
            ON U.LanguageMasterId = LANG.Id
    WHERE (UserName = @UserName)
          AND ([Password] = @Password)
          AND (U.IsDeleted = 0)
          AND U.IsActive = 1;

    SET NOCOUNT OFF;
END;
