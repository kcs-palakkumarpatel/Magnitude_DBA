-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,, Jun 2015>
-- Description:	<Description,,> Audrey Test 1
-- Call SP:		WSChangeAppUserPassword 'Krish11', 'Y18sYt6HCYfQ7BnrHmm6Rg==', 'Y18sYt6HCYfQ7BnrHmm6Rg==' 
-- =============================================
CREATE PROCEDURE [dbo].[WSChangeAppUserPassword]
    @Username NVARCHAR(50),
    @Password NVARCHAR(100),
    @NewPassword NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @UserId BIGINT,
            @status BIT = 0,
            @msg NVARCHAR(MAX) = N'Your password changed successfully.',
            @Name NVARCHAR(100),
            @EmailId NVARCHAR(100),
            @existingPasword VARCHAR(MAX) = '';

    SELECT TOP (1)
           @UserId = Id,
           @Name = Name,
           @EmailId = Email,
           @existingPasword = Password
    FROM dbo.[AppUser] WITH (NOLOCK)
    WHERE UserName = @Username
          AND IsDeleted = 0;

    IF (@UserId IS NULL OR @UserId <= 0)
        SET @msg = N'We could not find an account with that username. Try another.';
    ELSE IF (@Password <> @existingPasword)
        SET @msg = N'The current password you have entered is incorrect. Please re-enter current password correctly.';
    ----ELSE IF (
    ----(
    ----    SELECT COUNT(1)
    ----    FROM Split(@Name, ' ')
    ----    WHERE LEN(Data) > 3
    ----          AND @NewPassword LIKE '%' + Data + '%'
    ----) +
    ----(
    ----    SELECT COUNT(1) WHERE @NewPassword LIKE '%' + @Username + '%'
    ----) > 0
    ----        )
    ----    SET @msg = N'Password error: Passwords may not include any of your name / username details.';
    ELSE
    BEGIN
        DECLARE @tbl AS TABLE
        (
            Id BIT NOT NULL
        );
        INSERT INTO @tbl
        EXEC [AppUserPassWordValid] @AppUserId = @UserId, @Password = @NewPassword;

        SELECT @status = Id
        FROM @tbl;

        IF (@status = 0)
            SET @msg
                = N'You used an old password. Previous 5x passwords may not be re-used. <br>Please choose a password that you have not used before. <br>To protect your account, choose a new password.';
    END;

    IF (@status = 1)
    BEGIN
        UPDATE dbo.[AppUser]
        SET [Password] = @NewPassword
        WHERE Id = @UserId;

        INSERT INTO dbo.AppUserPasswordLog
        (
            [UserId],
            [Name],
            [Email],
            UserName,
            [PassWord],
            CreatedOn,
            CreatedBy
        )
        VALUES
        (@UserId, @Name, @EmailId, @Username, @NewPassword, GETUTCDATE(), @UserId);

    END;

    SELECT IIF(@status = 0, 0, @UserId) AS Id,
           @status AS Status,
           @msg AS msg;

    SET NOCOUNT OFF;
END;
