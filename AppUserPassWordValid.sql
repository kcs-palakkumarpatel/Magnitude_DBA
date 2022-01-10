-- =============================================
-- Author:			Mitesh Kachhadiya
-- Create date:	02-Aug-2021
-- Description:	Description,,AppUserPassWordValid>
-- Call SP    :		[AppUserPassWordValid] 1,'sdfgsdgs',1
-- =============================================
CREATE PROCEDURE [dbo].[AppUserPassWordValid]
    @AppUserId BIGINT,
    @Password NVARCHAR(50),
    @IsAllowCreateTemplates BIT = 0
AS
SET NOCOUNT ON;
BEGIN

    DECLARE @existingPasword VARCHAR(MAX) = '',
            @isValid BIT = 1;

    IF (@IsAllowCreateTemplates = 1)
    BEGIN
        SET @existingPasword =
        (
            SELECT TOP (1)
                   [PassWord]
            FROM dbo.AppUserPasswordLog WITH (NOLOCK)
            WHERE UserId = @AppUserId
            ORDER BY CreatedOn DESC
        );
    END;

    IF (@Password <> @existingPasword)
    BEGIN

        DECLARE @dataCount INT =
                (
                    SELECT COUNT(1)
                    FROM
                    (
                        SELECT TOP (5)
                               MAX(Id) AS Id,
                               [PassWord]
                        FROM dbo.AppUserPasswordLog WITH (NOLOCK)
                        WHERE UserId = @AppUserId
                        GROUP BY PassWord
                        ORDER BY MAX(Id) DESC
                    ) AS pwList
                    WHERE [PassWord] = @Password
                );
    END;

    IF (@dataCount > 0)
        SET @isValid = 0;

    SELECT @isValid AS IsValid;
END;
SET NOCOUNT OFF;
