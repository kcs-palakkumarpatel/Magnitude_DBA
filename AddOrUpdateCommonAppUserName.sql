-- =============================================
--  Author: 	  Mitesh Kachhadiya
--  Create date:  19-Oct-2021
--	Description:	
--	Call SP: AddOrUpdateCommonAppUserName 'Johan4.B','MG', 'Johan5.B'
--	=============================================  
CREATE PROCEDURE [dbo].[AddOrUpdateCommonAppUserName]
    @Username NVARCHAR(50),
    @InstanceKey NVARCHAR(50),
    @OldUsername NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    --DECLARE @Username NVARCHAR(50) = 'Johan.B', @InstanceKey NVARCHAR(50) = 'MG', @OldUsername NVARCHAR(50) = 'Johan.B';

    DECLARE @IsSucessed BIT = 0;
    DECLARE @EnvironmentId INT = (
                                     SELECT TOP (1)
                                         Id
                                     FROM dbo.ENVIRONMENT WITH (NOLOCK)
                                     WHERE [Key] = @InstanceKey
                                 );
    --   SELECT @EnvironmentId
    --, IIF(EXISTS( SELECT TOP (1)
    --                   CAU.Username
    --               FROM dbo.CommonAppUser CAU WITH (NOLOCK)
    --               WHERE Username = @OldUsername
    --                     AND CAU.EnvironmentId = @EnvironmentId), 1, 0)

    --    SELECT TOP (1)
    --                   CAU.Username
    --               FROM dbo.CommonAppUser CAU WITH (NOLOCK)
    --               WHERE Username = @OldUsername
    --                     AND CAU.EnvironmentId = @EnvironmentId

    IF (@EnvironmentId IS NOT NULL)
    BEGIN
        IF (@OldUsername != '')
        BEGIN
            IF (
                   EXISTS
            (
                SELECT TOP (1)
                    CAU.Username
                FROM dbo.CommonAppUser CAU WITH (NOLOCK)
                WHERE Username = @OldUsername
                      AND CAU.EnvironmentId = @EnvironmentId
            )
                   AND NOT EXISTS
            (
                SELECT TOP (1)
                    CAU.Username
                FROM dbo.CommonAppUser CAU WITH (NOLOCK)
                WHERE Username = @Username
            )
               )
            BEGIN
                UPDATE dbo.CommonAppUser
                SET Username = @Username
                WHERE Username = @OldUsername;

                SET @IsSucessed = 1;
                PRINT ('Update');
            END;
        END;

        ELSE IF (NOT EXISTS
             (
                 SELECT TOP (1)
                     CAU.Username
                 FROM dbo.CommonAppUser CAU WITH (NOLOCK)
                 WHERE Username = @Username
             --AND CAU.EnvironmentId = @EnvironmentId
             )
                )
        BEGIN
            INSERT INTO dbo.CommonAppUser
            (
                Username,
                Email,
                Groupname,
                EnvironmentId
            )
            VALUES
            (   @Username,     -- Username - varchar(125)
                '',            -- Email - varchar(125)
                '',            -- Groupname - varchar(125)
                @EnvironmentId -- EnvironmentId - varchar(125)
            );

            SET @IsSucessed = 1;
            PRINT ('Insert');
        END;

    END;
    PRINT (@IsSucessed);
    RETURN @IsSucessed;
    SET NOCOUNT OFF;
END;
