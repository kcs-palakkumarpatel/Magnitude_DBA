CREATE PROCEDURE dbo.GetAppUserIdByEmailId @EmailId NVARCHAR(500)
AS
BEGIN
    IF EXISTS (SELECT Id FROM dbo.AppUser WHERE Email = @EmailId)
    BEGIN
        SELECT Id
        FROM dbo.AppUser
        WHERE Email = @EmailId;
    END;
    ELSE
    BEGIN
        SELECT '0' AS Id;
    END;
END;
