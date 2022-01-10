-- =============================================
-- Author:		Krishna Panchal
-- Create date:	05-Aug-2021
-- Description:	Get SeenClient Unallocated Notification Text
-- SELECT * FROM DBO.GetSeenClientUnallocatedNotificationText(978951,'','')
-- =============================================
CREATE FUNCTION dbo.GetSeenClientUnallocatedNotificationText
(
    @SeenClientAnswerMasterId BIGINT,
    @EncryptedId NVARCHAR(500),
    @SeenClientAnswerChildId BIGINT
)
RETURNS @Result TABLE (CaptureUnallocatedNotificationAlert NVARCHAR(MAX))
AS
BEGIN
    DECLARE @EstablishmentName NVARCHAR(500),
            @UserName NVARCHAR(50),
            @UserEmail NVARCHAR(50),
            @UserMobile NVARCHAR(50),
            @UserProfileImage NVARCHAR(500),
            @Url NVARCHAR(100),
            @ConfigUrl NVARCHAR(200),
            @EI NVARCHAR(50),
            @PI NVARCHAR(50),
            @CaptureNotificationText NVARCHAR(MAX);

    SELECT @EstablishmentName = EstablishmentName,
           @UserName = U.Name,
           @EI = Am.EI,
           @PI = CAST(CAST(ROUND(Am.PI, 0) AS INT) AS NVARCHAR(10)) + N'%',
           @UserEmail = U.Email,
           @UserMobile = U.Mobile,
           @UserProfileImage = ISNULL(U.ImageName, ''),
           @CaptureNotificationText = E.CaptureUnallocatedNotificationAlert
    FROM dbo.SeenClientAnswerMaster AS Am
        INNER JOIN dbo.AppUser AS U
            ON Am.AppUserId = U.Id
        INNER JOIN dbo.Establishment AS E
            ON Am.EstablishmentId = E.Id
    WHERE Am.Id = @SeenClientAnswerMasterId;

    DECLARE @Tbl TABLE
    (
        Id BIGINT IDENTITY(1, 1),
        QuestionId BIGINT,
        Detail NVARCHAR(MAX)
    );
    DECLARE @Start BIGINT = 1,
            @End BIGINT,
            @Id BIGINT,
            @Details NVARCHAR(MAX),
            @QuestionId NVARCHAR(10);

    INSERT INTO @Tbl
    (
        QuestionId,
        Detail
    )
    SELECT SA.QuestionId,
           CASE QuestionTypeId
               WHEN 8 THEN
                   dbo.ChangeDateFormat(Detail, 'dd/MMM/yyyy')
               WHEN 9 THEN
                   dbo.ChangeDateFormat(Detail, 'hh:mm AM/PM')
               WHEN 22 THEN
                   dbo.ChangeDateFormat(Detail, 'dd/MMM/yyyy HH:mm')
               WHEN 17 THEN
                   dbo.GetFileTypeQuestionImageString(Detail, 1 ,SA.QuestionId)
               WHEN 1 THEN
               (
                   SELECT Name FROM dbo.SeenClientOptions WHERE Id = SA.OptionId
               )
               ELSE
                   Detail
           END
    FROM dbo.SeenClientAnswers SA
    WHERE SeenClientAnswerMasterId = @SeenClientAnswerMasterId
          AND ISNULL(SeenClientAnswerChildId, 0) = ISNULL(@SeenClientAnswerChildId, 0);
    SELECT @End = COUNT(1)
    FROM @Tbl;
    IF @CaptureNotificationText <> ''
       OR @CaptureNotificationText IS NOT NULL
    BEGIN
        WHILE @Start <= @End
        BEGIN
            SELECT @QuestionId = QuestionId,
                   @Details = Detail
            FROM @Tbl
            WHERE Id = @Start;

            SET @CaptureNotificationText
                = REPLACE(@CaptureNotificationText, '##[' + @QuestionId + ']##', ISNULL(@Details, ''));

            SET @Start += 1;
        END;

        SELECT @UserProfileImage = KeyValue + N'AppUser/' + @UserProfileImage
        FROM dbo.AAAAConfigSettings
        WHERE KeyName = 'DocViewerRootFolderPathCMS';

        SELECT @Url = KeyValue + N'Fb?Sid=' + @EncryptedId
        FROM dbo.AAAAConfigSettings
        WHERE KeyName = 'DocViewerRootFolderPath';

        SELECT @ConfigUrl = KeyValue + N'Fb/index?Sid=' + @EncryptedId
        FROM dbo.AAAAConfigSettings
        WHERE KeyName = 'DocViewerRootFolderPath';

        SET @CaptureNotificationText = REPLACE(@CaptureNotificationText, '##[link]##', @Url);
        SET @CaptureNotificationText = REPLACE(@CaptureNotificationText, '##[EI]##', @EI);
        SET @CaptureNotificationText = REPLACE(@CaptureNotificationText, '##[PI]##', @PI);
        SET @CaptureNotificationText = REPLACE(@CaptureNotificationText, '##[username]##', @UserName);
        SET @CaptureNotificationText = REPLACE(@CaptureNotificationText, '##[useremail]##', @UserEmail);
        SET @CaptureNotificationText = REPLACE(@CaptureNotificationText, '##[usermobile]##', @UserMobile);
        SET @CaptureNotificationText = REPLACE(@CaptureNotificationText, '##[establishment]##', @EstablishmentName);

    END;
    INSERT INTO @Result
    (
        CaptureUnallocatedNotificationAlert
    )
    VALUES (ISNULL(@CaptureNotificationText, ''));
    RETURN;
END;
