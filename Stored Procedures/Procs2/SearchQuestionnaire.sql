

-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 26 May 2015>
-- Description:	<Description,,GetQuestionnaireAll>
-- Call SP    :	SearchQuestionnaire 1, 1, '', ''
-- =============================================
CREATE PROCEDURE [dbo].[SearchQuestionnaire]
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
		SELECT TOP 1 @PageID = Id FROM dbo.Page WHERE PageName = 'Questionnaire'

        DECLARE @Sql NVARCHAR(MAX);

		IF @AdminRole = @UserRole
		BEGIN

			SELECT  RowNum ,
					ISNULL(Total, 0) AS Total ,
					Id ,
					QuestionnaireTitle ,
					QuestionnaireType ,
					[Description] ,
					QuestionnaireFormType ,
					dbo.ChangeDateFormat(LastLoadedDate, 'MM/dd/yyyy hh:mm AM/PM') AS LastLoadedDate
			FROM    ( SELECT    dbo.[Questionnaire].[Id] AS Id ,
								dbo.[Questionnaire].[QuestionnaireTitle] AS QuestionnaireTitle ,
								--dbo.[Questionnaire].[QuestionnaireType] AS QuestionnaireType ,
								CASE WHEN LOWER(dbo.[Questionnaire].[QuestionnaireType])='ei' THEN 'PI' ELSE [QuestionnaireType] end AS QuestionnaireType ,
								dbo.[Questionnaire].[Description] AS Description ,
								QuestionnaireFormType ,
								LastLoadedDate ,
								COUNT(*) OVER ( PARTITION BY 1 ) AS Total ,
								ROW_NUMBER() OVER ( ORDER BY CASE WHEN @Sort = 'Id Asc'
																  THEN dbo.[Questionnaire].[Id]
															 END ASC, CASE
																  WHEN @Sort = 'Id DESC'
																  THEN dbo.[Questionnaire].[Id]
																  END DESC, CASE
																  WHEN @Sort = 'QuestionnaireTitle Asc'
																  THEN dbo.[Questionnaire].[QuestionnaireTitle]
																  END ASC, CASE
																  WHEN @Sort = 'QuestionnaireTitle DESC'
																  THEN dbo.[Questionnaire].[QuestionnaireTitle]
																  END DESC, CASE
																  WHEN @Sort = 'QuestionnaireType Asc'
																  THEN dbo.[Questionnaire].[QuestionnaireType]
																  END ASC, CASE
																  WHEN @Sort = 'QuestionnaireType DESC'
																  THEN dbo.[Questionnaire].[QuestionnaireType]
																  END DESC, CASE
																  WHEN @Sort = 'Description Asc'
																  THEN dbo.[Questionnaire].[Description]
																  END ASC, CASE
																  WHEN @Sort = 'Description DESC'
																  THEN dbo.[Questionnaire].[Description]
																  END DESC, CASE
																  WHEN @Sort = 'CreatedOn Asc'
																  THEN dbo.[Questionnaire].CreatedOn
																  END ASC, CASE
																  WHEN @Sort = 'CreatedOn DESC'
																  THEN dbo.[Questionnaire].CreatedOn
																  END DESC ) AS RowNum
					  FROM      dbo.[Questionnaire]
					  WHERE     dbo.[Questionnaire].IsDeleted = 0
								AND ( ISNULL(dbo.[Questionnaire].[QuestionnaireTitle],
											 '') LIKE '%' + @Search + '%'
									  OR ISNULL(dbo.[Questionnaire].[QuestionnaireType],
												'') LIKE '%' + @Search + '%'
									  OR ISNULL(dbo.[Questionnaire].[Description],
												'') LIKE '%' + @Search + '%'
									)
					) AS T
			WHERE   RowNum BETWEEN @Start AND @End;
		END
		ELSE
		BEGIN

						SELECT  RowNum ,
					ISNULL(Total, 0) AS Total ,
					Id ,
					QuestionnaireTitle ,
					QuestionnaireType ,
					[Description] ,
					QuestionnaireFormType ,
					dbo.ChangeDateFormat(LastLoadedDate, 'MM/dd/yyyy hh:mm AM/PM') AS LastLoadedDate
			FROM    ( SELECT    dbo.[Questionnaire].[Id] AS Id ,
								dbo.[Questionnaire].[QuestionnaireTitle] AS QuestionnaireTitle ,
								--dbo.[Questionnaire].[QuestionnaireType] AS QuestionnaireType ,
								CASE WHEN LOWER(dbo.[Questionnaire].[QuestionnaireType])='ei' THEN 'PI' ELSE [QuestionnaireType] end AS QuestionnaireType ,
								dbo.[Questionnaire].[Description] AS Description ,
								QuestionnaireFormType ,
								LastLoadedDate ,
								COUNT(*) OVER ( PARTITION BY 1 ) AS Total ,
								ROW_NUMBER() OVER ( ORDER BY CASE WHEN @Sort = 'Id Asc'
																  THEN dbo.[Questionnaire].[Id]
															 END ASC, CASE
																  WHEN @Sort = 'Id DESC'
																  THEN dbo.[Questionnaire].[Id]
																  END DESC, CASE
																  WHEN @Sort = 'QuestionnaireTitle Asc'
																  THEN dbo.[Questionnaire].[QuestionnaireTitle]
																  END ASC, CASE
																  WHEN @Sort = 'QuestionnaireTitle DESC'
																  THEN dbo.[Questionnaire].[QuestionnaireTitle]
																  END DESC, CASE
																  WHEN @Sort = 'QuestionnaireType Asc'
																  THEN dbo.[Questionnaire].[QuestionnaireType]
																  END ASC, CASE
																  WHEN @Sort = 'QuestionnaireType DESC'
																  THEN dbo.[Questionnaire].[QuestionnaireType]
																  END DESC, CASE
																  WHEN @Sort = 'Description Asc'
																  THEN dbo.[Questionnaire].[Description]
																  END ASC, CASE
																  WHEN @Sort = 'Description DESC'
																  THEN dbo.[Questionnaire].[Description]
																  END DESC, CASE
																  WHEN @Sort = 'CreatedOn Asc'
																  THEN dbo.[Questionnaire].CreatedOn
																  END ASC, CASE
																  WHEN @Sort = 'CreatedOn DESC'
																  THEN dbo.[Questionnaire].CreatedOn
																  END DESC ) AS RowNum
					  FROM      dbo.[Questionnaire]
					  INNER JOIN dbo.UserRolePermissions ON dbo.UserRolePermissions.PageID = @PageID
						 AND dbo.UserRolePermissions.ActualID = dbo.Questionnaire.Id
						 AND dbo.UserRolePermissions.UserID = @UserID
					  WHERE     dbo.[Questionnaire].IsDeleted = 0
								AND ( ISNULL(dbo.[Questionnaire].[QuestionnaireTitle],
											 '') LIKE '%' + @Search + '%'
									  OR ISNULL(dbo.[Questionnaire].[QuestionnaireType],
												'') LIKE '%' + @Search + '%'
									  OR ISNULL(dbo.[Questionnaire].[Description],
												'') LIKE '%' + @Search + '%'
									)
					) AS T
			WHERE   RowNum BETWEEN @Start AND @End;

		END
    END;