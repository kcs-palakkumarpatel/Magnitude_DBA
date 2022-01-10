CREATE VIEW [dbo].[View_AllAnswerMasterForExportOUT]
AS
    SELECT  Am.Id AS ReportId ,
            ISNULL(Am.EstablishmentId, 0) AS EstablishmentId ,
            E.EstablishmentName ,
            ISNULL(Am.AppUserId, 0) AS UserId ,
            U.Name AS UserName ,
            ISNULL(( SELECT TOP ( 1 )
                            Detail
                     FROM   dbo.SeenClientAnswers
                     WHERE  ( QuestionTypeId = 11 )
                            AND ( SeenClientAnswerMasterId = Am.Id )
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
            'EI' AS QuestionnaireType ,
            'Seenclient' AS FormType ,
            CAST(1 AS BIT) AS IsOut ,
            ISNULL(Am.SeenClientId, 0) AS QuestionnaireId ,
            ISNULL(Am.ReadBy, 0) AS ReadBy ,
            ISNULL(Am.ContactMasterId, 0) AS ContactMasterId ,
            dbo.ConcateString(N'SeenClientQuestions', Am.Id) AS DisplayQuestionTitle ,
            dbo.ConcateString(N'SeenClientAnswersDetail', Am.Id) AS DisplayText ,
            ISNULL(Am.Latitude, '') AS Latitude ,
            ISNULL(Am.Longitude, '') AS Longitude ,
            CAST(0 AS BIT) AS IsTransferred ,
            '' AS TransferToUser ,
            '' AS TransferFromUser ,
            Am.Id AS SeenClientAnswerMasterId ,
            ISNULL(E.EstablishmentGroupId, 0) AS ActivityId ,
            dbo.ConcateString(N'ContactSummary', Am.ContactMasterId) AS ContactDetails ,
            Am.IsActioned ,
            dbo.ConcateString(N'ResolutionCommentsSeenClient', Am.Id) AS ResolutionComments
    FROM    dbo.SeenClientAnswerMaster AS Am
            INNER JOIN dbo.Establishment AS E ON Am.EstablishmentId = E.Id
            INNER JOIN dbo.SeenClient AS S ON Am.SeenClientId = S.Id
            INNER JOIN dbo.AppUser AS U ON Am.AppUserId = U.Id
    WHERE   ( Am.IsDeleted = 0 )
            AND ( E.IsDeleted = 0 )
            AND ( S.IsDeleted = 0 )
            AND ( U.IsDeleted = 0 )
GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[41] 4[26] 2[15] 3) )"
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
         Begin Table = "Am"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 135
               Right = 240
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "E"
            Begin Extent = 
               Top = 6
               Left = 278
               Bottom = 135
               Right = 533
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "S"
            Begin Extent = 
               Top = 6
               Left = 571
               Bottom = 135
               Right = 744
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "U"
            Begin Extent = 
               Top = 138
               Left = 38
               Bottom = 267
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 4575
         Alias = 1725
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'View_AllAnswerMasterForExportOUT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'View_AllAnswerMasterForExportOUT';

