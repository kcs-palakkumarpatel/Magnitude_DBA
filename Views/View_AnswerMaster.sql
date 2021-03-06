
CREATE VIEW dbo.View_AnswerMaster
AS
    SELECT  Am.Id AS ReportId ,
            Am.EstablishmentId ,
            E.EstablishmentName ,
            Am.AppUserId ,
            ISNULL(U.Name, '') AS UserName ,
            ISNULL(( SELECT TOP ( 1 )
                            Detail
                     FROM   dbo.Answers
                     WHERE  ( QuestionTypeId = 11 )
                            AND ( AnswerMasterId = Am.Id )
                   ), '') AS SenderCellNo ,
            Am.IsOutStanding ,
            Am.IsResolved ,
            --dbo.ChangeDateFormat(DATEADD(MINUTE, Am.TimeOffSet, Am.CreatedOn),
            --                     'MM/dd/yyyy hh:mm AM/PM') AS CaptureDate ,
            DATEADD(MINUTE, Am.TimeOffSet, Am.CreatedOn) AS CreatedOn ,
            --dbo.ChangeDateFormat(DATEADD(MINUTE, Am.TimeOffSet, Am.UpdatedOn),
            --                     'MM/dd/yyyy hh:mm AM/PM') AS UpdatedOn ,
            Am.EI ,
			Am.[PI] ,
            Am.IsPositive ,
            Qr.QuestionnaireType ,
            E.EstablishmentGroupId AS ActivityId ,
            Am.QuestionnaireId ,
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
            Am.IsActioned ,
            E.GroupId,
			am.IsDisabled,
			am.SeenClientAnswerMasterId,
			Am.Latitude,
			Am.Longitude,
			Am.TimeOffSet,
			ISNULL(SCA.StatusHistoryId, 0) AS StatusHistoryId,
			Am.ContactAppUserId
    FROM    dbo.AnswerMaster AS Am
            INNER JOIN dbo.Establishment AS E ON Am.EstablishmentId = E.Id
            INNER JOIN dbo.Questionnaire AS Qr ON Qr.Id = Am.QuestionnaireId
            LEFT OUTER JOIN dbo.AppUser AS U ON Am.AppUserId = U.Id
            LEFT OUTER JOIN dbo.AnswerMaster AS TransferFromAM ON TransferFromAM.Id = Am.AnswerMasterId
            LEFT OUTER JOIN dbo.AppUser AS TransferFromUser ON TransferFromAM.AppUserId = TransferFromUser.Id
            LEFT OUTER JOIN dbo.AppUser AS TransferByUser ON Am.CreatedBy = TransferByUser.Id
			LEFT JOIN dbo.SeenClientAnswerMaster SCA ON SCA.Id = Am.SeenClientAnswerMasterId
    WHERE   Am.IsDeleted = 0;




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
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Am"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 268
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "E"
            Begin Extent = 
               Top = 6
               Left = 306
               Bottom = 136
               Right = 561
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Qr"
            Begin Extent = 
               Top = 6
               Left = 599
               Bottom = 136
               Right = 788
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "U"
            Begin Extent = 
               Top = 6
               Left = 826
               Bottom = 136
               Right = 996
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
      Begin ColumnWidths = 15
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
        ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'View_AnswerMaster';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N' GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'View_AnswerMaster';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'View_AnswerMaster';

