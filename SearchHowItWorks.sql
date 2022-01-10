-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,, 06 Jun 2015>
-- Description:	<Description,,GetHowItWorksAll>
-- Call SP    :	SearchHowItWorks 1, 1, '', ''
-- =============================================
CREATE PROCEDURE [dbo].[SearchHowItWorks]
    @Rows INT ,
    @Page INT ,
    @Search NVARCHAR(500) ,
    @Sort NVARCHAR(50) ,
	@UserID INT
AS
    BEGIN
        DECLARE @Start AS INT ,
            @End INT,
			@AdminRole bigint ,
			@UserRole bigint ,
			@PageID bigint;

        SET @Start = ( ( @Page * @Rows ) - @Rows ) + 1;
        SET @End = @Start + @Rows - 1;

		SELECT TOP 1 @AdminRole = Id FROM [dbo].[Role] WHERE RoleName = 'Admin'
		SELECT TOP 1 @UserRole = RoleId FROM dbo.[User] WHERE Id = @UserId
		SELECT TOP 1 @PageID = Id FROM dbo.Page WHERE PageName = 'HowItWorks'

        DECLARE @Sql NVARCHAR(MAX);

		IF @AdminRole = @UserRole
		BEGIN

			SELECT  RowNum ,
					ISNULL(Total, 0) AS Total ,
					Id ,
					HowItWorksName ,
					HowItWorks
			FROM    ( SELECT    dbo.[HowItWorks].[Id] AS Id ,
								dbo.[HowItWorks].[HowItWorksName] AS HowItWorksName ,
								dbo.[HowItWorks].[HowItWorks] AS HowItWorks ,
								COUNT(*) OVER ( PARTITION BY 1 ) AS Total ,
								ROW_NUMBER() OVER ( ORDER BY CASE WHEN @Sort = 'Id Asc'
																  THEN dbo.[HowItWorks].[Id]
															 END ASC, CASE
																  WHEN @Sort = 'Id DESC'
																  THEN dbo.[HowItWorks].[Id]
																  END DESC, CASE
																  WHEN @Sort = 'HowItWorksName Asc'
																  THEN dbo.[HowItWorks].[HowItWorksName]
																  END ASC, CASE
																  WHEN @Sort = 'HowItWorksName DESC'
																  THEN dbo.[HowItWorks].[HowItWorksName]
																  END DESC, CASE
																  WHEN @Sort = 'CreatedOn Asc'
																  THEN dbo.[HowItWorks].CreatedOn
																  END ASC, CASE
																  WHEN @Sort = 'CreatedOn DESC'
																  THEN dbo.[HowItWorks].CreatedOn
																  END DESC ) AS RowNum
					  FROM      dbo.[HowItWorks]
					  WHERE     dbo.[HowItWorks].IsDeleted = 0
								AND ( ISNULL(dbo.[HowItWorks].[HowItWorksName], '') LIKE '%'
									  + @Search + '%' )
					) AS T
			WHERE   RowNum BETWEEN @Start AND @End;
		END
		ELSE
		BEGIN

			SELECT  RowNum ,
					ISNULL(Total, 0) AS Total ,
					Id ,
					HowItWorksName ,
					HowItWorks
			FROM    ( SELECT    dbo.[HowItWorks].[Id] AS Id ,
								dbo.[HowItWorks].[HowItWorksName] AS HowItWorksName ,
								dbo.[HowItWorks].[HowItWorks] AS HowItWorks ,
								COUNT(*) OVER ( PARTITION BY 1 ) AS Total ,
								ROW_NUMBER() OVER ( ORDER BY CASE WHEN @Sort = 'Id Asc'
																  THEN dbo.[HowItWorks].[Id]
															 END ASC, CASE
																  WHEN @Sort = 'Id DESC'
																  THEN dbo.[HowItWorks].[Id]
																  END DESC, CASE
																  WHEN @Sort = 'HowItWorksName Asc'
																  THEN dbo.[HowItWorks].[HowItWorksName]
																  END ASC, CASE
																  WHEN @Sort = 'HowItWorksName DESC'
																  THEN dbo.[HowItWorks].[HowItWorksName]
																  END DESC, CASE
																  WHEN @Sort = 'CreatedOn Asc'
																  THEN dbo.[HowItWorks].CreatedOn
																  END ASC, CASE
																  WHEN @Sort = 'CreatedOn DESC'
																  THEN dbo.[HowItWorks].CreatedOn
																  END DESC ) AS RowNum
					  FROM      dbo.[HowItWorks]
					  INNER JOIN dbo.UserRolePermissions ON dbo.UserRolePermissions.PageID = @PageID
						  AND dbo.UserRolePermissions.ActualID = dbo.HowItWorks.Id
						  AND dbo.UserRolePermissions.UserID = @UserID
					  WHERE     dbo.[HowItWorks].IsDeleted = 0
								AND ( ISNULL(dbo.[HowItWorks].[HowItWorksName], '') LIKE '%'
									  + @Search + '%' )
					) AS T
			WHERE   RowNum BETWEEN @Start AND @End;

		END
    END;