-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,, 15 Jun 2015>
-- Description:	<Description,,GetContactOptionsById>
-- Call SP    :	GetContactOptionsByContactQuestionsId
-- =============================================
CREATE PROCEDURE [dbo].[GetContactOptionsByContactQuestionsId]
    @ContactQuestionId BIGINT
AS 
    BEGIN
        SELECT  dbo.[ContactOptions].[Id] AS Id ,
                dbo.[ContactOptions].[ContactQuestionId] AS ContactQuestionId ,
                dbo.[ContactOptions].[Position] AS Position ,
                dbo.[ContactOptions].[Name] AS Name ,
                dbo.[ContactOptions].[Value] AS Value ,
                dbo.[ContactOptions].[DefaultValue] AS DefaultValue
        FROM    dbo.[ContactOptions]
        WHERE   dbo.[ContactOptions].IsDeleted = 0
                AND [ContactQuestionId] = @ContactQuestionId
    END