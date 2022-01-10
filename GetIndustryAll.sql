

-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 26 May 2015>
-- Description:	<Description,,GetIndustryAll>
-- Call SP    :	GetIndustryAll
-- =============================================
CREATE PROCEDURE [dbo].[GetIndustryAll]
	@UserID INT
AS
BEGIN

		DECLARE @AdminRole bigint ,
		@UserRole bigint ,
		@PageID bigint

		SELECT TOP 1 @AdminRole = Id FROM [dbo].[Role] WHERE RoleName = 'Admin'
		SELECT TOP 1 @UserRole = RoleId FROM dbo.[User] WHERE Id = @UserId
		SELECT TOP 1 @PageID = Id FROM dbo.Page WHERE PageName = 'Industry'

		IF @AdminRole = @UserRole
		BEGIN

			SELECT  dbo.[Industry].[Id] AS Id , 
					dbo.[Industry].[IndustryName] AS IndustryName , 
					dbo.[Industry].[AboutIndustry] AS AboutIndustry  
			FROM dbo.[Industry] 
			WHERE dbo.[Industry].IsDeleted = 0 ORDER BY IndustryName ASC

		END
		ELSE
		BEGIN

			SELECT  dbo.[Industry].[Id] AS Id , 
					dbo.[Industry].[IndustryName] AS IndustryName , 
					dbo.[Industry].[AboutIndustry] AS AboutIndustry  
			FROM dbo.[Industry] 
			INNER JOIN dbo.UserRolePermissions ON dbo.UserRolePermissions.PageID = @PageID
				AND dbo.UserRolePermissions.ActualID = dbo.Industry.Id
				AND dbo.UserRolePermissions.UserID = @UserID
			WHERE dbo.[Industry].IsDeleted = 0 ORDER BY IndustryName ASC

		END

END;