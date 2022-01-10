-- =============================================
-- Author:		<Author,,Gd>
-- Create date: <Create Date,, 06 Jun 2015>
-- Description:	<Description,,GetEstablishmentGroupAll>
-- Call SP    :	SearchEstablishmentGroup 2, 2, '', ''
-- =============================================
CREATE PROCEDURE [dbo].[SearchEstablishmentGroup]
    @Rows INT ,
    @Page INT ,
    @Search NVARCHAR(500) ,
    @Sort NVARCHAR(50) ,
    @GroupId BIGINT ,
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
		SELECT TOP 1 @PageID = Id FROM dbo.Page WHERE PageName = 'EstablishmentGroup'

        DECLARE @Sql NVARCHAR(MAX);

		IF @AdminRole = @UserRole
		BEGIN

			SELECT  RowNum ,
					ISNULL(Total, 0) AS Total ,
					Id ,
					GroupId ,
					GroupName ,
					EstablishmentGroupName ,
					EstablishmentGroupType ,
					AboutEstablishmentGroup ,
					QuestionnaireId ,
					QuestionnaireTitle ,
					SeenClientId ,
					SeenClientTitle ,
					HowItWorksId ,
					SMSReminder ,
					EmailReminder ,
					ContactTitle ,
					ContactId
			FROM    ( SELECT    dbo.[EstablishmentGroup].[Id] AS Id ,
								dbo.[EstablishmentGroup].[GroupId] AS GroupId ,
								dbo.[Group].GroupName ,
								dbo.[EstablishmentGroup].[EstablishmentGroupName] AS EstablishmentGroupName ,
								dbo.[EstablishmentGroup].[EstablishmentGroupType] AS EstablishmentGroupType ,
								dbo.[EstablishmentGroup].[AboutEstablishmentGroup] AS AboutEstablishmentGroup ,
								dbo.[EstablishmentGroup].[QuestionnaireId] AS QuestionnaireId ,
								dbo.[Questionnaire].QuestionnaireTitle ,
								dbo.[EstablishmentGroup].[SeenClientId] AS SeenClientId ,
								dbo.[SeenClient].SeenClientTitle ,
								dbo.[EstablishmentGroup].[HowItWorksId] AS HowItWorksId ,
								dbo.[EstablishmentGroup].[SMSReminder] AS SMSReminder ,
								dbo.[EstablishmentGroup].[EmailReminder] AS EmailReminder ,
								C.ContactTitle ,
								ContactId ,
								COUNT(*) OVER ( PARTITION BY 1 ) AS Total ,
								ROW_NUMBER() OVER ( ORDER BY CASE WHEN @Sort = 'GroupName Asc'
																  THEN dbo.[EstablishmentGroup].[GroupId]
															 END ASC, CASE
																  WHEN @Sort = 'GroupName DESC'
																  THEN dbo.[EstablishmentGroup].[GroupId]
																  END DESC, CASE
																  WHEN @Sort = 'EstablishmentGroupName Asc'
																  THEN dbo.[EstablishmentGroup].[EstablishmentGroupName]
																  END ASC, CASE
																  WHEN @Sort = 'EstablishmentGroupName DESC'
																  THEN dbo.[EstablishmentGroup].[EstablishmentGroupName]
																  END DESC, CASE
																  WHEN @Sort = 'EstablishmentGroupType Asc'
																  THEN dbo.[EstablishmentGroup].[EstablishmentGroupType]
																  END ASC, CASE
																  WHEN @Sort = 'EstablishmentGroupType DESC'
																  THEN dbo.[EstablishmentGroup].[EstablishmentGroupType]
																  END DESC, CASE
																  WHEN @Sort = 'QuestionnaireTitle Asc'
																  THEN dbo.[Questionnaire].QuestionnaireTitle
																  END ASC, CASE
																  WHEN @Sort = 'QuestionnaireTitle DESC'
																  THEN dbo.[Questionnaire].QuestionnaireTitle
																  END DESC, CASE
																  WHEN @Sort = 'ContactTitle Asc'
																  THEN ContactTitle
																  END ASC, CASE
																  WHEN @Sort = 'ContactTitle DESC'
																  THEN ContactTitle
																  END DESC, CASE
																  WHEN @Sort = 'SeenClientTitle Asc'
																  THEN SeenClientTitle
																  END ASC, CASE
																  WHEN @Sort = 'SeenClientTitle DESC'
																  THEN SeenClientTitle
																  END DESC, CASE
																  WHEN @Sort = 'CreatedOn Asc'
																  THEN dbo.[EstablishmentGroup].CreatedOn
																  END ASC, CASE
																  WHEN @Sort = 'CreatedOn DESC'
																  THEN dbo.[EstablishmentGroup].CreatedOn
																  END DESC ) AS RowNum
					  FROM      dbo.[EstablishmentGroup]
								INNER JOIN dbo.[Group] ON dbo.[Group].Id = dbo.[EstablishmentGroup].GroupId
								INNER JOIN dbo.Contact AS C ON C.Id = [Group].ContactId
								INNER JOIN dbo.[Questionnaire] ON dbo.[Questionnaire].Id = dbo.[EstablishmentGroup].QuestionnaireId
								LEFT OUTER JOIN dbo.[SeenClient] ON dbo.[SeenClient].Id = dbo.[EstablishmentGroup].SeenClientId
					  WHERE     dbo.[EstablishmentGroup].IsDeleted = 0
								AND ( dbo.[Group].GroupName LIKE '%' + @Search
									  + '%'
									  OR ISNULL(dbo.[EstablishmentGroup].[EstablishmentGroupName],
												'') LIKE '%' + @Search + '%'
									  OR ISNULL(dbo.[EstablishmentGroup].[EstablishmentGroupType],
												'') LIKE '%' + @Search + '%'
									  OR ISNULL(dbo.[Questionnaire].QuestionnaireTitle,
												'') LIKE '%' + @Search + '%'
									  OR ISNULL(dbo.[SeenClient].SeenClientTitle,
												'') LIKE '%' + @Search + '%'
									  OR ISNULL(C.ContactTitle, '') LIKE '%'
									  + @Search + '%'
									)
								AND ( dbo.[Group].Id = @GroupId
									  OR @GroupId = 0
									)
					) AS T
			WHERE   RowNum BETWEEN @Start AND @End;
		END
		ELSE
		BEGIN
			
						SELECT  RowNum ,
					ISNULL(Total, 0) AS Total ,
					Id ,
					GroupId ,
					GroupName ,
					EstablishmentGroupName ,
					EstablishmentGroupType ,
					AboutEstablishmentGroup ,
					QuestionnaireId ,
					QuestionnaireTitle ,
					SeenClientId ,
					SeenClientTitle ,
					HowItWorksId ,
					SMSReminder ,
					EmailReminder ,
					ContactTitle ,
					ContactId
			FROM    ( SELECT    dbo.[EstablishmentGroup].[Id] AS Id ,
								dbo.[EstablishmentGroup].[GroupId] AS GroupId ,
								dbo.[Group].GroupName ,
								dbo.[EstablishmentGroup].[EstablishmentGroupName] AS EstablishmentGroupName ,
								dbo.[EstablishmentGroup].[EstablishmentGroupType] AS EstablishmentGroupType ,
								dbo.[EstablishmentGroup].[AboutEstablishmentGroup] AS AboutEstablishmentGroup ,
								dbo.[EstablishmentGroup].[QuestionnaireId] AS QuestionnaireId ,
								dbo.[Questionnaire].QuestionnaireTitle ,
								dbo.[EstablishmentGroup].[SeenClientId] AS SeenClientId ,
								dbo.[SeenClient].SeenClientTitle ,
								dbo.[EstablishmentGroup].[HowItWorksId] AS HowItWorksId ,
								dbo.[EstablishmentGroup].[SMSReminder] AS SMSReminder ,
								dbo.[EstablishmentGroup].[EmailReminder] AS EmailReminder ,
								C.ContactTitle ,
								ContactId ,
								COUNT(*) OVER ( PARTITION BY 1 ) AS Total ,
								ROW_NUMBER() OVER ( ORDER BY CASE WHEN @Sort = 'GroupName Asc'
																  THEN dbo.[EstablishmentGroup].[GroupId]
															 END ASC, CASE
																  WHEN @Sort = 'GroupName DESC'
																  THEN dbo.[EstablishmentGroup].[GroupId]
																  END DESC, CASE
																  WHEN @Sort = 'EstablishmentGroupName Asc'
																  THEN dbo.[EstablishmentGroup].[EstablishmentGroupName]
																  END ASC, CASE
																  WHEN @Sort = 'EstablishmentGroupName DESC'
																  THEN dbo.[EstablishmentGroup].[EstablishmentGroupName]
																  END DESC, CASE
																  WHEN @Sort = 'EstablishmentGroupType Asc'
																  THEN dbo.[EstablishmentGroup].[EstablishmentGroupType]
																  END ASC, CASE
																  WHEN @Sort = 'EstablishmentGroupType DESC'
																  THEN dbo.[EstablishmentGroup].[EstablishmentGroupType]
																  END DESC, CASE
																  WHEN @Sort = 'QuestionnaireTitle Asc'
																  THEN dbo.[Questionnaire].QuestionnaireTitle
																  END ASC, CASE
																  WHEN @Sort = 'QuestionnaireTitle DESC'
																  THEN dbo.[Questionnaire].QuestionnaireTitle
																  END DESC, CASE
																  WHEN @Sort = 'ContactTitle Asc'
																  THEN ContactTitle
																  END ASC, CASE
																  WHEN @Sort = 'ContactTitle DESC'
																  THEN ContactTitle
																  END DESC, CASE
																  WHEN @Sort = 'SeenClientTitle Asc'
																  THEN SeenClientTitle
																  END ASC, CASE
																  WHEN @Sort = 'SeenClientTitle DESC'
																  THEN SeenClientTitle
																  END DESC, CASE
																  WHEN @Sort = 'CreatedOn Asc'
																  THEN dbo.[EstablishmentGroup].CreatedOn
																  END ASC, CASE
																  WHEN @Sort = 'CreatedOn DESC'
																  THEN dbo.[EstablishmentGroup].CreatedOn
																  END DESC ) AS RowNum
					  FROM      dbo.[EstablishmentGroup]
								INNER JOIN dbo.[Group] ON dbo.[Group].Id = dbo.[EstablishmentGroup].GroupId
								INNER JOIN dbo.Contact AS C ON C.Id = [Group].ContactId
								INNER JOIN dbo.[Questionnaire] ON dbo.[Questionnaire].Id = dbo.[EstablishmentGroup].QuestionnaireId
								LEFT OUTER JOIN dbo.[SeenClient] ON dbo.[SeenClient].Id = dbo.[EstablishmentGroup].SeenClientId
								INNER JOIN dbo.UserRolePermissions ON dbo.UserRolePermissions.PageID = @PageID
								AND dbo.UserRolePermissions.ActualID = dbo.EstablishmentGroup.Id
								AND dbo.UserRolePermissions.UserID = @UserID
					  WHERE     dbo.[EstablishmentGroup].IsDeleted = 0
								AND ( dbo.[Group].GroupName LIKE '%' + @Search
									  + '%'
									  OR ISNULL(dbo.[EstablishmentGroup].[EstablishmentGroupName],
												'') LIKE '%' + @Search + '%'
									  OR ISNULL(dbo.[EstablishmentGroup].[EstablishmentGroupType],
												'') LIKE '%' + @Search + '%'
									  OR ISNULL(dbo.[Questionnaire].QuestionnaireTitle,
												'') LIKE '%' + @Search + '%'
									  OR ISNULL(dbo.[SeenClient].SeenClientTitle,
												'') LIKE '%' + @Search + '%'
									  OR ISNULL(C.ContactTitle, '') LIKE '%'
									  + @Search + '%'
									)
								AND ( dbo.[Group].Id = @GroupId
									  OR @GroupId = 0
									)
					) AS T
			WHERE   RowNum BETWEEN @Start AND @End;

		END
    END;