-- =============================================
-- Author:		<Author,Mitesh>
-- Create date: <Create Date,, Aug 2021>
-- Description:	<Description,,>
-- Call SP:		UpdateUserPassword 255,'bOKDBz0BnZWNbMe02buhQWg==','cOKDBz0BnZWNbMe02buhQWg=='
-- =============================================
CREATE PROCEDURE [dbo].[UpdateUserPassword]
    @UserId BIGINT,
    @Password NVARCHAR(100),
    @NewPassword NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Username NVARCHAR(50),
            @status BIT = 0,
            @msg NVARCHAR(MAX) = N'Your password changed successfully.',
            @Name NVARCHAR(100),
            @EmailId NVARCHAR(100),
            @existingPasword VARCHAR(MAX) = '';

    SELECT TOP (1)
           @Username = UserName,
           @Name = Name,
           @EmailId = EmailId,
           @existingPasword = Password
    FROM dbo.[User] WITH (NOLOCK)
    WHERE Id = @UserId;
    --AND IsDeleted = 0;
    -- AND [Password] = @Password

    IF (@UserId < 0)
        SET @msg = N'We could not find an account with that username. Try another.';
    ELSE IF (@Password <> @existingPasword)
        SET @msg = N'The current password you have entered is incorrect. Please re-enter current password correctly.';
    ELSE
    BEGIN
        -- DECLARE @status BIT = 0, @UserId BIGINT = 255,    @Password NVARCHAR(100) = 'ym3ApyUrt+r68pU7yFuvTg==',    @NewPassword NVARCHAR(100)='OKDBz0BnZWNbMe02buhQWg==';
        DECLARE @tbl AS TABLE
        (
            Id BIT NOT NULL
        );
        INSERT INTO @tbl
        EXEC [UserPasswordValid] @UserId = @UserId, @Password = @NewPassword;

        SELECT @status = Id
        FROM @tbl;

        IF (@status = 0)
            SET @msg
                = N'You used an old password. Previous 5x passwords may not be re-used. <br>
				Please choose a password that you have not used before. <br> 
				To protect your account, choose a new password.';
    -- N'Invalid new Passowrd. You can not reuse last 5 Passsword. <br/>'
    --  + N'Please choose a password that you have not used before. To help protect your account, you need to choose a new password every time you reset it.';
    END;

    IF (@status = 1)
    BEGIN
        UPDATE dbo.[User]
        SET [Password] = @NewPassword,
            PWExpireDate = DATEADD(DAY, 119, GETUTCDATE())
        WHERE Id = @UserId;

        INSERT INTO dbo.UserPasswordLog
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

    SELECT @status AS Status,
           @msg AS msg;
    SET NOCOUNT OFF;
END;
