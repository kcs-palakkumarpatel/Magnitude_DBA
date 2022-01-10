
-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,25 September 2019>
-- Description:	<Description, Set Language in AppUser table>
-- =============================================
CREATE PROCEDURE [dbo].[Setlanguage]
    @language NVARCHAR(10),
    @userId BIGINT
AS
BEGIN
    IF (@language = 'en')
    BEGIN
        UPDATE dbo.AppUser
        SET LanguageMasterId = 1
        WHERE Id = @userId;
    END;
    ELSE IF (@language = 'es')
    BEGIN
        UPDATE dbo.AppUser
        SET LanguageMasterId = 2
        WHERE Id = @userId;
    END;
END;
