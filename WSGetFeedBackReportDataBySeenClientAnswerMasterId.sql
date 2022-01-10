-- =============================================
-- Author:				Sunil Vaghasiya
-- Create date:		21-June-2017
-- Description:	Get feedback IN by SeenClientAnswerMasterId
-- Call SP:			dbo.WSGetFeedBackReportDataBySeenClientAnswerMasterId 87272
-- =============================================
CREATE PROCEDURE dbo.WSGetFeedBackReportDataBySeenClientAnswerMasterId
    @SeenClientAnswerMasterId BIGINT,
    @AppuserId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Am.Id AS ReportId,
           Am.EstablishmentId,
           EstablishmentName,
           Am.Latitude,
           Am.Longitude,
           Am.PI AS EI,
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
                   ISNULL(cd.Detail, '')
               FROM dbo.ContactDetails cd
                   INNER JOIN dbo.ContactQuestions cq
                       ON cq.Id = cd.ContactQuestionId
               WHERE cd.ContactMasterId = IIF(ISNULL(SAM.ContactMasterId, 0) = 0,
                                              ISNULL(SCA.ContactMasterId, 0),
                                              ISNULL(SAM.ContactMasterId, 0))
                     AND cd.QuestionTypeId = 4
               ORDER BY cq.Position
           ) AS ContactDetails,
           Am.IsOutStanding,
           Am.IsActioned,
           ISNULL(U.Name, '') AS TransferToUser,
           ISNULL(TransferFromUser.Name, '') AS TransferFromUser,
           Am.IsDisabled,
           ISNULL(F.IsFlag, 0) AS [IsFlag]
    FROM dbo.AnswerMaster AS Am WITH (NOLOCK)
        INNER JOIN dbo.Establishment AS E WITH (NOLOCK)
            ON Am.EstablishmentId = E.Id
        INNER JOIN dbo.EstablishmentGroup AS Eg WITH (NOLOCK)
            ON E.EstablishmentGroupId = Eg.Id
        LEFT OUTER JOIN dbo.AppUser AS U WITH (NOLOCK)
            ON Am.AppUserId = U.Id AND U.IsDeleted = 0
        LEFT OUTER JOIN dbo.SeenClientAnswerMaster AS SAM WITH (NOLOCK)
            ON Am.SeenClientAnswerMasterId = ISNULL(SAM.Id, 0)
               AND SAM.IsDeleted = 0
        LEFT OUTER JOIN dbo.SeenClientAnswerChild AS SCA WITH (NOLOCK)
            ON SCA.Id = Am.SeenClientAnswerChildId
        LEFT OUTER JOIN dbo.AnswerMaster AS TransferFromAM WITH (NOLOCK)
            ON TransferFromAM.Id = Am.AnswerMasterId
        LEFT OUTER JOIN dbo.AppUser AS TransferFromUser WITH (NOLOCK)
            ON TransferFromAM.AppUserId = TransferFromUser.Id
        LEFT OUTER JOIN dbo.FlagMaster AS F WITH (NOLOCK)
            ON F.ReportId = Am.Id
               AND F.AppUserId = @AppuserId
               AND F.Type = 1
    WHERE SAM.Id = @SeenClientAnswerMasterId
          AND Am.IsDeleted = 0
    ORDER BY Am.Id ASC;
    SET NOCOUNT OFF;
END;
