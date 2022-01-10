-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,, 30 May 2015>
-- Description:	<Description,,GetOptionsById>
-- Call SP    :	GetOptionsByQuestionnaireId 3186
-- =============================================
CREATE PROCEDURE dbo.GetOptionsByQuestionnaireId
    @QuestionnaireId BIGINT
AS 
    BEGIN
        SELECT  dbo.[Options].[Id] AS Id ,
                dbo.[Options].[QuestionId] AS QuestionId ,
                QuestionTitle ,
                dbo.[Options].[Position] AS Position ,
                dbo.[Options].[Name] AS Name ,
                dbo.[Options].[Value] AS Value ,
                dbo.[Options].[DefaultValue] AS DefaultValue ,
                dbo.Options.[Weight],
				Point,
				dbo.Options.OptionImagePath,
				dbo.Questions.QuestionTypeId
        FROM    dbo.[Options]
                INNER JOIN dbo.[Questions] ON dbo.[Questions].Id = dbo.[Options].QuestionId AND dbo.[Questions].IsDeleted = 0
        WHERE   dbo.[Options].IsDeleted = 0
                AND QuestionnaireId = @QuestionnaireId 
				AND QuestionTypeId != 26 --AND dbo.Options.[Value] != '-- Select --'
    END
