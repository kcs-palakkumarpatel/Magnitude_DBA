-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,, 06 Jun 2015>
-- Description:	<Description,,GetHowItWorksById>
-- Call SP    :	GetHowItWorksById
-- =============================================
CREATE PROCEDURE [dbo].[GetHowItWorksById] @Id BIGINT
AS 
    BEGIN
        SELECT  [Id] AS Id ,
                [HowItWorksName] AS HowItWorksName ,
                [HowItWorks] AS HowItWorks
        FROM    dbo.[HowItWorks]
        WHERE   [Id] = @Id
    END