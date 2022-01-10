-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,, 08 Jun 2015>
-- Description:	<Description,,GetEstablishmentAll>
-- Call SP    :	SearchEstablishment 100, 1, '', '', 201,7871
-- =============================================
CREATE PROCEDURE [dbo].[SearchEstablishment]
    @Rows INT ,
    @Page INT ,
    @Search NVARCHAR(500) ,
    @Sort NVARCHAR(50) ,
    @GroupId BIGINT,
	@UserID INT
AS
    BEGIN
        DECLARE @Start AS INT ,
            @End INT ,
			@AdminRole bigint ,
			@UserRole bigint ,
			@PageID bigint;

        SET @Start = ( ( @Page * @Rows ) - @Rows ) + 1;
        SET @End = @Start + @Rows - 1;

		
		SELECT TOP 1 @AdminRole = Id FROM [dbo].[Role] WHERE RoleName = 'Admin'
		SELECT TOP 1 @UserRole = RoleId FROM dbo.[User] WHERE Id = @UserId
		SELECT TOP 1 @PageID = Id FROM dbo.Page WHERE PageName = 'Establishment'

		IF @AdminRole = @UserRole
		BEGIN
		    PRINT '1'
			SELECT  RowNum ,
					ISNULL(Total, 0) AS Total ,
					Id ,
					GroupId ,
					GroupName ,
					EstablishmentGroupId ,
					EstablishmentGroupName ,
					EstablishmentName ,
					UniqueSMSKeyword ,
					CommonSMSKeyword,
					EstablishmentGroupType ,
					FeedbackOnce,
					IsTellUs
			FROM    ( SELECT    dbo.[Establishment].[Id] AS Id ,
								dbo.[Establishment].[GroupId] AS GroupId ,
								dbo.[Group].GroupName ,
								dbo.[Establishment].[EstablishmentGroupId] AS EstablishmentGroupId ,
								dbo.[EstablishmentGroup].EstablishmentGroupName ,
								dbo.[Establishment].[EstablishmentName] AS EstablishmentName ,
								dbo.[Establishment].[UniqueSMSKeyword] AS UniqueSMSKeyword ,
								CASE dbo.[Establishment].[CommonSMSKeyword] WHEN NULL THEN dbo.[Establishment].[CommonSMSKeyword] ELSE dbo.[Establishment].[CommonSMSKeyword] + ' (' + CONVERT(NVARCHAR(5),dbo.EstablishmentGroup.ConfigureImageSequence) + ')' end CommonSMSKeyword ,
								dbo.[EstablishmentGroup].EstablishmentGroupType ,
								FeedbackOnce ,
								    ISNULL(CAST(CASE ISNULL(EstablishmentGroup.EstablishmentGroupId, 0)
                              WHEN 0 THEN 1
                              ELSE 0
                            END AS BIT), 0) AS IsTellUs ,
								COUNT(*) OVER ( PARTITION BY 1 ) AS Total ,
								ROW_NUMBER() OVER ( ORDER BY CASE WHEN @Sort = 'Id Asc'
																  THEN dbo.[Group].[Id]
															 END ASC, CASE
																  WHEN @Sort = 'Id DESC'
																  THEN dbo.[Group].[Id]
																  END DESC, CASE
																  WHEN @Sort = 'EstablishmentGroupName Asc'
																  THEN dbo.[EstablishmentGroup].EstablishmentGroupName
																  END ASC, CASE
																  WHEN @Sort = 'EstablishmentGroupName DESC'
																  THEN dbo.[EstablishmentGroup].EstablishmentGroupName
																  END DESC, CASE
																  WHEN @Sort = 'GroupName Asc'
																  THEN dbo.[Group].[GroupName]
																  END ASC, CASE
																  WHEN @Sort = 'GroupName DESC'
																  THEN dbo.[Group].[GroupName]
																  END DESC, CASE
																  WHEN @Sort = 'EstablishmentName Asc'
																  THEN dbo.[Establishment].[EstablishmentName]
																  END ASC, CASE
																  WHEN @Sort = 'EstablishmentName DESC'
																  THEN dbo.[Establishment].[EstablishmentName]
																  END DESC, CASE
																  WHEN @Sort = 'UniqueSMSKeyword Asc'
																  THEN dbo.[Establishment].[UniqueSMSKeyword]
																  END ASC, CASE
																  WHEN @Sort = 'UniqueSMSKeyword DESC'
																  THEN dbo.[Establishment].[UniqueSMSKeyword]
																  END DESC , CASE
																  WHEN @Sort = 'CommonSMSKeyword Asc'
																  THEN dbo.[Establishment].[CommonSMSKeyword]
																  END ASC, CASE
																  WHEN @Sort = 'CommonSMSKeyword DESC'
																  THEN dbo.[Establishment].[CommonSMSKeyword]
																  END DESC , CASE
																  WHEN @Sort = 'CreatedOn Asc'
																  THEN dbo.[Establishment].CreatedOn
																  END ASC, CASE
																  WHEN @Sort = 'CreatedOn DESC'
																  THEN dbo.[Establishment].CreatedOn
																  END DESC ) AS RowNum
					  FROM      dbo.[Establishment]
								INNER JOIN dbo.[Group] ON dbo.Establishment.GroupId = dbo.[Group].Id
								INNER JOIN dbo.EstablishmentGroup ON dbo.Establishment.EstablishmentGroupId = dbo.EstablishmentGroup.Id
					  WHERE     dbo.[Group].IsDeleted = 0
								AND dbo.[Establishment].IsDeleted = 0
								AND ( EstablishmentName LIKE '%' + @Search + '%'
									  OR EstablishmentGroupName LIKE '%' + @Search
									  + '%'
									  OR GroupName LIKE '%' + @Search + '%'
									  OR UniqueSMSKeyword LIKE '%' + @Search + '%'
									)
								AND ( Establishment.GroupId = @GroupId
									  OR @GroupId = 0
									)
					) AS T
			WHERE   RowNum BETWEEN @Start AND @End;
		END
		ELSE
		BEGIN
		    PRINT '2'
			SELECT  RowNum ,
					ISNULL(Total, 0) AS Total ,
					Id ,
					GroupId ,
					GroupName ,
					EstablishmentGroupId ,
					EstablishmentGroupName ,
					EstablishmentName ,
					UniqueSMSKeyword ,
					CommonSMSKeyword,
					EstablishmentGroupType ,
					FeedbackOnce,
					IsTellUs
			FROM    ( SELECT    dbo.[Establishment].[Id] AS Id ,
								dbo.[Establishment].[GroupId] AS GroupId ,
								dbo.[Group].GroupName ,
								dbo.[Establishment].[EstablishmentGroupId] AS EstablishmentGroupId ,
								dbo.[EstablishmentGroup].EstablishmentGroupName ,
								dbo.[Establishment].[EstablishmentName] AS EstablishmentName ,
								dbo.[Establishment].[UniqueSMSKeyword] AS UniqueSMSKeyword ,
								CASE dbo.[Establishment].[CommonSMSKeyword] WHEN NULL THEN dbo.[Establishment].[CommonSMSKeyword] ELSE dbo.[Establishment].[CommonSMSKeyword] + ' (' + CONVERT(NVARCHAR(5),dbo.EstablishmentGroup.ConfigureImageSequence) + ')' end CommonSMSKeyword ,
								dbo.[EstablishmentGroup].EstablishmentGroupType ,
								FeedbackOnce ,
								ISNULL(CAST(CASE ISNULL(EstablishmentGroup.EstablishmentGroupId, 0)
                              WHEN 0 THEN 1
                              ELSE 0
                            END AS BIT), 0) AS IsTellUs ,
								COUNT(*) OVER ( PARTITION BY 1 ) AS Total ,
								ROW_NUMBER() OVER ( ORDER BY CASE WHEN @Sort = 'Id Asc'
																  THEN dbo.[Group].[Id]
															 END ASC, CASE
																  WHEN @Sort = 'Id DESC'
																  THEN dbo.[Group].[Id]
																  END DESC, CASE
																  WHEN @Sort = 'EstablishmentGroupName Asc'
																  THEN dbo.[EstablishmentGroup].EstablishmentGroupName
																  END ASC, CASE
																  WHEN @Sort = 'EstablishmentGroupName DESC'
																  THEN dbo.[EstablishmentGroup].EstablishmentGroupName
																  END DESC, CASE
																  WHEN @Sort = 'GroupName Asc'
																  THEN dbo.[Group].[GroupName]
																  END ASC, CASE
																  WHEN @Sort = 'GroupName DESC'
																  THEN dbo.[Group].[GroupName]
																  END DESC, CASE
																  WHEN @Sort = 'EstablishmentName Asc'
																  THEN dbo.[Establishment].[EstablishmentName]
																  END ASC, CASE
																  WHEN @Sort = 'EstablishmentName DESC'
																  THEN dbo.[Establishment].[EstablishmentName]
																  END DESC, CASE
																  WHEN @Sort = 'UniqueSMSKeyword Asc'
																  THEN dbo.[Establishment].[UniqueSMSKeyword]
																  END ASC, CASE
																  WHEN @Sort = 'UniqueSMSKeyword DESC'
																  THEN dbo.[Establishment].[UniqueSMSKeyword]
																  END DESC , CASE
																  WHEN @Sort = 'CommonSMSKeyword Asc'
																  THEN dbo.[Establishment].[CommonSMSKeyword]
																  END ASC, CASE
																  WHEN @Sort = 'CommonSMSKeyword DESC'
																  THEN dbo.[Establishment].[CommonSMSKeyword]
																  END DESC , CASE
																  WHEN @Sort = 'CreatedOn Asc'
																  THEN dbo.[Establishment].CreatedOn
																  END ASC, CASE
																  WHEN @Sort = 'CreatedOn DESC'
																  THEN dbo.[Establishment].CreatedOn
																  END DESC ) AS RowNum
					  FROM      dbo.[Establishment]
								INNER JOIN dbo.[Group] ON dbo.Establishment.GroupId = dbo.[Group].Id
								INNER JOIN dbo.EstablishmentGroup ON dbo.Establishment.EstablishmentGroupId = dbo.EstablishmentGroup.Id
								INNER JOIN dbo.UserRolePermissions ON dbo.UserRolePermissions.PageID = @PageID
									AND dbo.UserRolePermissions.ActualID = dbo.Establishment.Id
									AND dbo.UserRolePermissions.UserID = @UserID
					  WHERE     dbo.[Group].IsDeleted = 0
								AND dbo.[Establishment].IsDeleted = 0
								AND ( EstablishmentName LIKE '%' + @Search + '%'
									  OR EstablishmentGroupName LIKE '%' + @Search
									  + '%'
									  OR GroupName LIKE '%' + @Search + '%'
									  OR UniqueSMSKeyword LIKE '%' + @Search + '%'
									)
								AND ( Establishment.GroupId = @GroupId
									  OR @GroupId = 0
									)
					) AS T
			WHERE   RowNum BETWEEN @Start AND @End;
		END
    END;
