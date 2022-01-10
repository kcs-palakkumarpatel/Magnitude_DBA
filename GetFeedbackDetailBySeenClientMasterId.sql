-- =============================================
-- Author:				Mittal Patel
-- Create date:		24-September-2019
-- Description:		Get feedback IN and out by AnswerMasterId
-- Call SP:			dbo.GetFeedbackDetailBySeenClientMasterId 40148,0
-- =============================================
CREATE PROCEDURE [dbo].[GetFeedbackDetailBySeenClientMasterId]
    @AnswerMasterId BIGINT,
    @AppUserId BIGINT
AS
BEGIN

    DECLARE @PIDispaly VARCHAR(5) = '0';
    DECLARE @Url VARCHAR(50);
    DECLARE @GroupType VARCHAR(10);
    DECLARE @SeenClientAnswerMasterId BIGINT;

    SELECT @Url = KeyValue
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'FeedbackUrl';

    SELECT @SeenClientAnswerMasterId = SeenClientAnswerMasterId
    FROM dbo.AnswerMaster
    WHERE Id = @AnswerMasterId;


    --GET IN form Data
    IF (
       (
           SELECT COUNT(1)
           FROM dbo.Questions
           WHERE QuestionTypeId IN ( 1, 5, 6, 7, 18, 21 )
                 AND QuestionnaireId =
                 (
                     SELECT QuestionnaireId FROM dbo.AnswerMaster WHERE Id = @AnswerMasterId
                 )
                 --AND [Required] = 1
                 AND IsDeleted = 0
       ) > 0
       )
    BEGIN
        SET @PIDispaly = '1';
    END;

    SELECT Am.Id AS ReportId,
           Am.EstablishmentId,
           EstablishmentName,
           Am.Latitude,
           Am.Longitude,
           --CONVERT(DECIMAL(18,0), Am.PI) AS EI ,
           IIF(@PIDispaly = 1, Am.[PI], IIF(Am.[PI] >= 0.00, Am.[PI], -1)) AS EI,
           Am.IsPositive AS SmileType,
           dbo.ChangeDateFormat(DATEADD(MINUTE, Am.TimeOffSet, Am.CreatedOn), 'dd/MMM/yy HH:mm') AS CaptureDate,
           Eg.EstablishmentGroupName AS ActivityName,
           Eg.Id AS ActivityId,
           Am.AppUserId,
           ISNULL(U.Name, '') AS AppUserName,
           ISNULL(Am.SeenClientAnswerMasterId, 0) AS SeenClientAnswerMasterId,
           Am.IsTransferred,
           Am.IsResolved AS AnswerStatus,
           IIF(ISNULL(SAM.ContactMasterId, 0) = 0, ISNULL(SCA.ContactMasterId, 0), ISNULL(SAM.ContactMasterId, 0)) AS ContactMasterId,
           (
               SELECT TOP 1
                   ISNULL(Detail, '')
               FROM dbo.ContactDetails
               WHERE ContactMasterId = IIF(ISNULL(SAM.ContactMasterId, 0) = 0,
                                           ISNULL(SCA.ContactMasterId, 0),
                                           ISNULL(SAM.ContactMasterId, 0))
                     AND QuestionTypeId = 4
           ) AS ContactDetails,
           Am.IsOutStanding,
           Am.IsActioned,
           ISNULL(U.Name, '') AS TransferToUser,
           ISNULL(TransferFromUser.Name, '') AS TransferFromUser,
           Am.IsDisabled,
           ISNULL(F.IsFlag, 0) AS [IsFlag]
    FROM dbo.AnswerMaster AS Am
        INNER JOIN dbo.Establishment AS E
            ON Am.EstablishmentId = E.Id
        INNER JOIN dbo.EstablishmentGroup AS Eg
            ON E.EstablishmentGroupId = Eg.Id
        LEFT OUTER JOIN dbo.AppUser AS U
            ON Am.AppUserId = U.Id
        LEFT OUTER JOIN dbo.SeenClientAnswerMaster AS SAM
            ON Am.SeenClientAnswerMasterId = SAM.Id
        LEFT OUTER JOIN dbo.SeenClientAnswerChild AS SCA
            ON SCA.Id = Am.SeenClientAnswerChildId
        LEFT OUTER JOIN dbo.AnswerMaster AS TransferFromAM
            ON TransferFromAM.Id = Am.AnswerMasterId
        LEFT OUTER JOIN dbo.AppUser AS TransferFromUser
            ON TransferFromAM.AppUserId = TransferFromUser.Id
        LEFT OUTER JOIN dbo.FlagMaster AS F
            ON F.ReportId = Am.Id
               AND F.AppUserId = @AppUserId
               AND F.Type = 1
    WHERE Am.Id = @AnswerMasterId;

    --GET OUT form Data
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
           EstablishmentName,
           Am.Latitude,
           Am.Longitude,
           Am.PI AS EI,
           --CONVERT(DECIMAL(18,0),Am.PI) AS EI ,
           --IIF(@PIDispaly = 1, Am.[PI],IIF(Am.[PI] > 0.00,Am.[PI],-1)) AS EI,
           Am.IsPositive AS SmileType,
           dbo.ChangeDateFormat(DATEADD(MINUTE, Am.TimeOffSet, Am.CreatedOn), 'dd/MMM/yy HH:mm') AS CaptureDate,
           U.Name + ' To '
           + CASE
                 WHEN ISNULL(Am.ContactGroupId, 0) > 0 THEN
                     ISNULL(
                     (
                         SELECT ContactGropName FROM dbo.ContactGroup WHERE Id = Am.ContactGroupId
                     ),
                     ''
                           )
                 ELSE
             (
                 SELECT LEFT(ISNULL(
                             (
                                 SELECT dbo.ConcateString('ContactSummary', Am.ContactMasterId)
                             ),
                             0
                                   ), CHARINDEX(
                                                   ',',
                                                   ISNULL(
                                                   (
                                                       SELECT dbo.ConcateString('ContactSummary', Am.ContactMasterId)
                                                   ),
                                                   0
                                                         )
                                               ) - 0)
             )
             END AS CapturedBy,
           Eg.EstablishmentGroupName AS ActivityName,
           Eg.Id AS ActivityId,
           Am.AppUserId,
           ISNULL(
           (
               SELECT TOP 1
                   Am.Id
               FROM dbo.AnswerMaster AS Am
                   RIGHT JOIN dbo.SeenClientAnswerMaster CM
                       ON Am.SeenClientAnswerMasterId = CM.Id --ISNULL(CM.SeenClientAnswerMasterId, Cm.Id)
               WHERE Am.IsDeleted = 0
                     AND CM.Id = @SeenClientAnswerMasterId
               ORDER BY Am.CreatedOn DESC
           ),
           0
                 ) AS AnswerMasterId,
           ISNULL(Am.IsResolved, '') AS AnswerStatus,
           ISNULL(Am.ContactMasterId, Am.ContactGroupId) AS ContactMasterId,
           ISNULL(Am.IsOutStanding, 0) AS IsOutStanding,
           ISNULL(Am.IsActioned, 0) AS IsActioned,
           ISNULL(Am.IsTransferred, 0) AS IsTransferred,
           ISNULL(U.Name, '') AS TransferToUser,
           ISNULL(TransferFromUser.Name, '') AS TransferFromUser,
           ISNULL(Am.IsDisabled, 0) AS IsDisabled,
           ISNULL(
           (
               SELECT ContactGropName FROM dbo.ContactGroup WHERE Id = Am.ContactGroupId
           ),
           ''
                 ) AS ContactGropName,
           ISNULL(Am.IsRecursion, 0) AS IsRecursion,
           CASE (ISNULL(
                 (
                     SELECT TOP 1
                         Am.Id
                     FROM dbo.AnswerMaster AS Am
                         RIGHT JOIN dbo.SeenClientAnswerMaster CM
                             ON Am.SeenClientAnswerMasterId = ISNULL(CM.SeenClientAnswerMasterId, CM.Id)
                     WHERE Am.IsDeleted = 0
                           AND CM.Id = @SeenClientAnswerMasterId
                     ORDER BY Am.CreatedOn DESC
                 ),
                 0
                       )
                )
               WHEN 0 THEN
                   1
               ELSE
                   0
           END AS IsResend,
           dbo.ChangeDateFormat(DATEADD(MINUTE, Am.TimeOffSet, Am.UpdatedOn), 'dd/MMM/yy HH:mm') AS UpdatedOn,
           @Url AS MobiLink,
           @GroupType AS GroupType,
           CASE
               WHEN Am.ContactGroupId != 0 THEN
                   IIF(
                      (
                          SELECT IsFeedBackSubmitted
                          FROM dbo.FeedbackOnceHistory
                          WHERE SeenclientChildId =
                          (
                              SELECT Id
                              FROM dbo.SeenClientAnswerChild
                              WHERE ContactMasterId = Am.ContactMasterId
                                    AND SeenClientAnswerMasterId = Am.Id
                          )
                                AND SeenClientAnswerMasterId = Am.Id
                      ) = 1,
                      1,
                      0)
               ELSE
                   IIF(
                      (
                          SELECT TOP 1
                              IsFeedBackSubmitted
                          FROM dbo.FeedbackOnceHistory
                          WHERE SeenClientAnswerMasterId = Am.Id
                          ORDER BY Id DESC
                      ) = 1,
                      1,
                      0)
           END AS FeedbackSubmitted,
           ISNULL(F.IsFlag, 0) AS [IsFlag]
    FROM dbo.SeenClientAnswerMaster AS Am
        INNER JOIN dbo.Establishment AS E
            ON Am.EstablishmentId = E.Id
        INNER JOIN dbo.EstablishmentGroup AS Eg
            ON E.EstablishmentGroupId = Eg.Id
        INNER JOIN dbo.AppUser AS U
            ON Am.AppUserId = U.Id
        LEFT OUTER JOIN dbo.SeenClientAnswerMaster AS TransferFromAM
            ON TransferFromAM.Id = Am.SeenClientAnswerMasterId
        LEFT OUTER JOIN dbo.AppUser AS TransferFromUser
            ON TransferFromAM.AppUserId = TransferFromUser.Id
        LEFT OUTER JOIN dbo.FlagMaster AS F
            ON F.ReportId = Am.Id
               AND F.AppUserId = @AppUserId
               AND F.Type = 2
    WHERE Am.Id = @SeenClientAnswerMasterId;
END;
