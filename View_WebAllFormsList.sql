CREATE VIEW [dbo].[View_WebAllFormsList]
AS
    SELECT  Am.Id AS ReportId ,
            Am.EstablishmentId ,
            EstablishmentName ,
            Am.AppUserId AS UserId ,
            ISNULL(U.Name, '') AS UserName ,
            ISNULL(Am.SenderCellNo, '') AS SenderCellNo ,
            Am.IsOutStanding ,
            Am.IsResolved AS AnswerStatus ,
            Am.TimeOffSet ,
            DATEADD(MINUTE, Am.TimeOffSet, Am.CreatedOn) AS CreatedOn ,
            DATEADD(MINUTE, Am.TimeOffSet, Am.UpdatedOn) AS UpdatedOn ,
            Am.EI ,
            Am.[PI] ,
            Am.IsPositive AS SmileType ,
            Qr.QuestionnaireType ,
            'Feedback' AS FormType ,
            CAST(0 AS BIT) AS IsOut ,
            Am.QuestionnaireId ,
            ISNULL(Am.ReadBy, 0) AS ReadBy ,
            IIF(ISNULL(SAM.ContactMasterId, 0) = 0, ISNULL(SCD.ContactMasterId, 0), ISNULL(SAM.ContactMasterId, 0)) AS ContactMasterId ,
            ISNULL(SAM.ContactGroupId, 0) AS ContactGroupId ,
            ISNULL(Am.Latitude, '') AS Latitude ,
            ISNULL(Am.Longitude, '') AS Longitude ,
            Am.IsTransferred ,
            CASE Am.IsTransferred
              WHEN 1 THEN ISNULL(U.Name, '')
              ELSE ''
            END AS TransferToUser ,
            CASE Am.IsTransferred
              WHEN 1
              THEN ISNULL(TransferFromUser.Name,
                          ISNULL(TransferByUser.Name, ''))
              ELSE ''
            END AS TransferFromUser ,
            ISNULL(Am.SeenClientAnswerMasterId, 0) AS SeenClientAnswerMasterId ,
            E.EstablishmentGroupId AS ActivityId ,
            Am.IsActioned ,
            ISNULL(TransferByUser.Id, 0) AS TransferByUserId ,
            ISNULL(TransferFromUser.Id, 0) AS TransferFromUserId ,
            ISNULL(Am.IsDisabled, 0) AS IsDisabled ,
            ISNULL(Am.CreatedBy, 0) AS CreatedUserId
    FROM    dbo.AnswerMaster AS Am
            INNER JOIN dbo.Establishment AS E ON Am.EstablishmentId = E.Id
            INNER JOIN dbo.Questionnaire AS Qr ON Qr.Id = Am.QuestionnaireId
            LEFT OUTER JOIN dbo.SeenClientAnswerMaster AS SAM ON Am.SeenClientAnswerMasterId = SAM.Id
			LEFT OUTER JOIN dbo.SeenClientAnswerChild AS SCD ON SCD.Id = Am.SeenClientAnswerChildId
            LEFT OUTER JOIN dbo.AppUser AS U ON Am.AppUserId = U.Id
            LEFT OUTER JOIN dbo.AnswerMaster AS TransferFromAM ON TransferFromAM.Id = Am.AnswerMasterId
            LEFT OUTER JOIN dbo.AppUser AS TransferFromUser ON TransferFromAM.AppUserId = TransferFromUser.Id
            LEFT OUTER JOIN dbo.AppUser AS TransferByUser ON Am.CreatedBy = TransferByUser.Id
    WHERE   Am.IsDeleted = 0
    UNION ALL
    SELECT  Am.Id AS ReportId ,
            Am.EstablishmentId ,
            EstablishmentName ,
            Am.AppUserId AS UserId ,
            U.Name AS UserName ,
            ISNULL(Am.SenderCellNo, '') AS SenderCellNo ,
            Am.IsOutStanding ,
            Am.IsResolved AS AnswerStatus ,
            Am.TimeOffSet ,
            DATEADD(MINUTE, Am.TimeOffSet, Am.CreatedOn) AS CreatedOn ,
            DATEADD(MINUTE, Am.TimeOffSet, Am.UpdatedOn) AS UpdatedOn ,
            Am.EI ,
            Am.[PI] ,
            Am.IsPositive AS SmileType ,
            'EI' AS QuestionnaireType ,
            'Seenclient' AS FormType ,
            CAST(1 AS BIT) AS IsOut ,
            Am.SeenClientId AS QuestionnaireId ,
            ISNULL(Am.ReadBy, 0) AS ReadBy ,
            ISNULL(Am.ContactMasterId, 0) AS ContactMasterId ,
            ISNULL(Am.ContactGroupId, 0) AS ContactGroupId ,
            ISNULL(Am.Latitude, '') AS Latitude ,
            ISNULL(Am.Longitude, '') AS Longitude ,
            Am.IsTransferred ,
            CASE Am.IsTransferred
              WHEN 1 THEN ISNULL(U.Name, '')
              ELSE ''
            END AS TransferToUser ,
            CASE Am.IsTransferred
              WHEN 1
              THEN ISNULL(TransferFromUser.Name,
                          ISNULL(TransferByUser.Name, ''))
              ELSE ''
            END AS TransferFromUser ,
            0 AS SeenClientAnswerMasterId ,
            E.EstablishmentGroupId AS ActivityId ,
            Am.IsActioned ,
            ISNULL(TransferByUser.Id, 0) AS TransferByUserId ,
            ISNULL(TransferFromUser.Id, 0) AS TransferFromUserId ,
            ISNULL(Am.IsDisabled, 0) AS IsDisabled ,
            ISNULL(Am.CreatedBy, 0) AS CreatedUserId
    FROM    dbo.SeenClientAnswerMaster AS Am
            INNER JOIN dbo.Establishment AS E ON Am.EstablishmentId = E.Id
            INNER JOIN dbo.SeenClient AS S ON Am.SeenClientId = S.Id
            INNER JOIN dbo.AppUser AS U ON Am.AppUserId = U.Id
            LEFT OUTER JOIN dbo.SeenClientAnswerMaster AS TransferFromAM ON TransferFromAM.Id = Am.SeenClientAnswerMasterId
            LEFT OUTER JOIN dbo.AppUser AS TransferFromUser ON TransferFromAM.AppUserId = TransferFromUser.Id
            LEFT OUTER JOIN dbo.AppUser AS TransferByUser ON Am.CreatedBy = TransferByUser.Id
    WHERE   Am.IsDeleted = 0;


