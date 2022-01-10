

CREATE VIEW [dbo].[View_AllAnswerMaster]
WITH SCHEMABINDING
AS
SELECT Am.Id AS ReportId,
       Am.EstablishmentId,
       EstablishmentName,
       Am.AppUserId AS UserId,
       ISNULL(U.Name, '') AS UserName,
       ISNULL(Am.SenderCellNo, '') AS SenderCellNo,
       Am.IsOutStanding,
       Am.IsResolved AS AnswerStatus,
       Am.TimeOffSet,
       DATEADD(MINUTE, Am.TimeOffSet, Am.CreatedOn) AS CreatedOn,
       DATEADD(MINUTE, Am.TimeOffSet, Am.UpdatedOn) AS UpdatedOn,
       Am.EI,
       Am.[PI],
       Am.IsPositive AS SmileType,
       Qr.QuestionnaireType,
       'Feedback' AS FormType,
       CAST(0 AS BIT) AS IsOut,
       Am.QuestionnaireId,
       ISNULL(Am.ReadBy, 0) AS ReadBy,
       IIF(ISNULL(SAM.ContactMasterId, 0) = 0, ISNULL(SCD.ContactMasterId, 0), ISNULL(SAM.ContactMasterId, 0)) AS ContactMasterId,
       ISNULL(SAM.ContactGroupId, 0) AS ContactGroupId,
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
       ISNULL(Am.SeenClientAnswerMasterId, 0) AS SeenClientAnswerMasterId,
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
       ISNULL(E.ReleaseDateValidationMessage, '') AS ReleaseDateValidationMessage,
       ISNULL(E.MobiExpiredValidationMessage, '') AS MobiExpiredValidationMessage,
       ISNULL(E.CaptureReminderAlert, '') AS CaptureReminderAlert,
       ISNULL(E.FeedBackReminderAlert, '') AS FeedBackReminderAlert,
		SAM.IsUnAllocated,
		SAM.StatusHistoryId
FROM dbo.AnswerMaster AS Am
    INNER JOIN dbo.Establishment AS E
        ON Am.EstablishmentId = E.Id
    INNER JOIN dbo.Questionnaire AS Qr
        ON Qr.Id = Am.QuestionnaireId
    LEFT OUTER JOIN dbo.SeenClientAnswerMaster AS SAM
        ON Am.SeenClientAnswerMasterId = SAM.Id
    LEFT OUTER JOIN dbo.StatusHistory AS SH
        ON SAM.StatusHistoryId = SH.Id
    LEFT OUTER JOIN dbo.EstablishmentStatus AS ES
        ON SH.EstablishmentStatusId = ES.Id
    LEFT OUTER JOIN dbo.StatusIconImage SII
        ON ES.StatusIconImageId = SII.Id
    LEFT OUTER JOIN dbo.SeenClientAnswerChild AS SCD
        ON SCD.Id = Am.SeenClientAnswerChildId
    LEFT OUTER JOIN dbo.AppUser AS U
        ON Am.AppUserId = U.Id
    LEFT OUTER JOIN dbo.AnswerMaster AS TransferFromAM
        ON TransferFromAM.Id = Am.AnswerMasterId
    LEFT OUTER JOIN dbo.AppUser AS TransferFromUser
        ON TransferFromAM.AppUserId = TransferFromUser.Id
    LEFT OUTER JOIN dbo.AppUser AS TransferByUser
        ON Am.CreatedBy = TransferByUser.Id
WHERE Am.IsDeleted = 0
UNION
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
       ISNULL(E.ReleaseDateValidationMessage, '') AS ReleaseDateValidationMessage,
       ISNULL(E.MobiExpiredValidationMessage, '') AS MobiExpiredValidationMessage,
       ISNULL(E.CaptureReminderAlert, '') AS CaptureReminderAlert,
       ISNULL(E.FeedBackReminderAlert, '') AS FeedBackReminderAlert,
	   Am.IsUnAllocated,
	   Am.StatusHistoryId
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
WHERE Am.IsDeleted = 0







GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = -96
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 16
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'View_AllAnswerMaster';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'View_AllAnswerMaster';

