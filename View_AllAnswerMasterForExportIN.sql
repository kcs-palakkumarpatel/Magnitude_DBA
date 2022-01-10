


CREATE VIEW [dbo].[View_AllAnswerMasterForExportIN]
AS
    SELECT  Am.Id AS ReportId ,
            Am.EstablishmentId ,
            EstablishmentName ,
            Am.AppUserId AS UserId ,
            ISNULL(U.Name, '') AS UserName ,
            ISNULL(( SELECT TOP 1
                            Detail
                     FROM   dbo.Answers
                     WHERE  QuestionTypeId = 11
                            AND AnswerMasterId = Am.Id
                   ), '') AS SenderCellNo ,
            Am.IsOutStanding ,
            Am.IsResolved AS AnswerStatus ,
            dbo.ChangeDateFormat(DATEADD(MINUTE, Am.TimeOffSet, Am.CreatedOn),
                                 'MM/dd/yyyy hh:mm AM/PM') AS CaptureDate ,
            DATEADD(MINUTE, Am.TimeOffSet, Am.CreatedOn) AS CreatedOn ,
            dbo.ChangeDateFormat(DATEADD(MINUTE, Am.TimeOffSet, Am.UpdatedOn),
                                 'MM/dd/yyyy hh:mm AM/PM') AS UpdatedOn ,
            CASE WHEN Am.IsPositive = 'Neutral' THEN 'N/A'
                 ELSE CAST(Am.EI AS NVARCHAR(50))
            END AS EI ,
            Am.IsPositive AS SmileType ,
            Qr.QuestionnaireType ,
            'Feedback' AS FormType ,
            CAST(0 AS BIT) AS IsOut ,
            Am.QuestionnaireId ,
            ISNULL(Am.ReadBy, 0) AS ReadBy ,
            ISNULL(ContactMasterId, 0) AS ContactMasterId ,
            dbo.ConcateString('Questions', Am.Id) AS DisplayQuestionTitle ,
            dbo.ConcateString('AnswersDetail', Am.Id) AS DisplayText ,
            ISNULL(Am.Latitude, '') AS Latitude ,
            ISNULL(Am.Longitude, '') AS Longitude ,
            Am.IsTransferred ,
            CASE WHEN Am.IsTransferred = 1 THEN ISNULL(U.Name, '')
                 ELSE ''
            END AS TransferToUser ,
            ISNULL(TransferFromUser.Name, '') AS TransferFromUser ,
            ISNULL(Am.SeenClientAnswerMasterId, 0) AS SeenClientAnswerMasterId ,
            E.EstablishmentGroupId AS ActivityId ,
            dbo.ConcateString('ContactSummary', ISNULL(SAM.ContactMasterId, 0)) AS ContactDetails ,
            Am.IsActioned ,
            dbo.ConcateString('ResolutionComments', Am.Id) AS ResolutionComments
    FROM    dbo.AnswerMaster AS Am
            INNER JOIN dbo.Establishment AS E ON Am.EstablishmentId = E.Id
            INNER JOIN dbo.Questionnaire AS Qr ON Qr.Id = Am.QuestionnaireId
            LEFT OUTER JOIN dbo.SeenClientAnswerMaster AS SAM ON Am.SeenClientAnswerMasterId = SAM.Id
            LEFT OUTER JOIN dbo.AppUser AS U ON Am.AppUserId = U.Id
            LEFT OUTER JOIN dbo.AnswerMaster AS TransferFromAM ON TransferFromAM.Id = Am.AnswerMasterId
            LEFT OUTER JOIN dbo.AppUser AS TransferFromUser ON TransferFromAM.AppUserId = TransferFromUser.Id
    WHERE   Am.IsDeleted = 0