-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 16 Dec 2016>
-- Description:	<Description,,InsertOrUpdateHeaderSetting>
-- Call SP    :	InsertOrUpdateHeaderSetting
-- =============================================
CREATE PROCEDURE dbo.InsertOrUpdateHeaderSetting
    @GroupId BIGINT,
    @ActivityId BIGINT,
    @HeaderId BIGINT,
    @HeaderName NVARCHAR(2000),
    @HeaderValue NVARCHAR(2000),
    @LabelColor NVARCHAR(100),
    @IsLabel BIT,
    @UserId BIGINT,
    @PageId BIGINT
AS
BEGIN

    DECLARE @HeaderSettingId BIGINT = 0;
    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.HeaderSetting
        WHERE [HeaderId] = @HeaderId
              AND EstablishmentGroupId = @ActivityId
              AND GroupId = @GroupId AND IsDeleted = 0
    )
    BEGIN
        INSERT INTO dbo.[HeaderSetting]
        (
            [GroupId],
            [EstablishmentGroupId],
            [HeaderId],
            [HeaderName],
            [HeaderValue],
            [CreatedOn],
            [CreatedBy],
            [IsDeleted],
            LabelColor,
            IsLabel
        )
        VALUES
        (@GroupId, @ActivityId, @HeaderId, @HeaderName, @HeaderValue, GETUTCDATE(), @UserId, 0, @LabelColor, @IsLabel);
        SELECT @HeaderSettingId = SCOPE_IDENTITY();
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
        (@UserId,
         @PageId,
         'Insert record in table HeaderSetting',
         'HeaderSetting',
         @HeaderSettingId,
         GETUTCDATE(),
         @UserId,
         0
        );
    END;
    ELSE
    BEGIN
        IF @HeaderId = 1
           OR @HeaderId = 15
        --OR @HeaderId = 2
        BEGIN
            UPDATE dbo.[HeaderSetting]
            SET [HeaderValue] = @HeaderValue,
                LabelColor = @LabelColor,
                [UpdatedOn] = GETUTCDATE(),
                [UpdatedBy] = @UserId
            WHERE [HeaderId] = @HeaderId
                  AND GroupId = @GroupId;
        END;
        ELSE
        BEGIN
            UPDATE dbo.[HeaderSetting]
            SET [HeaderValue] = @HeaderValue,
                LabelColor = @LabelColor,
                [UpdatedOn] = GETUTCDATE(),
                [UpdatedBy] = @UserId
            WHERE [HeaderId] = @HeaderId
                  AND EstablishmentGroupId = @ActivityId
                  AND GroupId = @GroupId;
        END;

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
        (@UserId,
         @PageId,
         'Update record in table HeaderSetting',
         'HeaderSetting',
         @HeaderSettingId,
         GETUTCDATE(),
         @UserId,
         0
        );

        SET @HeaderSettingId =
        (
            SELECT TOP 1 HeaderSettingId
            FROM dbo.HeaderSetting
            WHERE [HeaderId] = @HeaderId
                  AND EstablishmentGroupId = @ActivityId
                  AND GroupId = @GroupId
        );

    END;
    SELECT ISNULL(@HeaderSettingId, 0) AS InsertedId;
END;
