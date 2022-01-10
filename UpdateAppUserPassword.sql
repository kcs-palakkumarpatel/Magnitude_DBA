
-- =============================================
-- Author:		Krishna Panchal
-- Create date:	22-Oct-2021
-- Description:	ChangesPassword
-- Call SP    :	[UpdateAppUserPassword]
-- =============================================
CREATE PROCEDURE [dbo].[UpdateAppUserPassword]
    @AppUserId BIGINT,
    @Password NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @Username NVARCHAR(100),
                @Name NVARCHAR(100),
                @EmailId NVARCHAR(100);

        SELECT TOP (1)
            @Username = UserName,
            @Name = Name,
            @EmailId = Email
        FROM dbo.[AppUser] WITH (NOLOCK)
        WHERE Id = @AppUserId;

        IF (@Username IS NOT NULL)
        BEGIN
            UPDATE dbo.AppUser
            SET [Password] = @Password
            WHERE Id = @AppUserId;

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
            (@AppUserId, @Name, @EmailId, @Username, @Password, GETUTCDATE(), 0);

            -- Set Login Attempt true & allow(UnLock) to Login this AppUser
            INSERT dbo.AppUserLoginLog
            (
                UserId,
                UserName,
                Attempt,
                AttemptsLeft,
                IpAddress,
                CreatedOn,
                CreatedBy
            )
            VALUES
            (   @AppUserId, -- AppUserId - bigint
                @Username,  -- UserName - nvarchar(50)
                1,          -- Attempt - bit
                10,         -- AttemptsLeft - SMALLINT 
                N'',        -- IpAddress - nvarchar(50)
                GETDATE(),  -- CreatedOn - datetime
                @AppUserId  -- CreatedBy - bigint
            );
            RETURN 1;
        END;
        ELSE
            RETURN 0;

    END TRY
    BEGIN CATCH
        INSERT INTO dbo.ErrorLog
        (
            PageId,
            MethodName,
            ErrorType,
            ErrorMessage,
            ErrorDetails,
            ErrorDate,
            UserId,
            Solution,
            CreatedOn,
            CreatedBy
        )
        VALUES
        (ERROR_LINE(),
         'dbo.UpdateAppUserPassword',
         N'Database',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         @AppUserId,
         N'',
         GETUTCDATE(),
         @AppUserId
        );
    END CATCH;
    SET NOCOUNT OFF;
END;
