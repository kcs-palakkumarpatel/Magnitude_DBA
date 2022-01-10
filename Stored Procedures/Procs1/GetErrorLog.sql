-- =============================================
-- Author:		<Vasu Patel>
-- Create date: <13 May 2017>
-- Description:	<Error Log>
-- Call: GetErrorLog '01 jan 2015','10 Jun 2016','',1,50
-- =============================================
CREATE PROCEDURE [dbo].[GetErrorLog]
    @FromDate DATE ,
    @ToDate DATE ,
    @Search NVARCHAR(MAX) ,
    @Rows INT ,
    @Page INT
AS
    BEGIN

        DECLARE @Start AS INT ,
            @End INT ,
            @Total INT ,
            @sql NVARCHAR(MAX);

        SET @Start = ( ( @Page - 1 ) * @Rows ) + 1;
        SET @End = @Start + @Rows;

        DECLARE @TempTable TABLE
            (
              Rownum BIGINT IDENTITY(1, 1) ,
              MethodName NVARCHAR(200) ,
              ErrorType NVARCHAR(200) ,
              ErrorMessage NVARCHAR(MAX) ,
              ErrorDetails NVARCHAR(MAX) ,
              ErrorDate NVARCHAR(20) ,
              CreatedOn NVARCHAR(20)
            );

        SELECT  @sql = N'SELECT  MethodName ,
        ErrorType ,
        ErrorMessage ,
        ErrorDetails ,
		dbo.ChangeDateFormat(ErrorDate, ''dd/MMM/yyyy hh:mm AM/PM''),
		dbo.ChangeDateFormat(CreatedOn, ''dd/MMM/yyyy hh:mm AM/PM'')
FROM    dbo.ErrorLog
WHERE   ( ErrorDate BETWEEN ''' + CONVERT(NVARCHAR(18), @FromDate, 106)
                + ''' AND ''' + CONVERT(NVARCHAR(18), @ToDate, 106) + ''' )
        AND ( ErrorMessage + '' '' + ErrorDetails + '' '' ) LIKE ''%'
                + @Search + '%''
        AND ( MethodName LIKE ''%SendEmail%''
              OR MethodName LIKE ''%SendPending%''
            );';

        INSERT  INTO @TempTable
                ( MethodName ,
                  ErrorType ,
                  ErrorMessage ,
                  ErrorDetails ,
                  ErrorDate ,
                  CreatedOn
			    )
                EXECUTE ( @sql );
        SELECT  @Total = COUNT(*)
        FROM    @TempTable;

        SELECT  * ,
                ISNULL(@Total, 0) AS Total
        FROM    @TempTable
        WHERE   Rownum >= CONVERT(NVARCHAR(50), @Start)
                AND Rownum < CONVERT(NVARCHAR(50), @End);
    END;
