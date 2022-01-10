CREATE VIEW [dbo].[View_AllDeletedAnswerMaster]
WITH SCHEMABINDING
AS
SELECT Am.Id AS ReportId,
       Am.EstablishmentId,
       EstablishmentName,
       Am.AppUserId AS UserId,
       U.Name AS UserName,
       ISNULL(Am.SenderCellNo, '') AS SenderCellNo,
       Am.IsOutStanding,
       Am.IsResolved AS AnswerStatus,
       Am.TimeOffSet,
       DATEADD(MINUTE, Am.TimeOffSet, Am.CreatedOn) AS CreatedOn,
       DATEADD(MINUTE, Am.TimeOffSet, Am.UpdatedOn) AS UpdatedOn,
       Am.EI,
       Am.[PI],
       Am.IsPositive AS SmileType,
       'EI' AS QuestionnaireType,
       'Seenclient' AS FormType,
       CAST(1 AS BIT) AS IsOut,
       Am.SeenClientId AS QuestionnaireId,
       ISNULL(Am.ReadBy, 0) AS ReadBy,
       ISNULL(Am.ContactMasterId, 0) AS ContactMasterId,
       ISNULL(Am.ContactGroupId, 0) AS ContactGroupId,
       ISNULL(Am.Latitude, '') AS Latitude,
       ISNULL(Am.Longitude, '') AS Longitude,
       Am.IsTransferred,
       CASE Am.IsTransferred
           WHEN 1 THEN
               ISNULL(U.Name, '')
           ELSE
               ''
       END AS TransferToUser,
       CASE Am.IsTransferred
           WHEN 1 THEN
               ISNULL(TransferFromUser.Name, ISNULL(TransferByUser.Name, ''))
           ELSE
               ''
       END AS TransferFromUser,
       0 AS SeenClientAnswerMasterId,
       E.EstablishmentGroupId AS ActivityId,
       Am.IsActioned,
       ISNULL(TransferByUser.Id, 0) AS TransferByUserId,
       ISNULL(TransferFromUser.Id, 0) AS TransferFromUserId,
       ISNULL(Am.IsDisabled, 0) AS IsDisabled,
       ISNULL(Am.CreatedBy, 0) AS CreatedUserId,
       ISNULL(Am.IsFlag, 0) AS IsFlag1,
       ES.Id AS StatusId,
       ES.StatusName AS StatusName,
       SII.IconPath AS StatusImage,
       SH.StatusDateTime AS StatusTime,
       (GETUTCDATE() - SH.CreatedOn) AS StatusCounter,
	   Am.DeletedOn
FROM dbo.SeenClientAnswerMaster AS Am
    INNER JOIN dbo.Establishment AS E
        ON Am.EstablishmentId = E.Id
    INNER JOIN dbo.SeenClient AS S
        ON Am.SeenClientId = S.Id
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
    LEFT OUTER JOIN dbo.AppUser AS TransferByUser
        ON Am.CreatedBy = TransferByUser.Id
WHERE Am.IsDeleted = 1 


