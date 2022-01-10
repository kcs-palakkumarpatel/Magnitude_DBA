-- =============================================
--  Author:			Mitesh
--  Create date:	08-Aug-2021
--	Description:	
--	Call SP: ValidateAppUserLoginAttempt 'TFC Abdul', 'glI0kVil9LN5GHUXUEnRQ==', '1.0.12.122'
--	=============================================
CREATE PROCEDURE dbo.ValidateAppUserLoginAttempt
    @UserName NVARCHAR(50),
    @Password NVARCHAR(100),
    @IPAddress NVARCHAR(MAX) = N'',
    @IsWeb BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @UserId BIGINT,
            @UserPW NVARCHAR(100),
            @status BIT = 0,
            @msg NVARCHAR(MAX) = N'You are logged in successfully.';

    BEGIN TRY

        SELECT TOP (1)
            @UserId = Id,
            @UserPW = Password
        FROM dbo.[AppUser] WITH (NOLOCK)
        WHERE IsActive = 1
              AND IsDeleted = 0
              AND UserName = @UserName;

        IF (@UserId > 0)
        BEGIN

            DECLARE @attemptsLeft SMALLINT = 9;

            SELECT TOP (1)
                @attemptsLeft = ([AttemptsLeft] - 1)
            FROM dbo.AppUserLoginLog WITH (NOLOCK)
            WHERE UserId = @UserId
            ORDER BY CreatedOn DESC;
            --SELECT @attemptsLeft
            IF (@attemptsLeft <= 0)
                SET @msg
                    = N'You’ve reached the maximum logon attempts. <br/> Please reset your password and try again or contact Magnitude support for assistance.';

            ELSE
            BEGIN
                IF (@Password <> @UserPW)
                BEGIN
                    SET @msg
                        = N'This password is incorrect. Please re-enter current password correctly. </br> You have '
                          + CAST((@attemptsLeft) AS NVARCHAR(2)) + N' more attempts before your account is locked.';
                END;
                ELSE
                BEGIN
                    SET @status = 1;
                    SET @msg = N'You are logged in successfully.';
                END;
            END;
            -- Insert User Login Log
            IF (@attemptsLeft >= 0)
            BEGIN
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
                (   @UserId,                                      -- UserId - bigint
                    @UserName,                                    -- UserName - nvarchar(50)
                    IIF(@Password <> @UserPW, 0, 1),              -- Attempt - bit
                    IIF(@Password <> @UserPW, @attemptsLeft, 10), --AttemptsLeft - SMALLINT 
                    @IPAddress,                                   -- IpAddress - nvarchar(50)
                    GETDATE(),                                    -- CreatedOn - datetime
                    @UserId                                       -- CreatedBy - bigint
                );
            END;

        END;

        ELSE
        BEGIN
            IF (EXISTS
            (
                SELECT TOP (1)
                    Id
                FROM dbo.[AppUser] WITH (NOLOCK)
                WHERE IsDeleted = 0
                      AND UserName = @UserName
            )
               )
            BEGIN
                SET @msg = N'We could not find an account with that username. Try another..';
            END;
            ELSE
            BEGIN
                DECLARE @InstanceUrl VARCHAR(MAX) = (
                                                        SELECT TOP (1)
                                                            REPLACE(ApiURL, 'webapi', 'web')
                                                        FROM dbo.CommonAppUser WITH (NOLOCK)
                                                            JOIN dbo.ENVIRONMENT
                                                                ON ENVIRONMENT.Id = CommonAppUser.ENVIRONMENTID
                                                        WHERE Username = @UserName
                                                    );

                IF (@InstanceUrl IS NOT NULL AND @InstanceUrl != '')
                BEGIN
                    IF (@IsWeb = 1)
                    BEGIN
                        SET @msg
                            = N'We have changed your login web address. This is directly related to improving security, performance and adherence to POPIA. <br/><b>Your new Login URL is "'
                              + ' <a href="' + @InstanceUrl + '">' + @InstanceUrl + '</a>".</b> '
                              + ' Go to this URL and use the same username and password. <br/> <small>For more information, please see our website: <a target="_blank" href="https://www.magnitudeapps.com/">www.magnitudeapps.com</a> </small>';
                    END;
                    ELSE
                        SET @msg
                            = N'Due to server migration, please ensure you are running the latest version of Magnitude on your mobile device.';
                END;

                ELSE
                    SET @msg = N'We could not find an account with that username. Try another.';

            END;
        END;
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
         'dbo.ValidateUserLogin',
         N'Database',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         0  ,
         N'',
         GETUTCDATE(),
         0
        );

        SET @msg = N'Something went wrong. Please try again.';
    END CATCH;

    SELECT @status AS STATUS,
           @msg AS msg;

    SET NOCOUNT OFF;
END;
