-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,17 May 2018>
-- Description:	<Description,,>
-- Call SP:		WSGetActionListByReportIdForCustomer 94982, 1,1243
--				WSGetActionListByReportIdForCustomer 36738,0,35354,0
-- =============================================
CREATE PROCEDURE [dbo].[WSGetActionListByReportIdForCustomer]
    @ReportId BIGINT ,
    @IsOut BIT,
	@lgCustomerUserId  BIGINT, 
	@ShowhideChat BIT
AS
    BEGIN
	DECLARE @list VARCHAR(100)
	DECLARE @path VARCHAR(100)
	DECLARE @Iscustome Bit
	SELECT @path = (SELECT TOP 1 KeyValue  + 'Actions/' FROM dbo.AAAAConfigSettings WHERE    KeyName = 'DocViewerRootFolderPathWebApp')
	IF @ShowhideChat = 1
	BEGIN
		 IF @IsOut = 1
            BEGIN
                SELECT  LA.Id ,
                        [Conversation] ,
                        U.Name AS UserName ,
						U.Name AS UName ,
                        dbo.ChangeDateFormat(DATEADD(MINUTE, E.TimeOffSet,
                                                     LA.CreatedOn),
                                             'dd/MMM/yyyy hh:mm AM/PM') AS CaptureDate ,
                        CASE LA.IsReminderSet
                          WHEN 1 THEN 'Reminder'
                          ELSE ''
                        END AS ReminderSet,
						ISNULL(LA.Attachment,'') AS Attachment,
						@path AS FilePath,
						ISNULL(PNW.IsRead,1) AS IsRead,
						ISNULL(LA.IsNote,0) AS IsNote,
						LA.IsExternalType AS ExternalType,
						LA.CustomerName AS CustomerName,
						LA.CustomerAppId AS CustomerAppId,
						IIF(ISNULL(LA.CustomerAppId,0) = CONVERT(VARCHAR(1000), @lgCustomerUserId),1,0) AS IsCustomer
						--CASE WHEN ISNULL(@lgCustomerUserId,0) > 0 THEN (CASE when (SELECT COUNT(1) FROM dbo.CloseLoopAction WHERE CustomerAppId = @lgCustomerUserId) > 1 THEN 1 ELSE 0 END)  ELSE 0 END AS  IsCustomer
		                FROM    dbo.CloseLoopAction AS LA 
                        INNER JOIN dbo.AppUser AS U ON LA.AppUserId = U.Id
                        INNER JOIN dbo.SeenClientAnswerMaster AS Am ON Am.Id = LA.SeenClientAnswerMasterId
                        INNER JOIN dbo.Establishment AS E ON E.Id = Am.EstablishmentId
						LEFT JOIN dbo.PendingNotificationWeb PNW ON pnw.RefId = @ReportId AND la.[Conversation] = pnw.[Message]
                WHERE   LA.SeenClientAnswerMasterId = @ReportId
		 UNION 
				SELECT  LA.Id ,
                        [Conversation] ,
                        U.Name AS UserName ,
						U.Name AS UName ,
                        dbo.ChangeDateFormat(DATEADD(MINUTE, E.TimeOffSet,
                                                     LA.CreatedOn),
                                             'dd/MMM/yyyy hh:mm AM/PM') AS CaptureDate ,
                        CASE LA.IsReminderSet
                          WHEN 1 THEN 'Reminder'
                          ELSE ''
                        END AS ReminderSet,
						ISNULL(LA.Attachment,'') AS Attachment,
						@path AS FilePath,
						ISNULL(PNW.IsRead,1) AS IsRead,
						ISNULL(LA.IsNote,0) AS IsNote,
						LA.IsExternalType AS ExternalType,
						LA.CustomerName AS CustomerName,
						LA.CustomerAppId AS CustomerAppId,
						IIF(ISNULL(LA.CustomerAppId,0) = CONVERT(VARCHAR(1000), @lgCustomerUserId),1,0) AS IsCustomer
                FROM    dbo.CloseLoopAction AS LA
                        INNER JOIN dbo.AppUser AS U ON LA.AppUserId = U.Id
                        INNER JOIN dbo.AnswerMaster AS Am ON Am.Id = LA.AnswerMasterId
                        INNER JOIN dbo.Establishment AS E ON E.Id = Am.EstablishmentId
						LEFT JOIN dbo.PendingNotificationWeb PNW ON pnw.RefId = @ReportId AND la.[Conversation] = pnw.[Message]
                WHERE   Am.SeenClientAnswerMasterId = @ReportId
			UNION
                        SELECT  LA.Id ,
                        [Conversation] ,
                        U.Name AS UserName ,
						 U.Name AS UName ,
                        dbo.ChangeDateFormat(DATEADD(MINUTE, E.TimeOffSet,
                                                     LA.CreatedOn),
                                             'dd/MMM/yyyy hh:mm AM/PM') AS CaptureDate ,
                        CASE LA.IsReminderSet
                          WHEN 1 THEN 'Reminder'
                          ELSE ''
                        END AS ReminderSet,
						ISNULL(LA.Attachment,'') AS Attachment,
						@path AS FilePath,
						ISNULL(PNW.IsRead,1) AS IsRead,
						ISNULL(LA.IsNote,0) AS IsNote,
						LA.IsExternalType AS ExternalType,
						LA.CustomerName AS CustomerName,
						LA.CustomerAppId AS CustomerAppId,
						IIF(ISNULL(LA.CustomerAppId,0) = CONVERT(VARCHAR(1000), @lgCustomerUserId),1,0) AS IsCustomer
                FROM    dbo.CloseLoopAction AS LA 
                        INNER JOIN dbo.AppUser AS U ON LA.AppUserId = U.Id
                        INNER JOIN dbo.SeenClientAnswerMaster AS Am ON Am.Id = LA.SeenClientAnswerMasterId
                        INNER JOIN dbo.Establishment AS E ON E.Id = Am.EstablishmentId
						LEFT JOIN dbo.PendingNotificationWeb PNW ON pnw.RefId = @ReportId AND la.[Conversation] = pnw.[Message]
                WHERE   LA.SeenClientAnswerMasterId = @ReportId AND LA.IsExternalType IS NOT NULL AND LA.IsExternalType !=0
            END;
        ELSE
            BEGIN
                SELECT  LA.Id ,
                        [Conversation] ,
                        U.Name AS UserName ,
						 U.Name AS UName ,
                        dbo.ChangeDateFormat(DATEADD(MINUTE, E.TimeOffSet,
                                                     LA.CreatedOn),
                                             'dd/MMM/yyyy hh:mm AM/PM') AS CaptureDate ,
                        CASE LA.IsReminderSet
                          WHEN 1 THEN 'Reminder'
                          ELSE ''
                        END AS ReminderSet,
						ISNULL(LA.Attachment,'')  AS Attachment,
						@path AS FilePath,
						ISNULL(PNW.IsRead,1) AS IsRead,
						ISNULL(LA.IsNote,0) AS IsNote,
						LA.IsExternalType AS ExternalType,
						LA.CustomerName AS CustomerName,
						LA.CustomerAppId AS CustomerAppId,
						IIF(ISNULL(LA.CustomerAppId,0) = CONVERT(VARCHAR(1000), @lgCustomerUserId),1,0) AS IsCustomer
                FROM    dbo.CloseLoopAction AS LA
                        INNER JOIN dbo.AppUser AS U ON LA.AppUserId = U.Id
                        INNER JOIN dbo.AnswerMaster AS Am ON Am.Id = LA.AnswerMasterId
                        INNER JOIN dbo.Establishment AS E ON E.Id = Am.EstablishmentId
						LEFT JOIN dbo.PendingNotificationWeb PNW ON pnw.RefId = @ReportId AND la.[Conversation] = pnw.[Message] 
                WHERE   LA.AnswerMasterId = @ReportId
				UNION
                     SELECT  LA.Id ,
                        [Conversation] ,
                        U.Name AS UserName ,
						 U.Name AS UName ,
                        dbo.ChangeDateFormat(DATEADD(MINUTE, E.TimeOffSet,
                                                     LA.CreatedOn),
                                             'dd/MMM/yyyy hh:mm AM/PM') AS CaptureDate ,
                        CASE LA.IsReminderSet
                          WHEN 1 THEN 'Reminder'
                          ELSE ''
                        END AS ReminderSet,
						ISNULL(LA.Attachment,'')  AS Attachment,
						@path AS FilePath,
						ISNULL(PNW.IsRead,1) AS IsRead,
						ISNULL(LA.IsNote,0) AS IsNote,
						LA.IsExternalType AS ExternalType,
						LA.CustomerName AS CustomerName,
						LA.CustomerAppId AS CustomerAppId,
						IIF(ISNULL(LA.CustomerAppId,0) = CONVERT(VARCHAR(1000), @lgCustomerUserId),1,0) AS IsCustomer
                FROM    dbo.CloseLoopAction AS LA
                        INNER JOIN dbo.AppUser AS U ON LA.AppUserId = U.Id
                        INNER JOIN dbo.AnswerMaster AS Am ON Am.Id = LA.AnswerMasterId
                        INNER JOIN dbo.Establishment AS E ON E.Id = Am.EstablishmentId
						LEFT JOIN dbo.PendingNotificationWeb as PNW ON PNW.RefId = @ReportId AND la.[Conversation] = pnw.[Message]
                WHERE   Am.AnswerMasterId = @ReportId
				UNION 
				   SELECT  LA.Id ,
                        [Conversation] ,
                        U.Name AS UserName ,
						 U.Name AS UName ,
                        dbo.ChangeDateFormat(DATEADD(MINUTE, E.TimeOffSet,
                                                     LA.CreatedOn),
                                             'dd/MMM/yyyy hh:mm AM/PM') AS CaptureDate ,
                        CASE LA.IsReminderSet
                          WHEN 1 THEN 'Reminder'
                          ELSE ''
                        END AS ReminderSet,
					    ISNULL(LA.Attachment,'') AS Attachment,
						@path AS FilePath,
							ISNULL(PNW.IsRead,1) AS IsRead,
							ISNULL(LA.IsNote,0) AS IsNote,
							LA.IsExternalType AS ExternalType,
							LA.CustomerName AS CustomerName,
							LA.CustomerAppId AS CustomerAppId,
							IIF(ISNULL(LA.CustomerAppId,0) = CONVERT(VARCHAR(1000), @lgCustomerUserId),1,0) AS IsCustomer
                FROM    dbo.CloseLoopAction AS LA
                        INNER JOIN dbo.AppUser AS U ON LA.AppUserId = U.Id
                        INNER JOIN dbo.AnswerMaster AS Am ON Am.Id = LA.AnswerMasterId
                        INNER JOIN dbo.Establishment AS E ON E.Id = Am.EstablishmentId
						LEFT JOIN dbo.PendingNotificationWeb PNW ON pnw.RefId = @ReportId AND la.[Conversation] = pnw.[Message]
                WHERE   LA.AnswerMasterId = @ReportId
            END;
	END
    ELSE
    BEGIN
        IF @IsOut = 1
            BEGIN
                SELECT  LA.Id ,
                        [Conversation] ,
                        U.Name AS UserName ,
						U.Name AS UName ,
                        dbo.ChangeDateFormat(DATEADD(MINUTE, E.TimeOffSet,
                                                     LA.CreatedOn),
                                             'dd/MMM/yyyy hh:mm AM/PM') AS CaptureDate ,
                        CASE LA.IsReminderSet
                          WHEN 1 THEN 'Reminder'
                          ELSE ''
                        END AS ReminderSet,
						ISNULL(LA.Attachment,'') AS Attachment,
						@path AS FilePath,
						ISNULL(PNW.IsRead,1) AS IsRead,
						ISNULL(LA.IsNote,0) AS IsNote,
						LA.IsExternalType AS ExternalType,
						LA.CustomerName AS CustomerName,
						LA.CustomerAppId AS CustomerAppId,
						IIF(ISNULL(LA.CustomerAppId,0) IN (CONVERT(VARCHAR(1000), @lgCustomerUserId)),1,0) AS IsCustomer
						--CASE WHEN ISNULL(@lgCustomerUserId,0) > 0 THEN (CASE when (SELECT COUNT(1) FROM dbo.CloseLoopAction WHERE CustomerAppId = @lgCustomerUserId) > 1 THEN 1 ELSE 0 END)  ELSE 0 END AS  IsCustomer
		                FROM    dbo.CloseLoopAction AS LA 
                        INNER JOIN dbo.AppUser AS U ON LA.AppUserId = U.Id
                        INNER JOIN dbo.SeenClientAnswerMaster AS Am ON Am.Id = LA.SeenClientAnswerMasterId
                        INNER JOIN dbo.Establishment AS E ON E.Id = Am.EstablishmentId
						LEFT JOIN dbo.PendingNotificationWeb PNW ON pnw.RefId = @ReportId AND la.[Conversation] = pnw.[Message]
                WHERE   LA.SeenClientAnswerMasterId = @ReportId and (SELECT data FROM dbo.split(ISNULL(LA.CustomerAppId,'0'),',') WHERE data = CONVERT(VARCHAR(1000), @lgCustomerUserId)) IN (CONVERT(VARCHAR(1000), @lgCustomerUserId))
		UNION
		   SELECT  LA.Id ,
                        [Conversation] ,
                        U.Name AS UserName ,
						U.Name AS UName ,
                        dbo.ChangeDateFormat(DATEADD(MINUTE, E.TimeOffSet,
                                                     LA.CreatedOn),
                                             'dd/MMM/yyyy hh:mm AM/PM') AS CaptureDate ,
                        CASE LA.IsReminderSet
                          WHEN 1 THEN 'Reminder'
                          ELSE ''
                        END AS ReminderSet,
						ISNULL(LA.Attachment,'') AS Attachment,
						@path AS FilePath,
						ISNULL(PNW.IsRead,1) AS IsRead,
						ISNULL(LA.IsNote,0) AS IsNote,
						LA.IsExternalType AS ExternalType,
						LA.CustomerName AS CustomerName,
						LA.CustomerAppId AS CustomerAppId,
						IIF(ISNULL(LA.CustomerAppId,0) IN (CONVERT(VARCHAR(1000), @lgCustomerUserId)),1,0) AS IsCustomer
						--CASE WHEN ISNULL(@lgCustomerUserId,0) > 0 THEN (CASE when (SELECT COUNT(1) FROM dbo.CloseLoopAction WHERE CustomerAppId = @lgCustomerUserId) > 1 THEN 1 ELSE 0 END)  ELSE 0 END AS  IsCustomer
		                FROM    dbo.CloseLoopAction AS LA 
                        INNER JOIN dbo.AppUser AS U ON LA.AppUserId = U.Id
                        INNER JOIN dbo.SeenClientAnswerMaster AS Am ON Am.Id = LA.SeenClientAnswerMasterId
                        INNER JOIN dbo.Establishment AS E ON E.Id = Am.EstablishmentId
						LEFT JOIN dbo.PendingNotificationWeb PNW ON pnw.RefId = @ReportId AND la.[Conversation] = pnw.[Message]
                WHERE   LA.SeenClientAnswerMasterId = @ReportId AND LA.Conversation LIKE '%@EveryOne%'
		 UNION 
				SELECT  LA.Id ,
                        [Conversation] ,
                        U.Name AS UserName ,
						U.Name AS UName ,
                        dbo.ChangeDateFormat(DATEADD(MINUTE, E.TimeOffSet,
                                                     LA.CreatedOn),
                                             'dd/MMM/yyyy hh:mm AM/PM') AS CaptureDate ,
                        CASE LA.IsReminderSet
                          WHEN 1 THEN 'Reminder'
                          ELSE ''
                        END AS ReminderSet,
						ISNULL(LA.Attachment,'') AS Attachment,
						@path AS FilePath,
						ISNULL(PNW.IsRead,1) AS IsRead,
						ISNULL(LA.IsNote,0) AS IsNote,
						LA.IsExternalType AS ExternalType,
						LA.CustomerName AS CustomerName,
						LA.CustomerAppId AS CustomerAppId,
						IIF(ISNULL(LA.CustomerAppId,0) IN (CONVERT(VARCHAR(1000), @lgCustomerUserId)),1,0) AS IsCustomer
                FROM    dbo.CloseLoopAction AS LA
                        INNER JOIN dbo.AppUser AS U ON LA.AppUserId = U.Id
                        INNER JOIN dbo.AnswerMaster AS Am ON Am.Id = LA.AnswerMasterId
                        INNER JOIN dbo.Establishment AS E ON E.Id = Am.EstablishmentId
						LEFT JOIN dbo.PendingNotificationWeb PNW ON pnw.RefId = @ReportId AND la.[Conversation] = pnw.[Message]
                WHERE   Am.SeenClientAnswerMasterId = @ReportId and (SELECT data FROM dbo.split(ISNULL(LA.CustomerAppId,'0'),',') WHERE data = CONVERT(VARCHAR(1000), @lgCustomerUserId)) IN (CONVERT(VARCHAR(1000), @lgCustomerUserId))
			UNION
                        SELECT  LA.Id ,
                        [Conversation] ,
                        U.Name AS UserName ,
						 U.Name AS UName ,
                        dbo.ChangeDateFormat(DATEADD(MINUTE, E.TimeOffSet,
                                                     LA.CreatedOn),
                                             'dd/MMM/yyyy hh:mm AM/PM') AS CaptureDate ,
                        CASE LA.IsReminderSet
                          WHEN 1 THEN 'Reminder'
                          ELSE ''
                        END AS ReminderSet,
						ISNULL(LA.Attachment,'') AS Attachment,
						@path AS FilePath,
						ISNULL(PNW.IsRead,1) AS IsRead,
						ISNULL(LA.IsNote,0) AS IsNote,
						LA.IsExternalType AS ExternalType,
						LA.CustomerName AS CustomerName,
						LA.CustomerAppId AS CustomerAppId,
						IIF(ISNULL(LA.CustomerAppId,0) IN (CONVERT(VARCHAR(1000), @lgCustomerUserId)),1,0) AS IsCustomer
                FROM    dbo.CloseLoopAction AS LA 
                        INNER JOIN dbo.AppUser AS U ON LA.AppUserId = U.Id
                        INNER JOIN dbo.SeenClientAnswerMaster AS Am ON Am.Id = LA.SeenClientAnswerMasterId
                        INNER JOIN dbo.Establishment AS E ON E.Id = Am.EstablishmentId
						LEFT JOIN dbo.PendingNotificationWeb PNW ON pnw.RefId = @ReportId AND la.[Conversation] = pnw.[Message]
                WHERE   LA.SeenClientAnswerMasterId = @ReportId AND LA.IsExternalType IS NOT NULL AND LA.IsExternalType !=0 
				AND (SELECT data FROM dbo.split(ISNULL(LA.CustomerAppId,'0'),',') WHERE data = CONVERT(VARCHAR(1000), @lgCustomerUserId)) IN (CONVERT(VARCHAR(1000), @lgCustomerUserId))
            END;
        ELSE
            BEGIN
                SELECT  LA.Id ,
                        [Conversation] ,
                        U.Name AS UserName ,
						 U.Name AS UName ,
                        dbo.ChangeDateFormat(DATEADD(MINUTE, E.TimeOffSet,
                                                     LA.CreatedOn),
                                             'dd/MMM/yyyy hh:mm AM/PM') AS CaptureDate ,
                        CASE LA.IsReminderSet
                          WHEN 1 THEN 'Reminder'
                          ELSE ''
                        END AS ReminderSet,
						ISNULL(LA.Attachment,'')  AS Attachment,
						@path AS FilePath,
						ISNULL(PNW.IsRead,1) AS IsRead,
						ISNULL(LA.IsNote,0) AS IsNote,
						LA.IsExternalType AS ExternalType,
						LA.CustomerName AS CustomerName,
						LA.CustomerAppId AS CustomerAppId,
						IIF(ISNULL(LA.CustomerAppId,0) IN (CONVERT(VARCHAR(1000), @lgCustomerUserId)),1,0) AS IsCustomer
                FROM    dbo.CloseLoopAction AS LA
                        INNER JOIN dbo.AppUser AS U ON LA.AppUserId = U.Id
                        INNER JOIN dbo.AnswerMaster AS Am ON Am.Id = LA.AnswerMasterId
                        INNER JOIN dbo.Establishment AS E ON E.Id = Am.EstablishmentId
						LEFT JOIN dbo.PendingNotificationWeb PNW ON pnw.RefId = @ReportId AND la.[Conversation] = pnw.[Message] 
                WHERE   LA.AnswerMasterId = @ReportId and (SELECT data FROM dbo.split(ISNULL(LA.CustomerAppId,'0'),',') WHERE data = CONVERT(VARCHAR(1000), @lgCustomerUserId)) IN (CONVERT(VARCHAR(1000), @lgCustomerUserId))
				UNION
                     SELECT  LA.Id ,
                        [Conversation] ,
                        U.Name AS UserName ,
						 U.Name AS UName ,
                        dbo.ChangeDateFormat(DATEADD(MINUTE, E.TimeOffSet,
                                                     LA.CreatedOn),
                                             'dd/MMM/yyyy hh:mm AM/PM') AS CaptureDate ,
                        CASE LA.IsReminderSet
                          WHEN 1 THEN 'Reminder'
                          ELSE ''
                        END AS ReminderSet,
						ISNULL(LA.Attachment,'')  AS Attachment,
						@path AS FilePath,
						ISNULL(PNW.IsRead,1) AS IsRead,
						ISNULL(LA.IsNote,0) AS IsNote,
						LA.IsExternalType AS ExternalType,
						LA.CustomerName AS CustomerName,
						LA.CustomerAppId AS CustomerAppId,
						IIF(ISNULL(LA.CustomerAppId,0) IN (CONVERT(VARCHAR(1000), @lgCustomerUserId)),1,0) AS IsCustomer
                FROM    dbo.CloseLoopAction AS LA
                        INNER JOIN dbo.AppUser AS U ON LA.AppUserId = U.Id
                        INNER JOIN dbo.AnswerMaster AS Am ON Am.Id = LA.AnswerMasterId
                        INNER JOIN dbo.Establishment AS E ON E.Id = Am.EstablishmentId
						LEFT JOIN dbo.PendingNotificationWeb as PNW ON PNW.RefId = @ReportId AND la.[Conversation] = pnw.[Message]
                WHERE   Am.AnswerMasterId = @ReportId and (SELECT data FROM dbo.split(ISNULL(LA.CustomerAppId,'0'),',') WHERE data = CONVERT(VARCHAR(1000), @lgCustomerUserId)) IN (CONVERT(VARCHAR(1000), @lgCustomerUserId))
					UNION
		   SELECT  LA.Id ,
                        [Conversation] ,
                        U.Name AS UserName ,
						U.Name AS UName ,
                        dbo.ChangeDateFormat(DATEADD(MINUTE, E.TimeOffSet,
                                                     LA.CreatedOn),
                                             'dd/MMM/yyyy hh:mm AM/PM') AS CaptureDate ,
                        CASE LA.IsReminderSet
                          WHEN 1 THEN 'Reminder'
                          ELSE ''
                        END AS ReminderSet,
						ISNULL(LA.Attachment,'') AS Attachment,
						@path AS FilePath,
						ISNULL(PNW.IsRead,1) AS IsRead,
						ISNULL(LA.IsNote,0) AS IsNote,
						LA.IsExternalType AS ExternalType,
						LA.CustomerName AS CustomerName,
						LA.CustomerAppId AS CustomerAppId,
						IIF(ISNULL(LA.CustomerAppId,0) IN (CONVERT(VARCHAR(1000), @lgCustomerUserId)),1,0) AS IsCustomer
						--CASE WHEN ISNULL(@lgCustomerUserId,0) > 0 THEN (CASE when (SELECT COUNT(1) FROM dbo.CloseLoopAction WHERE CustomerAppId = @lgCustomerUserId) > 1 THEN 1 ELSE 0 END)  ELSE 0 END AS  IsCustomer
		                FROM    dbo.CloseLoopAction AS LA 
                        INNER JOIN dbo.AppUser AS U ON LA.AppUserId = U.Id
                        INNER JOIN dbo.AnswerMaster AS Am ON Am.Id = LA.AnswerMasterId
                        INNER JOIN dbo.Establishment AS E ON E.Id = Am.EstablishmentId
						LEFT JOIN dbo.PendingNotificationWeb PNW ON pnw.RefId = @ReportId AND la.[Conversation] = pnw.[Message]
                WHERE   LA.AnswerMasterId = @ReportId AND LA.Conversation LIKE '%@EveryOne%'
				UNION 
				   SELECT  LA.Id ,
                        [Conversation] ,
                        U.Name AS UserName ,
						 U.Name AS UName ,
                        dbo.ChangeDateFormat(DATEADD(MINUTE, E.TimeOffSet,
                                                     LA.CreatedOn),
                                             'dd/MMM/yyyy hh:mm AM/PM') AS CaptureDate ,
                        CASE LA.IsReminderSet
                          WHEN 1 THEN 'Reminder'
                          ELSE ''
                        END AS ReminderSet,
					    ISNULL(LA.Attachment,'') AS Attachment,
						@path AS FilePath,
							ISNULL(PNW.IsRead,1) AS IsRead,
							ISNULL(LA.IsNote,0) AS IsNote,
							LA.IsExternalType AS ExternalType,
							LA.CustomerName AS CustomerName,
							LA.CustomerAppId AS CustomerAppId,
							IIF(ISNULL(LA.CustomerAppId,0) IN (CONVERT(VARCHAR(1000), @lgCustomerUserId)),1,0) AS IsCustomer
                FROM    dbo.CloseLoopAction AS LA
                        INNER JOIN dbo.AppUser AS U ON LA.AppUserId = U.Id
                        INNER JOIN dbo.AnswerMaster AS Am ON Am.Id = LA.AnswerMasterId
                        INNER JOIN dbo.Establishment AS E ON E.Id = Am.EstablishmentId
						LEFT JOIN dbo.PendingNotificationWeb PNW ON pnw.RefId = @ReportId AND la.[Conversation] = pnw.[Message]
                WHERE   LA.AnswerMasterId = @ReportId and (SELECT data FROM dbo.split(ISNULL(LA.CustomerAppId,'0'),',') WHERE data = CONVERT(VARCHAR(1000), @lgCustomerUserId)) IN (CONVERT(VARCHAR(1000), @lgCustomerUserId))
            END;
	END
    END;

