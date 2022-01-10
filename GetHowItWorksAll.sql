-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,, 06 Jun 2015>
-- Description:	<Description,,GetHowItWorksAll>
-- Call SP    :	GetHowItWorksAll
-- =============================================
CREATE PROCEDURE [dbo].[GetHowItWorksAll]
	@UserID INT
AS 
    BEGIN

		DECLARE @AdminRole bigint ,
		@UserRole bigint ,
		@PageID bigint

		SELECT TOP 1 @AdminRole = Id FROM [dbo].[Role] WHERE RoleName = 'Admin'
		SELECT TOP 1 @UserRole = RoleId FROM dbo.[User] WHERE Id = @UserId
		SELECT TOP 1 @PageID = Id FROM dbo.Page WHERE PageName = 'HowItWorks'

		IF @AdminRole = @UserRole
		BEGIN

			SELECT  dbo.[HowItWorks].[Id] AS Id ,
					dbo.[HowItWorks].[HowItWorksName] AS HowItWorksName ,
					dbo.[HowItWorks].[HowItWorks] AS HowItWorks
			FROM    dbo.[HowItWorks]
			WHERE   dbo.[HowItWorks].IsDeleted = 0
		END
		ELSE
		BEGIN

			SELECT  dbo.[HowItWorks].[Id] AS Id ,
					dbo.[HowItWorks].[HowItWorksName] AS HowItWorksName ,
					dbo.[HowItWorks].[HowItWorks] AS HowItWorks
			FROM    dbo.[HowItWorks]
			INNER JOIN dbo.UserRolePermissions ON dbo.UserRolePermissions.PageID = @PageID
				AND dbo.UserRolePermissions.ActualID = dbo.HowItWorks.Id
				AND dbo.UserRolePermissions.UserID = @UserID
			WHERE   dbo.[HowItWorks].IsDeleted = 0

		END
    END;