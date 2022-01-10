-- =============================================
-- Author:		Vasu Patel
-- Create date: 11 May 2017
-- Description:	Email Log
-- Call: GetEmailLog '01-Feb-2020 00:00:00','29-Sep-2020 00:00:00','',70,429,23246,100,1
-- =============================================
CREATE PROCEDURE dbo.GetEmailLog
    @FromDate DATE,
    @ToDate DATE,
    @Search NVARCHAR(MAX),
    @GroupId BIGINT,
    @ActivityId BIGINT,
    @EstablishmentId BIGINT,
    @Rows INT,
    @Page INT


AS
BEGIN
    --SET @FromDate ='01-Feb-2020 00:00:00';
    --SET @ToDate ='29-Sep-2020 00:00:00';
    --SET @Search ='';
    --SET @GroupId =70;
    --SET @ActivityId =429;
    --SET @EstablishmentId =23246;
    --SET @Rows =100;
    --SET @Page =1;
    DECLARE @Start AS INT,
            @End INT,
            @Total INT;

    SET @Start = ((@Page - 1) * @Rows) + 1;
    SET @End = @Start + @Rows;


    DECLARE @tempTeable TABLE
    (
        RowNum BIGINT IDENTITY(1, 1),
        ProcessName NVARCHAR(50),
        EmailId NVARCHAR(MAX),
        ReplyTo NVARCHAR(MAX),
        EmailText NVARCHAR(MAX),
        IsSent NVARCHAR(10),
        CreatedOn NVARCHAR(20),
        ScheduleDateTime NVARCHAR(20),
        SentDate NVARCHAR(20),
        RefId NVARCHAR(10),
        EstablishmentId NVARCHAR(10),
        EstablishmentName NVARCHAR(MAX),
        GropuId NVARCHAR(10),
        GroupName NVARCHAR(MAX),
        ActivityId NVARCHAR(10),
        EstablishmentGroupName NVARCHAR(MAX),
        IsDelete NVARCHAR(10),
        COUNTER NVARCHAR(4)
    );

    DECLARE @tempTeable1 TABLE
    (
        ProcessName NVARCHAR(50),
        EmailId NVARCHAR(MAX),
        ReplyTo NVARCHAR(MAX),
        EmailText NVARCHAR(MAX),
        IsSent NVARCHAR(10),
        CreatedOn NVARCHAR(20),
        ScheduleDateTime NVARCHAR(20),
        SentDate NVARCHAR(20),
        RefId NVARCHAR(10),
        EstablishmentId NVARCHAR(10),
        EstablishmentName NVARCHAR(MAX),
        GropuId NVARCHAR(10),
        GroupName NVARCHAR(MAX),
        ActivityId NVARCHAR(10),
        EstablishmentGroupName NVARCHAR(MAX),
        IsDelete NVARCHAR(10),
        Counter NVARCHAR(4)
    );

    DECLARE @sql NVARCHAR(MAX);
    DECLARE @Sql1 NVARCHAR(MAX);
	 DECLARE @Sql2 NVARCHAR(MAX);
    DECLARE @Filter AS NVARCHAR(MAX);

    IF (@GroupId != 0 AND @ActivityId != 0 AND @EstablishmentId != 0)
    BEGIN
        SET @Filter
            = ' E.GroupId = ' + CONVERT(NVARCHAR(50), @GroupId) + ' and  E.EstablishmentGroupId = '
              + CONVERT(NVARCHAR(50), @ActivityId)
              + ' and SCAM.EstablishmentId = '
              + CONVERT(NVARCHAR(50), @EstablishmentId);
    END;
    ELSE IF (@GroupId != 0 AND @ActivityId != 0)
    BEGIN
        SET @Filter
            = ' E.GroupId = ' + CONVERT(NVARCHAR(50), @GroupId) + ' and E.EstablishmentGroupId = '
              + CONVERT(NVARCHAR(50), @ActivityId);
    END;
    ELSE IF (@GroupId != 0)
    BEGIN
        SET @Filter = ' E.GroupId = ' + CONVERT(NVARCHAR(50), @GroupId);
    END;
    ELSE IF (@ActivityId != 0)
    BEGIN
        SET @Filter = ' E.EstablishmentGroupId = ' + CONVERT(NVARCHAR(50), @ActivityId);
    END;
    ELSE IF (@EstablishmentId != 0)
    BEGIN
        SET @Filter
            = ' SCAM.EstablishmentId = '
              + CONVERT(NVARCHAR(50), @EstablishmentId);
    END;
    ELSE
    BEGIN
        SET @Filter = '1 = 1';
    END;

    DECLARE @Filter1 AS NVARCHAR(MAX);
    IF (@GroupId != 0 AND @ActivityId != 0 AND @EstablishmentId != 0)
    BEGIN
        SET @Filter1
            = 'AND E.GroupId = ' + CONVERT(NVARCHAR(50), @GroupId) + ' and  E.EstablishmentGroupId = '
              + CONVERT(NVARCHAR(50), @ActivityId) + 'and E.Id = '
              + CONVERT(NVARCHAR(50), @EstablishmentId); ;
    END;
    ELSE IF (@GroupId != 0 AND @ActivityId != 0)
    BEGIN
        SET @Filter1
            = 'AND E.GroupId = ' + CONVERT(NVARCHAR(50), @GroupId) + ' and E.EstablishmentGroupId = '
              + CONVERT(NVARCHAR(50), @ActivityId);
    END;
    ELSE IF (@GroupId != 0)
    BEGIN
        SET @Filter1 = 'AND E.GroupId = ' + CONVERT(NVARCHAR(50), @GroupId);
    END;
    ELSE IF (@ActivityId != 0)
    BEGIN
        SET @Filter1 = 'AND E.EstablishmentGroupId = ' + CONVERT(NVARCHAR(50), @ActivityId);
    END;
    ELSE IF (@EstablishmentId != 0)
    BEGIN
        SET @Filter1 = 'AND E.Id = ' + CONVERT(NVARCHAR(50), @EstablishmentId);
    END;
    ELSE
    BEGIN
        SET @Filter = '1 = 1';
    END;

    SET @sql
        = N'SELECT Ps.ProcessName ,
                EmailId ,
                ReplyTo ,
                dbo.StripHTML(dbo.udf_StripHTML(LTRIM(RTRIM(EmailText)))),
				IsSent = case isnull(IsSent,0) when 0 then ''false'' else ''true'' end,
			    dbo.ChangeDateFormat(DATEADD(MINUTE, E.TimeOffSet, PE.CreatedOn), ''dd/MMM/yyyy hh:mm AM/PM'') AS CreatedOn,
				dbo.ChangeDateFormat(DATEADD(MINUTE, E.TimeOffSet, ScheduleDateTime), ''dd/MMM/yyyy hh:mm AM/PM'') As ScheduleDateTime ,
				dbo.ChangeDateFormat(DATEADD(MINUTE, E.TimeOffSet, SentDate), ''dd/MMM/yyyy hh:mm AM/PM'') as SentDate,
				RefId ,
                SCAM.EstablishmentId AS EstablishmentId ,
				E.EstablishmentName,
                ISNULL(E.GroupId, 0) AS GropuId ,
				G.GroupName,
                ISNULL(E.EstablishmentGroupId, 0) AS ActivityId,
				EG.EstablishmentGroupName,
				IsDeleted = case isnull(PE.IsDeleted,0) when 0 then ''false'' else ''true'' end,
				PE.Counter AS [Counter]
         FROM    dbo.PendingEmail PE
                LEFT JOIN dbo.SeenClientAnswerMaster SCAM ON PE.RefId = SCAM.Id
                LEFT JOIN dbo.Establishment E ON SCAM.EstablishmentId = E.Id
				LEFT JOIN dbo.ProcessStatus Ps ON PE.ModuleId = Ps.ModuleId
				LEFT JOIN dbo.[Group] G ON E.GroupId = G.Id
				LEFT JOIN dbo.EstablishmentGroup EG ON EG.Id = E.EstablishmentGroupId
        WHERE   ( PE.CreatedOn BETWEEN ''' + CONVERT(NVARCHAR(18), @FromDate, 106) + ''' AND '''
          + CONVERT(NVARCHAR(18), DATEADD(d, 1, @ToDate), 106)
          + ''' )
                AND (PE.EmailId +'' ''+ convert(NVARCHAR(50), PE.RefId) +'' ''+ PE.EmailText) LIKE ''%' + @Search
          + '%'' 
				AND ps.ProcessId IN (1,7) AND
			';
    SET @sql2
        = N'Union
		        SELECT Ps.ProcessName ,
                EmailId ,
                ReplyTo ,
                dbo.StripHTML(dbo.udf_StripHTML(LTRIM(RTRIM(EmailText)))),
				IsSent = case isnull(IsSent,0) when 0 then ''false'' else ''true'' end,
			    dbo.ChangeDateFormat(DATEADD(MINUTE, E.TimeOffSet, PE.CreatedOn), ''dd/MMM/yyyy hh:mm AM/PM'') AS CreatedOn,
				dbo.ChangeDateFormat(DATEADD(MINUTE, E.TimeOffSet, ScheduleDateTime), ''dd/MMM/yyyy hh:mm AM/PM'') As ScheduleDateTime ,
				dbo.ChangeDateFormat(DATEADD(MINUTE, E.TimeOffSet, SentDate), ''dd/MMM/yyyy hh:mm AM/PM'') as SentDate,
				RefId ,
                SCAM.EstablishmentId AS EstablishmentId ,
				E.EstablishmentName,
                ISNULL(E.GroupId, 0) AS GropuId ,
				G.GroupName,
                ISNULL(E.EstablishmentGroupId, 0) AS ActivityId,
				EG.EstablishmentGroupName,
				IsDeleted = case isnull(PE.IsDeleted,0) when 0 then ''false'' else ''true'' end,
				PE.Counter AS [Counter]
         FROM    dbo.PendingEmail PE
                LEFT JOIN dbo.AnswerMaster SCAM ON PE.RefId = SCAM.Id
                LEFT JOIN dbo.Establishment E ON SCAM.EstablishmentId = E.Id
				LEFT JOIN dbo.ProcessStatus Ps ON PE.ModuleId = Ps.ModuleId
				LEFT JOIN dbo.[Group] G ON E.GroupId = G.Id
				LEFT JOIN dbo.EstablishmentGroup EG ON EG.Id = E.EstablishmentGroupId
        WHERE   ( PE.CreatedOn BETWEEN ''' + CONVERT(NVARCHAR(18), @FromDate, 106) + ''' AND '''
          + CONVERT(NVARCHAR(18), DATEADD(d, 1, @ToDate), 106)
          + ''' )
                AND (PE.EmailId +'' ''+ convert(NVARCHAR(50), PE.RefId) +'' ''+ PE.EmailText) LIKE ''%' + @Search
          + '%'' 
				AND ps.ProcessId IN (2) AND
			';
    SELECT @Sql1
        = N' Union All
				SELECT   ''Auto Report Scheduler'' ProcessName ,
                EmailId ,
                '''' AS ReplyTo ,
                ''Auto Report Scheduler'' AS EmailText ,
				IsSent = case isnull(PE.IsExecuted,0) when 0 then ''false'' else ''true'' end,
                 dbo.ChangeDateFormat(DATEADD(MINUTE, E.TimeOffSet, PE.CreatedOn), ''dd/MMM/yyyy hh:mm AM/PM'') AS CreatedOn,
				dbo.ChangeDateFormat(DATEADD(MINUTE, E.TimeOffSet, PE.ScheduleDate), ''dd/MMM/yyyy hh:mm AM/PM'') As ScheduleDateTime ,
				dbo.ChangeDateFormat(DATEADD(MINUTE, E.TimeOffSet, PE.ScheduleDate), ''dd/MMM/yyyy hh:mm AM/PM'') as SentDate,
                --PE.ScheduleDate AS ScheduleDateTime ,
                --PE.ExecutedOn,
				0 as RefId ,
                ISNULL(E.Id, 0) AS EstablishmentId ,
				E.EstablishmentName,
                ISNULL(E.GroupId, 0) AS GropuId ,
				G.GroupName,
                ISNULL(E.EstablishmentGroupId, 0) AS ActivityId,
				EG.EstablishmentGroupName,
				IsDeleted = case isnull(PE.IsDeleted,0) when 0 then ''false'' else ''true'' end,
				0 AS [Counter]
         FROM    dbo.PendingAutoReportingScheduler PE
				LEFT JOIN dbo.EstablishmentGroup EG ON EG.Id = PE.EstablishmentGroupId
                LEFT JOIN dbo.Establishment E ON e.EstablishmentGroupId = eg.Id
				--LEFT JOIN dbo.ProcessStatus Ps ON PE.ModuleId = Ps.ModuleId
				LEFT JOIN dbo.[Group] G ON E.GroupId = G.Id
        WHERE   ( PE.CreatedOn BETWEEN ''' + CONVERT(NVARCHAR(18), @FromDate, 106) + ''' AND '''
          + CONVERT(NVARCHAR(18), DATEADD(d, 1, @ToDate), 106) + ''' )
                AND PE.EmailId LIKE ''%' + @Search
          + '%''';

    PRINT @sql;
    PRINT @Filter;
	PRINT @sql2;
    PRINT @Filter;
    PRINT @Sql1;
	PRINT @Filter1
    INSERT INTO @tempTeable1
    (
        ProcessName,
        EmailId,
        ReplyTo,
        EmailText,
        IsSent,
        CreatedOn,
        ScheduleDateTime,
        SentDate,
        RefId,
        EstablishmentId,
        EstablishmentName,
        GropuId,
        GroupName,
        ActivityId,
        EstablishmentGroupName,
        IsDelete,
        Counter
    )
    EXECUTE (@sql + @Filter + @sql2 + @Filter + @Sql1 + @Filter1);

    INSERT INTO @tempTeable
    (
        ProcessName,
        EmailId,
        ReplyTo,
        EmailText,
        IsSent,
        CreatedOn,
        ScheduleDateTime,
        SentDate,
        RefId,
        EstablishmentId,
        EstablishmentName,
        GropuId,
        GroupName,
        ActivityId,
        EstablishmentGroupName,
        IsDelete,
        Counter
    )
    SELECT ProcessName,
           EmailId,
           ReplyTo,
           EmailText,
           IsSent,
           CreatedOn,
           ScheduleDateTime,
           SentDate,
           RefId,
           EstablishmentId,
           EstablishmentName,
           GropuId,
           GroupName,
           ActivityId,
           EstablishmentGroupName,
           IsDelete,
           Counter
    FROM @tempTeable1
    ORDER BY ISNULL(SentDate, '01 Jan 1900') DESC,
             ScheduleDateTime DESC;

    SELECT @Total = COUNT(*)
    FROM @tempTeable;
    SELECT *,
           ISNULL(@Total, 0) AS Total
    FROM @tempTeable
    WHERE RowNum >= CONVERT(NVARCHAR(50), @Start)
          AND RowNum < CONVERT(NVARCHAR(50), @End);
END;
