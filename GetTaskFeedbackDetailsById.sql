-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,04 Jul 2015>
-- Description:	<Description,,>
-- Call SP:GetTaskFeedbackDetailsById 976781, 18058
-- =============================================
CREATE PROCEDURE dbo.GetTaskFeedbackDetailsById
    @SeenClientAnswerMasterId BIGINT,
    @AppuserId BIGINT
AS
BEGIN

    DECLARE @EstablishmentID BIGINT,
            @TimeOffSet INT;
    SET @EstablishmentID =
    (
        SELECT EstablishmentId
        FROM SeenClientAnswerMaster
        WHERE Id = @SeenClientAnswerMasterId
    );
    SET @TimeOffSet =
    (
        SELECT TimeOffSet FROM Establishment WHERE Id = @EstablishmentID
    );

    IF NOT EXISTS
    (
        SELECT *
        FROM dbo.ReportAuditLog
        WHERE AppUserId = @AppuserId
              AND ReportId = @SeenClientAnswerMasterId
              AND isOut = 1
    )
    BEGIN
        INSERT INTO ReportAuditLog
        (
            AppUserId,
            EstablishmentId,
            ReportId,
            isOut,
            ReadOn,
            IsDeleted
        )
        VALUES
        (@AppuserId, @EstablishmentID, @SeenClientAnswerMasterId, 1, DATEADD(MINUTE, @TimeOffSet, GETUTCDATE()), 0);
    END;

    INSERT INTO ReportAuditLog_History
    (
        AppUserId,
        EstablishmentId,
        ReportId,
        isOut,
        ReadOn,
        IsDeleted
    )
    VALUES
    (@AppuserId, @EstablishmentID, @SeenClientAnswerMasterId, 1, DATEADD(MINUTE, @TimeOffSet, GETUTCDATE()), 0);

    DECLARE @Url VARCHAR(100);
    DECLARE @GroupType VARCHAR(10);
    SELECT @Url = KeyValue
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'FeedbackUrl';
    SET @GroupType = ISNULL(
                     (
                         SELECT CASE
                                    WHEN ISNULL(Id, 0) > 0 THEN
                                        '1'
                                    ELSE
                                        '0'
                                END
                         FROM dbo.Establishment
                         WHERE GroupId IN (
                                              SELECT Data
                                              FROM dbo.Split(
                                                   (
                                                       SELECT KeyValue
                                                       FROM dbo.AAAAConfigSettings
                                                       WHERE KeyName = 'ExcludeGroupId'
                                                   ),
                                                   ','
                                                            )
                                          )
                               AND Id =
                               (
                                   SELECT EstablishmentId
                                   FROM dbo.SeenClientAnswerMaster
                                   WHERE Id = @SeenClientAnswerMasterId
                               )
                     ),
                     '0'
                           );

    SELECT Am.Id AS ReportId,
           Am.EstablishmentId,
           E.EstablishmentName,
		   Eg.Id AS ActivityId,
		   Eg.EstablishmentGroupName AS ActivityName,
		   Am.SeenClientId AS SeenClientId,
           Am.Latitude,
           Am.Longitude,
           dbo.ChangeDateFormat(DATEADD(MINUTE, Am.TimeOffSet, Am.CreatedOn), 'dd/MMM/yyyy HH:mm') AS CaptureDate,
		   dbo.ChangeDateFormat(DATEADD(MINUTE, Am.TimeOffSet, Am.UpdatedOn), 'dd/MMM/yyyy HH:mm') AS UpdatedOn,
           Am.AppUserId,
		   ISNULL(Am.IsTransferred, 0) AS IsTransferred,
           ISNULL(Am.IsResolved, '') AS AnswerStatus,
           ISNULL(Am.IsActioned, 0) AS IsActioned,
           @Url AS MobiLink,
           ISNULL(F.IsFlag, 0) AS [IsFlag],
           ES.Id AS StatusId,
           ES.StatusName,
           SII.IconPath AS StatusImage,
           (
               SELECT FORMAT(CAST(SH.StatusDateTime AS DATETIME), 'dd/MMM/yy HH:mm', 'en-us')
           ) AS StatusTime,
           (
               SELECT dbo.DifferenceDatefun(
                                               ISNULL(SH.StatusDateTime, GETUTCDATE()),
                                               DATEADD(MINUTE, Am.TimeOffSet, GETUTCDATE())
                                           )
           ) AS StatusCounter,
		   SII.Id AS StatusIconId,
           E.StatusIconEstablishment AS StatusIconEstablishment,
           ISNULL(Eg.InFormRefNumber, 0) AS InFormRefNumber,
		   (
               SELECT TOP 1
                      ISNULL(SO.Value, '')
               FROM dbo.SeenClientOptions SO
                   INNER JOIN dbo.SeenClientAnswers SCA
                       ON SCA.OptionId = SO.Id
               WHERE SCA.SeenClientAnswerMasterId = AM.Id
                     AND QuestionTypeId = 21
           ) AS PriorityName,
		   '' AS ScreenTitleText,
		   U.Name AS AppuserName,
		   ISNULL(Am.IsDisabled,0) AS IsDisabled,
		   ISNULL(U.AllowDeleteFeedback,0) AS AllowDeleteFeedback,
		   ISNULL(U.AllowExportData,0) AS AllowExportData
    FROM dbo.SeenClientAnswerMaster AS Am
        INNER JOIN dbo.Establishment AS E
            ON Am.EstablishmentId = E.Id
        INNER JOIN dbo.EstablishmentGroup AS Eg
            ON E.EstablishmentGroupId = Eg.Id
        INNER JOIN dbo.AppUser AS U
            ON Am.AppUserId = U.Id
        LEFT OUTER JOIN dbo.StatusHistory AS SH
            ON Am.StatusHistoryId = SH.Id
        LEFT OUTER JOIN dbo.EstablishmentStatus AS ES
            ON SH.EstablishmentStatusId = ES.Id
        LEFT OUTER JOIN dbo.StatusIconImage SII
            ON ES.StatusIconImageId = SII.Id
        LEFT OUTER JOIN dbo.SeenClientAnswerMaster AS TransferFromAM
            ON TransferFromAM.Id = Am.SeenClientAnswerMasterId
        LEFT OUTER JOIN dbo.AppUser AS TransferFromUser
            ON TransferFromAM.AppUserId = TransferFromUser.Id
        LEFT OUTER JOIN dbo.FlagMaster AS F
            ON F.ReportId = Am.Id
               AND F.AppUserId = @AppuserId
               AND F.Type = 2
    WHERE Am.Id = @SeenClientAnswerMasterId;
END;
