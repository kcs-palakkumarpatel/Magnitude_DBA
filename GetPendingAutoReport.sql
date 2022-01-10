
-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,29 Oct 2015>
-- Description:	<Description,,>
-- Call SP:		GetPendingAutoReport
-- =============================================
CREATE PROCEDURE [dbo].[GetPendingAutoReport]
AS
    BEGIN
		SET DEADLOCK_PRIORITY NORMAL;
	
		BEGIN TRY
        DECLARE @Url NVARCHAR(150);

        SELECT  @Url = KeyValue
        FROM    dbo.AAAAConfigSettings
        WHERE   KeyName = 'DocViewerRootFolderPathCMS';

        SELECT  PARS.Id ,
                Eg.AutoReportSchedulerId ,
                PARS.FromDate ,
                PARS.ToDate ,
                Eg.EstablishmentGroupName ,
                Eg.EstablishmentGroupType ,
                Eg.QuestionnaireId ,
                ISNULL(Eg.SeenClientId, 1) AS SeenClientId ,
                PARS.EmailId ,
                ARS.FreqTypeId ,
                CASE ARS.FreqTypeId
                  WHEN 1 THEN 'Daily'
                  WHEN 2 THEN 'Weekly'
                  WHEN 3 THEN 'Monthly'
                END + ' report of ' + CASE Eg.EstablishmentGroupType
                                        WHEN 'customer' THEN 'IN'
                                        ELSE 'IN and OUT'
                                      END + ' for '
                + Eg.EstablishmentGroupName AS EmailSubject ,
                @Url AS Url,
				GroupName
        FROM    dbo.PendingAutoReportingScheduler AS PARS
                INNER JOIN dbo.EstablishmentGroup AS Eg ON Eg.Id = PARS.EstablishmentGroupId
                INNER JOIN dbo.AutoReportScheduler AS ARS ON ARS.Id = Eg.AutoReportSchedulerId
				INNER JOIN [dbo].[Group] ON [Group].Id = Eg.GroupId
        WHERE   ScheduleDate <= GETUTCDATE()
                AND IsExecuted = 0
                --AND E.IsDeleted = 0
                AND PARS.EmailId <> ''
                AND PARS.EmailId IS NOT NULL;
   END TRY

BEGIN CATCH
	INSERT INTO dbo.ErrorLog
        (
            PageId,
            MethodName,
            ErrorType,
            ErrorMessage,
            ErrorDetails,
            ErrorDate,
            UserId,
            Solution,
            CreatedOn,
            CreatedBy
        )
        VALUES
        (ERROR_LINE(),
         'dbo.GetPendingAutoReport',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         N'',
         N'',
         GETUTCDATE(),
         N''
        );
END CATCH
   END;
