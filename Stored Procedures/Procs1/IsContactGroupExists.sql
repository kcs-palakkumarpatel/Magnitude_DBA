-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,19 Jun 2015>
-- Description:	<Description,,>
-- Call SP:		IsContactGroupExists 1, 'KCS'
-- =============================================
CREATE PROCEDURE [dbo].[IsContactGroupExists]
    @Id BIGINT ,
    @GroupId BIGINT ,
    @GroupName NVARCHAR(50)
AS 
    BEGIN
        SELECT  Id ,
                ContactGropName
        FROM    dbo.ContactGroup
        WHERE   Id <> @Id
                AND IsDeleted = 0
                AND ContactGropName = @GroupName
				AND GroupId = @GroupId
    END