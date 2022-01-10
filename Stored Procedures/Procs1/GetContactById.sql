-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,, 15 Jun 2015>
-- Description:	<Description,,GetContactById>
-- Call SP    :	GetContactById
-- =============================================
CREATE PROCEDURE [dbo].[GetContactById] @Id BIGINT
AS 
    BEGIN
        SELECT  [Id] AS Id ,
                [ContactTitle] AS ContactTitle ,
                [Description] AS Description
        FROM    dbo.[Contact]
        WHERE   [Id] = @Id
    END