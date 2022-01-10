-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,, 15 Jun 2015>
-- Description:	<Description,,GetContactOptionsById>
-- Call SP    :	GetContactOptionsByContactQuestionsId
-- =============================================
CREATE PROCEDURE [dbo].[GetContactOptionsByContactId] @ContactId BIGINT
AS 
    BEGIN
        SELECT  dbo.[ContactOptions].[Id] AS Id ,
                dbo.[ContactOptions].[ContactQuestionId] AS ContactQuestionId ,
                dbo.[ContactOptions].[Position] AS Position ,
                dbo.[ContactOptions].[Name] AS Name ,
                dbo.[ContactOptions].[Value] AS Value ,
                dbo.[ContactOptions].[DefaultValue] AS DefaultValue ,
                CQ.ContactId,
				CQ.Id AS QuestionId
        FROM    dbo.[ContactOptions]
                INNER JOIN dbo.ContactQuestions AS CQ ON dbo.ContactOptions.ContactQuestionId = CQ.Id
        WHERE   dbo.[ContactOptions].IsDeleted = 0
                AND CQ.ContactId = @ContactId
    END