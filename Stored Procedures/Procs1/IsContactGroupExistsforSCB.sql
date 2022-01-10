-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,19 Jun 2015>
-- Description:	<Description,,>
-- Call SP:		IsContactGroupExistsforSCB 201,0, 'Test Activity _testContact Group'
-- =============================================
CREATE PROCEDURE dbo.IsContactGroupExistsforSCB
    @Id BIGINT,
    @GroupId BIGINT,
    @GroupName NVARCHAR(50)
AS
BEGIN
    IF EXISTS
    (
         SELECT TOP 1
            Id
        FROM dbo.ContactGroup
        WHERE IsDeleted = 0
              AND ContactGropName = @GroupName
              AND GroupId = @Id
    )
    BEGIN
        SELECT TOP 1
            Id
        FROM dbo.ContactGroup
        WHERE IsDeleted = 0
              AND ContactGropName = @GroupName
              AND GroupId = @Id;
    END;
    ELSE
    BEGIN
        SELECT 0 AS Id;
    END;
END;
