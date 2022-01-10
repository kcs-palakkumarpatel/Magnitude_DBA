

-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 18 Oct 2014>
-- Description:	<Description,,GetRoleById>
-- Call SP    :	GetRoleById
-- =============================================
CREATE PROCEDURE [dbo].[GetRoleById] @Id BIGINT
AS 
    BEGIN
        SELECT  [Id] AS Id ,
                [RoleName] AS RoleName ,
                [Description] AS Description
        FROM    dbo.[Role]
        WHERE   [Id] = @Id
    END