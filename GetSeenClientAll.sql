-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,, 28 May 2015>
-- Description:	<Description,,GetSeenClientAll>
-- Call SP    :	GetSeenClientAll
-- =============================================
CREATE PROCEDURE dbo.GetSeenClientAll @UserID INT
AS
BEGIN
    DECLARE @AdminRole BIGINT,
            @UserRole BIGINT,
            @PageID BIGINT;

    SELECT TOP 1
           @AdminRole = Id
    FROM [dbo].[Role]
    WHERE RoleName = 'Admin';
    SELECT TOP 1
           @UserRole = RoleId
    FROM dbo.[User]
    WHERE Id = @UserID;
    SELECT TOP 1
           @PageID = Id
    FROM dbo.Page
    WHERE PageName = 'SeenClient';

    IF @AdminRole = @UserRole
    BEGIN
        SELECT dbo.[SeenClient].[Id] AS Id,
               dbo.[SeenClient].[SeenClientTitle] AS SeenClientTitle,
               dbo.[SeenClient].[Description] AS Description
        FROM dbo.[SeenClient]
        WHERE dbo.[SeenClient].IsDeleted = 0
        ORDER BY SeenClientTitle;
    END;
    ELSE
    BEGIN
        SELECT dbo.[SeenClient].[Id] AS Id,
               dbo.[SeenClient].[SeenClientTitle] AS SeenClientTitle,
               dbo.[SeenClient].[Description] AS Description
        FROM dbo.[SeenClient]
            INNER JOIN dbo.UserRolePermissions
                ON dbo.UserRolePermissions.PageID = @PageID
                   AND dbo.UserRolePermissions.ActualID = dbo.SeenClient.Id
                   AND dbo.UserRolePermissions.UserID = @UserID
        WHERE dbo.[SeenClient].IsDeleted = 0
        ORDER BY SeenClientTitle;

    END;
END;
