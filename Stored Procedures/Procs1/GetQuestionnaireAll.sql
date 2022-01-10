
-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 26 May 2015>
-- Description:	<Description,,GetQuestionnaireAll>
-- Call SP    :	GetQuestionnaireAll
-- =============================================
CREATE PROCEDURE [dbo].[GetQuestionnaireAll]
	@UserID INT
AS
    BEGIN

	DECLARE @AdminRole bigint ,
		@UserRole bigint ,
		@PageID bigint

		SELECT TOP 1 @AdminRole = Id FROM [dbo].[Role] WHERE RoleName = 'Admin'
		SELECT TOP 1 @UserRole = RoleId FROM dbo.[User] WHERE Id = @UserId
		SELECT TOP 1 @PageID = Id FROM dbo.Page WHERE PageName = 'Questionnaire'
		
		IF @AdminRole = @UserRole
		BEGIN

			SELECT  dbo.[Questionnaire].[Id] AS Id ,
					dbo.[Questionnaire].[QuestionnaireTitle] AS QuestionnaireTitle ,
					dbo.[Questionnaire].[QuestionnaireType] AS QuestionnaireType ,
					dbo.[Questionnaire].[Description] AS Description ,
					QuestionnaireFormType
			FROM    dbo.[Questionnaire]
			WHERE   dbo.[Questionnaire].IsDeleted = 0;
		END
		ELSE
		BEGIN

			SELECT  dbo.[Questionnaire].[Id] AS Id ,
					dbo.[Questionnaire].[QuestionnaireTitle] AS QuestionnaireTitle ,
					dbo.[Questionnaire].[QuestionnaireType] AS QuestionnaireType ,
					dbo.[Questionnaire].[Description] AS Description ,
					QuestionnaireFormType
			FROM    dbo.[Questionnaire]
			INNER JOIN dbo.UserRolePermissions ON dbo.UserRolePermissions.PageID = @PageID
				AND dbo.UserRolePermissions.ActualID = dbo.Questionnaire.Id
				AND dbo.UserRolePermissions.UserID = @UserID
			WHERE   dbo.[Questionnaire].IsDeleted = 0;

		END
    END;