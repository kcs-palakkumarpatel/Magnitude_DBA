-- =============================================
-- Author:		<Author,,SUNIL>
-- Create date: <Create Date,, 17 01 2017>
-- Description:	<Description,,>
-- Call SP    :		dbo.InsertDefaultHeaderSettingByNewActivity 7833, 2
-- =============================================
CREATE PROCEDURE dbo.InsertDefaultHeaderSettingByNewActivity
    @ActivityId BIGINT,
    @UserId BIGINT
AS
BEGIN
    IF @ActivityId > 0
       AND @ActivityId IS NOT NULL
    BEGIN
        INSERT INTO dbo.HeaderSetting
        (
            GroupId,
            EstablishmentGroupId,
            HeaderId,
            HeaderName,
            HeaderValue,
            CreatedOn,
            CreatedBy,
			LabelColor,
			IsLabel
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
               @UserId AS CreatedBy,
			   '',
			   'false'
        FROM dbo.WebAppHeaders AS WAH
            INNER JOIN dbo.EstablishmentGroup AS EG
                ON EG.Id = @ActivityId
        WHERE WAH.IsDeleted = 0
               AND (WAH.IsLabel = 0 OR WAH.IsLabel IS NULL)
              AND EG.IsDeleted = 0
        ORDER BY EG.Id,
                 WAH.Id ASC;

        INSERT INTO dbo.HeaderSetting
        (
            GroupId,
            EstablishmentGroupId,
            HeaderId,
            HeaderName,
            HeaderValue,
            CreatedOn,
            CreatedBy,
			LabelColor,
			IsLabel
        )
        SELECT EG.GroupId,
               EG.Id AS ActivityId,
               WAH.Id AS HeaderId,
               LabelName AS HeaderName,
               CASE
                   WHEN LabelName = 'import Unallocated' THEN
                       'import'
                   WHEN LabelName = 'Import History' THEN
                       'Import'
                   WHEN LabelName = 'Unresolved Count' THEN
                       'Unresolved'
                   ELSE
                       LabelName
               END AS HeaderValue,
               GETDATE() AS CreatedOn,
               @UserId AS CreatedBy,
			   '',
			   'true'
        FROM dbo.WebAppHeaders AS WAH
            INNER JOIN dbo.EstablishmentGroup AS EG
                ON EG.Id = @ActivityId
        WHERE WAH.IsDeleted = 0
              AND WAH.IsLabel = 1
              AND EG.IsDeleted = 0
        ORDER BY EG.Id,
                 WAH.Id ASC;
        ---------------------------------------------------------------------------------------------------------------------------------------------
        SELECT SCOPE_IDENTITY() AS InsertedId;
        INSERT INTO dbo.ActivityLog
        (
            UserId,
            PageId,
            AuditComments,
            TableName,
            RecordId,
            CreatedOn,
            CreatedBy,
            IsDeleted
        )
        VALUES
        (@UserId, 40, 'Insert record in table HeaderSetting', 'HeaderSetting', 1, GETDATE(), @UserId, 0);
    END;
END;
