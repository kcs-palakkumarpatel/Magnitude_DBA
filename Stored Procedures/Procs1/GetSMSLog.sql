-- =============================================
-- Author:		Vasu Patel
-- Create date: 11 May 2017
-- Description:	Email Log
-- Call: GetSMSLog '18 jun 2020','18 Jun 2020','',0,0,0 ,100,1
-- =============================================
CREATE PROCEDURE dbo.GetSMSLog 
    @FromDate DATE ,
    @ToDate DATE ,
    @Search NVARCHAR(MAX),
	@GroupId BIGINT,
	@ActivityId BIGINT,
	@EstablishmentId BIGINT,
	@Rows INT ,
    @Page INT 
AS
    BEGIN

	 DECLARE @Start AS INT ,
            @End INT ,
            @Total INT

        SET @Start = ( ( @Page - 1 ) * @Rows ) + 1
        SET @End = @Start + @Rows

	DECLARE @tempTeable TABLE
	(
				RowNum BIGINT IDENTITY(1,1),
				ProcessName NVARCHAR(50),
                MobileNo NVARCHAR(max),
                SMSText NVARCHAR(max),
                IsSent NVARCHAR(10),
                CreatedOn NVARCHAR(20),
                ScheduleDateTime NVARCHAR(20),
                SentDate NVARCHAR(20),
				RefId NVARCHAR(10),
                EstablishmentId NVARCHAR(10),
				EstablishmentName NVARCHAR(max),
                GropuId NVARCHAR(10),
				GroupName NVARCHAR(max),
                ActivityId NVARCHAR(10),
    			EstablishmentGroupName NVARCHAR(max),
				IsDelete NVARCHAR(10)
	)
	
	DECLARE @sql NVARCHAR(max)
	DECLARE @Filter AS NVARCHAR(max)
	IF(@GroupId != 0 AND @ActivityId != 0 AND @EstablishmentId != 0)
	BEGIN
	    SET @Filter = ' E.GroupId = ' + CONVERT(NVARCHAR(50), @GroupId) + ' and  E.EstablishmentGroupId = '+ CONVERT(NVARCHAR(50), @ActivityId ) + ' and ISNULL(SCAM.EstablishmentId, ISNULL(AM.EstablishmentId, 0)) = ' + CONVERT(NVARCHAR(50), @EstablishmentId);
	END
	ELSE IF(@GroupId != 0 AND @ActivityId != 0)
	BEGIN
	    SET @Filter = ' E.GroupId = ' + CONVERT(NVARCHAR(50), @GroupId ) + ' and E.EstablishmentGroupId = ' +CONVERT(NVARCHAR(50), @ActivityId);
	END
	ELSE IF (@GroupId != 0 )
	BEGIN
	    SET @Filter = ' E.GroupId = ' + CONVERT(NVARCHAR(50), @GroupId);
	END
	ELSE IF(@ActivityId != 0)
	BEGIN
	    SET @Filter = ' E.EstablishmentGroupId = ' + CONVERT(NVARCHAR(50), @ActivityId);
	END
	ELSE IF(@EstablishmentId != 0)
    BEGIN
	    SET @Filter = ' ISNULL(SCAM.EstablishmentId, ISNULL(AM.EstablishmentId, 0)) = ' + CONVERT(NVARCHAR(50), @EstablishmentId);
	END
    ELSE
    BEGIN
	SET @Filter = '1 = 1'
	END
	PRINT @Filter
        SET @sql = N'SELECT   Ps.ProcessName ,
                PE.MobileNo ,
                dbo.StripHTML(dbo.udf_StripHTML(LTRIM(RTRIM(PE.SMSText)))),
                IsSent = case IsSent when 0 then ''false'' else ''true'' end,
                dbo.ChangeDateFormat(DATEADD(MINUTE, E.TimeOffSet, PE.CreatedOn), ''dd/MMM/yyyy hh:mm AM/PM'') ,
				dbo.ChangeDateFormat(DATEADD(MINUTE, E.TimeOffSet, PE.ScheduleDateTime), ''dd/MMM/yyyy hh:mm AM/PM'') ,
				dbo.ChangeDateFormat(DATEADD(MINUTE, E.TimeOffSet, PE.SentDate), ''dd/MMM/yyyy hh:mm AM/PM'') ,
				RefId ,
                ISNULL(SCAM.EstablishmentId, ISNULL(AM.EstablishmentId, 0)) AS EstablishmentId ,
				E.EstablishmentName,
                ISNULL(E.GroupId, 0) AS GropuId ,
				G.GroupName,
                ISNULL(E.EstablishmentGroupId, 0) AS ActivityId,
				EG.EstablishmentGroupName,
				IsDeleted = case isnull(PE.IsDeleted,0) when 0 then ''false'' else ''true'' end
         FROM    dbo.PendingSMS PE
                LEFT JOIN dbo.SeenClientAnswerMaster SCAM ON ISNULL(PE.RefId,
                                                              0) = SCAM.Id
                LEFT JOIN dbo.AnswerMaster AM ON PE.RefId = AM.Id
                LEFT JOIN dbo.Establishment E ON ISNULL(SCAM.EstablishmentId,
                                                        AM.EstablishmentId) = E.Id
				LEFT JOIN dbo.ProcessStatus Ps ON PE.ModuleId = Ps.ModuleId
				LEFT JOIN dbo.[Group] G ON E.GroupId = G.Id
				LEFT JOIN dbo.EstablishmentGroup EG ON EG.Id = E.EstablishmentGroupId
        WHERE   ( PE.CreatedOn BETWEEN ''' + CONVERT(NVARCHAR(18), @FromDate,106) + ''' AND ''' + CONVERT(NVARCHAR(18), DATEADD(d, 1, @ToDate), 106) +''' )
               AND (PE.MobileNo +'' ''+ convert(NVARCHAR(50), PE.RefId) +'' ''+ PE.SMSText) LIKE ''%' + @search + '%'' 
				AND ps.ProcessId IN (3,4,8) AND '
				PRINT(@sql + @Filter)
				INSERT INTO @tempTeable
				        ( ProcessName ,
				          MobileNo ,
				          SMSText ,
				          IsSent ,
				          CreatedOn ,
				          ScheduleDateTime ,
				          SentDate ,
				          RefId ,
				          EstablishmentId ,
				          EstablishmentName ,
				          GropuId ,
				          GroupName ,
				          ActivityId ,
				          EstablishmentGroupName,
						  IsDelete
				        )
        EXECUTE(@sql + @Filter)

		SELECT @Total = COUNT(*) FROM @tempTeable
		SELECT *,ISNULL(@Total,0) AS Total FROM @tempTeable where RowNum >= CONVERT(NVARCHAR(50), @Start) AND RowNum < CONVERT(NVARCHAR(50), @End)
    END;
