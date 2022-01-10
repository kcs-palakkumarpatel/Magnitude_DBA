

-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,14 Jul 2021>
-- Description:	<Description,,>
-- Call SP: exec [dbo].[InsertEmailHistory] 979666,1,'parth.m13@mailnesia.com','open','1626241984','9njgnp0hst-dt21abfyslg.filterdrecv-65f8b4d99-kp4bb-1-60EE78A3-34.0'
-- =============================================
CREATE PROCEDURE [dbo].[InsertEmailHistory_111721]
    @RefID BIGINT,
    @IsOut BIT,
    @email NVARCHAR(1000),
    @event NVARCHAR(50),
    @timestamp NVARCHAR(50),
    @sg_message_id NVARCHAR(MAX),
    @response NVARCHAR(MAX) = NULL
AS
BEGIN
    BEGIN TRY

        SET NOCOUNT ON;
        DECLARE @EstablishmentId BIGINT = NULL;
        DECLARE @EstablishmentGroupId BIGINT = NULL;
        DECLARE @GroupId BIGINT = NULL;
        IF @IsOut = 0
        BEGIN
            SELECT TOP 1
                   @EstablishmentId = EstablishmentId,
                   @EstablishmentGroupId = EstablishmentGroupId,
                   @GroupId = GroupId
            FROM dbo.AnswerMaster acam WITH (NOLOCK)
                JOIN dbo.Establishment AS est WITH (NOLOCK)
                    ON acam.EstablishmentId = est.Id
            WHERE acam.Id = @RefID;
        END;
        ELSE
        BEGIN
            SELECT TOP 1
                   @EstablishmentId = EstablishmentId,
                   @EstablishmentGroupId = EstablishmentGroupId,
                   @GroupId = GroupId
            FROM dbo.SeenClientAnswerMaster acam WITH (NOLOCK)
                JOIN dbo.Establishment AS est WITH (NOLOCK)
                    ON acam.EstablishmentId = est.Id
            WHERE acam.Id = @RefID;
        END;
        --IF @EstablishmentId IS NOT NULL
        --BEGIN
        DECLARE @Name NVARCHAR(MAX) = N'';
        DECLARE @ContactMasterId BIGINT;
        SET @ContactMasterId =
        (
            SELECT ContactMasterId
            FROM dbo.SeenClientAnswerMaster WITH (NOLOCK)
            WHERE Id = @RefID
        );

        IF @ContactMasterId <> 0
        BEGIN
            SET @Name =
            (
                SELECT TOP 1
                       Detail
                FROM dbo.ContactDetails AS CD WITH (NOLOCK)
                WHERE CD.ContactMasterId = @ContactMasterId
                      AND CD.QuestionTypeId = 4
            );
            IF (@Name = '')
            BEGIN
                SET @Name = LEFT(@email, (CHARINDEX('@', @email) - 1));
            END;
        END;
        ELSE
        BEGIN
            CREATE TABLE #GroupConatctMasterId
            (
                Id BIGINT PRIMARY KEY IDENTITY(1, 1),
                ContactMasterId BIGINT
            );
            INSERT INTO #GroupConatctMasterId
            (
                ContactMasterId
            )
            SELECT ContactMasterId
            FROM dbo.SeenClientAnswerChild WITH (NOLOCK)
            WHERE SeenClientAnswerMasterId = @RefID; -- ContactMasterId - bigint   
            SET @ContactMasterId =
            (
                SELECT TOP 1
                       CD.ContactMasterId
                FROM dbo.ContactDetails CD WITH (NOLOCK)
                    INNER JOIN #GroupConatctMasterId GM
                        ON CD.ContactMasterId = GM.ContactMasterId
                WHERE CD.Detail = @email
            );
            SET @Name =
            (
                SELECT TOP 1
                       Detail
                FROM dbo.ContactDetails AS CD WITH (NOLOCK)
                WHERE CD.ContactMasterId = @ContactMasterId
                      AND CD.QuestionTypeId = 4
            );
            IF (@Name = '')
            BEGIN
                SET @Name = LEFT(@email, (CHARINDEX('@', @email) - 1));
            END;
        END;

        INSERT INTO dbo.EmailHistory
        (
            RefID,
            IsOut,
            EstablishmentId,
            EstablishmentGroupId,
            GroupId,
            Email,
            Event,
            TimeStamp,
            SG_message_id,
            Response,
            Name,
            CreatedOn
        )
        VALUES
        (@RefID, @IsOut, @EstablishmentId, @EstablishmentGroupId, @GroupId, @email, @event, @timestamp, @sg_message_id,
         @response, @Name, GETUTCDATE() -- CreatedOn - datetime
            );

        SELECT SCOPE_IDENTITY() AS InsertedId;

        --END;
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
        (ERROR_LINE(), 'dbo.InsertEmailHistory', N'Database', ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(), 0, N'', GETUTCDATE(), 0);
    END CATCH;
	SET NOCOUNT OFF;
END;
