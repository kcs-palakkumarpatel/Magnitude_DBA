-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,, 06 Jun 2015>
-- Description:	<Description,,GetEstablishmentGroupAll>
-- Call SP    :	GetEstablishmentGroupAll
-- =============================================
CREATE PROCEDURE [dbo].[GetEstablishmentGroupAll]
AS 
    BEGIN
        SELECT  dbo.[EstablishmentGroup].[Id] AS Id ,
                dbo.[EstablishmentGroup].[GroupId] AS GroupId ,
                dbo.[Group].GroupName ,
                dbo.[EstablishmentGroup].[EstablishmentGroupName] AS EstablishmentGroupName ,
                dbo.[EstablishmentGroup].[EstablishmentGroupType] AS EstablishmentGroupType ,
                dbo.[EstablishmentGroup].[AboutEstablishmentGroup] AS AboutEstablishmentGroup ,
                dbo.[EstablishmentGroup].[QuestionnaireId] AS QuestionnaireId ,
                dbo.[EstablishmentGroup].[SeenClientId] AS SeenClientId ,
                dbo.[EstablishmentGroup].[HowItWorksId] AS HowItWorksId ,
                dbo.[EstablishmentGroup].[SMSReminder] AS SMSReminder ,
                dbo.[EstablishmentGroup].[EmailReminder] AS EmailReminder
        FROM    dbo.[EstablishmentGroup]
                INNER JOIN dbo.[Group] ON dbo.[Group].Id = dbo.[EstablishmentGroup].GroupId
        WHERE   dbo.[EstablishmentGroup].IsDeleted = 0
    END