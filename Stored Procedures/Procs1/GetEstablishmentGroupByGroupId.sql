
-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,08 Jun 2015>
-- Description:	<Description,,>
-- Call SP:		GetEstablishmentGroupByGroupId 1
-- =============================================
CREATE PROCEDURE [dbo].[GetEstablishmentGroupByGroupId] 
	@GroupId BIGINT,
	@UserID INT
AS 
    BEGIN
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
	DECLARE @AdminRole bigint ,
		@UserRole bigint ,
		@PageID bigint

		SELECT TOP 1 @AdminRole = Id FROM [dbo].[Role] WHERE RoleName = 'Admin'
		SELECT TOP 1 @UserRole = RoleId FROM dbo.[User] WHERE Id = @UserId
		SELECT TOP 1 @PageID = Id FROM dbo.Page WHERE PageName = 'EstablishmentGroup'

		IF @AdminRole = @UserRole
		BEGIN

			SELECT  Id, EstablishmentGroupName, EstablishmentGroupType
			FROM    dbo.EstablishmentGroup
			WHERE   GroupId = @GroupId
					AND IsDeleted = 0

		END
		ELSE
		BEGIN

			SELECT  EstablishmentGroup.Id, EstablishmentGroupName, EstablishmentGroupType
			FROM    dbo.EstablishmentGroup
			INNER JOIN dbo.UserRolePermissions ON dbo.UserRolePermissions.PageID = @PageID
				AND dbo.UserRolePermissions.ActualID = dbo.EstablishmentGroup.Id
				AND dbo.UserRolePermissions.UserID = @UserID
			WHERE   GroupId = @GroupId
					AND EstablishmentGroup.IsDeleted = 0

		END
		END TRY

BEGIN CATCH
	INSERT INTO dbo.ErrorLog
        (
            PageId,
            MethodName,
            ErrorType,
            ErrorMessage,
            ErrorDetails,
            ErrorDate,
            UserId,
            Solution,
            CreatedOn,
            CreatedBy
        )
        VALUES
        (ERROR_LINE(),
         'dbo.GetEstablishmentGroupByGroupId',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         N'',
         @GroupId+','+@UserID,
         GETUTCDATE(),
         N''
        );
END CATCH
    END
