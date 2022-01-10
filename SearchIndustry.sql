
-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 26 May 2015>
-- Description:	<Description,,GetIndustryAll>
-- Call SP    :	SearchIndustry 1, 1, '', ''
-- =============================================
CREATE PROCEDURE [dbo].[SearchIndustry]
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
		SELECT TOP 1 @PageID = Id FROM dbo.Page WHERE PageName = 'Industry'

        DECLARE @Sql NVARCHAR(MAX);

		IF @AdminRole = @UserRole
		BEGIN

			SELECT  RowNum ,
					ISNULL(Total, 0) AS Total ,
					Id ,
					IndustryName ,
					AboutIndustry
			FROM    ( SELECT    dbo.[Industry].[Id] AS Id ,
								dbo.[Industry].[IndustryName] AS IndustryName ,
								dbo.[Industry].[AboutIndustry] AS AboutIndustry ,
								COUNT(*) OVER ( PARTITION BY 1 ) AS Total ,
								ROW_NUMBER() OVER ( ORDER BY CASE WHEN @Sort = 'Id Asc'
																  THEN dbo.[Industry].[Id]
															 END ASC, CASE
																  WHEN @Sort = 'Id DESC'
																  THEN dbo.[Industry].[Id]
																  END DESC, CASE
																  WHEN @Sort = 'IndustryName Asc'
																  THEN dbo.[Industry].[IndustryName]
																  END ASC, CASE
																  WHEN @Sort = 'IndustryName DESC'
																  THEN dbo.[Industry].[IndustryName]
																  END DESC, CASE
																  WHEN @Sort = 'AboutIndustry Asc'
																  THEN dbo.[Industry].[AboutIndustry]
																  END ASC, CASE
																  WHEN @Sort = 'AboutIndustry DESC'
																  THEN dbo.[Industry].[AboutIndustry]
																  END DESC, CASE
																  WHEN @Sort = 'CreatedOn Asc'
																  THEN dbo.[Industry].[AboutIndustry]
																  END ASC, CASE
																  WHEN @Sort = 'CreatedOn DESC'
																  THEN dbo.[Industry].CreatedOn
																  END DESC ) AS RowNum
					  FROM      dbo.[Industry]
					  WHERE     dbo.[Industry].IsDeleted = 0
								AND ( ISNULL(dbo.[Industry].[IndustryName], '') LIKE '%'
									  + @Search + '%'
									  OR ISNULL(dbo.[Industry].[AboutIndustry], '') LIKE '%'
									  + @Search + '%'
									)
					) AS T
			WHERE   RowNum BETWEEN @Start AND @End;
		END
		ELSE
		BEGIN

			SELECT  RowNum ,
						ISNULL(Total, 0) AS Total ,
						Id ,
						IndustryName ,
						AboutIndustry
				FROM    ( SELECT    dbo.[Industry].[Id] AS Id ,
									dbo.[Industry].[IndustryName] AS IndustryName ,
									dbo.[Industry].[AboutIndustry] AS AboutIndustry ,
									COUNT(*) OVER ( PARTITION BY 1 ) AS Total ,
									ROW_NUMBER() OVER ( ORDER BY CASE WHEN @Sort = 'Id Asc'
																	  THEN dbo.[Industry].[Id]
																 END ASC, CASE
																	  WHEN @Sort = 'Id DESC'
																	  THEN dbo.[Industry].[Id]
																	  END DESC, CASE
																	  WHEN @Sort = 'IndustryName Asc'
																	  THEN dbo.[Industry].[IndustryName]
																	  END ASC, CASE
																	  WHEN @Sort = 'IndustryName DESC'
																	  THEN dbo.[Industry].[IndustryName]
																	  END DESC, CASE
																	  WHEN @Sort = 'AboutIndustry Asc'
																	  THEN dbo.[Industry].[AboutIndustry]
																	  END ASC, CASE
																	  WHEN @Sort = 'AboutIndustry DESC'
																	  THEN dbo.[Industry].[AboutIndustry]
																	  END DESC, CASE
																	  WHEN @Sort = 'CreatedOn Asc'
																	  THEN dbo.[Industry].[AboutIndustry]
																	  END ASC, CASE
																	  WHEN @Sort = 'CreatedOn DESC'
																	  THEN dbo.[Industry].CreatedOn
																	  END DESC ) AS RowNum
						  FROM      dbo.[Industry]
						  INNER JOIN dbo.UserRolePermissions ON dbo.UserRolePermissions.PageID = @PageID
								AND dbo.UserRolePermissions.ActualID = dbo.Industry.Id
								AND dbo.UserRolePermissions.UserID = @UserID
						  WHERE     dbo.[Industry].IsDeleted = 0
									AND ( ISNULL(dbo.[Industry].[IndustryName], '') LIKE '%'
										  + @Search + '%'
										  OR ISNULL(dbo.[Industry].[AboutIndustry], '') LIKE '%'
										  + @Search + '%'
										)
						) AS T
				WHERE   RowNum BETWEEN @Start AND @End;
		END
    END;