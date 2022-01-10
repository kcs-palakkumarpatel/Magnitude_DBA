
-- =============================================
-- Author:			D3
-- Create date:	24-Jan-2018
--	Description:	
--	Call SP:WSValidateAppUserLogin 'sh1', 'ldtFAJcgbrhxNg/2L0FLAQ=='
--	=============================================
CREATE PROCEDURE [dbo].[WSValidateAppUserLogin_111921]
    @UserName NVARCHAR(50),
    @Password NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Url NVARCHAR(500);
    SELECT @Url = KeyValue + N'AppUser/'
    FROM dbo.AAAAConfigSettings WITH (NOLOCK)
    WHERE KeyName = 'DocViewerRootFolderPathCMS';
    DECLARE @GroupId BIGINT;
    DECLARE @AppUserId BIGINT;
    SELECT @GroupId = GroupId,
           @AppUserId = Id
    FROM dbo.AppUser
    WHERE (UserName = @UserName)
          AND ([Password] = @Password)
          AND (IsDeleted = 0)
          AND IsActive = 1;

    IF NOT EXISTS
    (
        (SELECT HeaderSettingId
         FROM dbo.HeaderSetting WITH (NOLOCK)
         WHERE GroupId = @GroupId)
    )
    BEGIN
        IF @GroupId > 0
           AND @GroupId IS NOT NULL
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
                   WAH.LabelName AS HeaderName,
                   CASE
                       WHEN WAH.LabelName = 'OUT Form Section' THEN
                           'OUT'
                       WHEN WAH.LabelName = 'IN Form Section' THEN
                           'IN'
                       WHEN WAH.LabelName = 'Action Screen' THEN
                           'Action'
                       WHEN WAH.LabelName = 'Map Screen' THEN
                           'Map'
                       WHEN WAH.LabelName = 'Select Establishment' THEN
                           'Establishment'
                       WHEN WAH.LabelName = 'Select User' THEN
                           'User'
                       ELSE
                           WAH.LabelName
                   END AS HeaderValue,
                   GETDATE() AS CreatedOn,
                   @AppUserId AS CreatedBy
            FROM dbo.WebAppHeaders AS WAH WITH (NOLOCK)
                INNER JOIN dbo.EstablishmentGroup AS EG WITH (NOLOCK)
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
        (
            SELECT KeyValue
            FROM dbo.AAAAConfigSettings
            WHERE KeyName = 'DocViewerRootFolderPathCMS'
        ) AS ThemeURL,
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
        (
            SELECT LoginFlag FROM dbo.ClientInfo
        ) AS LoginFlag,
        dbo.fn_IsContactMasterExists(EG.GroupId, U.Email, U.Mobile) AS ContactMasterId,
        ISNULL(U.AllowTaskAllocations, 0) AS AllowTaskAllocations,
        ISNULL(U.AllowAnalytics, 0) AS AllowAnalytics
    FROM dbo.AppUser AS U WITH (NOLOCK)
        INNER JOIN dbo.AppUserEstablishment AS UE WITH (NOLOCK)
            ON U.Id = UE.AppUserId
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
        LEFT JOIN dbo.LanguageMaster AS LANG WITH (NOLOCK)
            ON U.LanguageMasterId = LANG.Id
    WHERE (U.UserName = @UserName)
          AND ([Password] = @Password)
          AND (U.IsDeleted = 0)
          AND U.IsActive = 1;
    SET NOCOUNT OFF;
END;
