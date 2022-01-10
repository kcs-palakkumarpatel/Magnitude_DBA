-- =============================================
-- Author:      Vasudev
-- Create Date: 18 Oct 2019
-- Description: diff of between two date
-- select dbo.DifferenceDatefun('28 oct 2019 15:33:040','29 oct 2019 16:25:000')
-- =============================================
CREATE FUNCTION [dbo].[DifferenceDatefun]
(
    -- Add the parameters for the stored procedure here
    @StartDate datetime ,
    @EndDate datetime 
)
RETURNS VARCHAR(100)
BEGIN
  DECLARE  @result VARCHAR(100);
 DECLARE @days INT,
    @hours INT, @minutes INT
SELECT @days=DATEDIFF(dd, @StartDate, @EndDate)
IF DATEADD(dd, -@days, @EndDate) < @StartDate 
SELECT @days=@days-1
SET @EndDate= DATEADD(dd, -@days, @EndDate)

SELECT @hours=DATEDIFF(hh, @StartDate, @EndDate)
IF DATEADD(hh, -@hours, @EndDate) < @StartDate 
SELECT @hours=@hours-1
SET @EndDate= DATEADD(hh, -@hours, @EndDate)

SELECT @minutes=DATEDIFF(mi, @StartDate, @EndDate)
IF DATEADD(mi, -@minutes, @EndDate) < @StartDate 
SELECT @minutes=@minutes-1
SET @EndDate= DATEADD(mi, -@minutes, @EndDate)

SELECT @result= 
CASE when @days=0 Then
ISNULL('000 ' + CASE WHEN @hours < 10 THEN '0' + CAST(@hours AS VARCHAR(10)) + '' ELSE CAST(NULLIF(@hours,0) AS VARCHAR(10)) END + ':' ,'00:')
     + ISNULL('' + CASE WHEN @minutes < 10 THEN '0' + CAST(@minutes AS VARCHAR(10)) + '' ELSE CAST(@minutes AS VARCHAR(10)) end  + '','00')
ELSE
ISNULL('' + CASE WHEN @days < 10 THEN '00' + CAST(@days AS VARCHAR(10)) + '' ELSE CASE WHEN @days < 100 THEN '0' + CAST(@days AS VARCHAR(10)) + ''  ELSE CAST(NULLIF(@days,0) AS VARCHAR(10))  END END + ' ','000 ')
     + ISNULL('' + CASE WHEN @hours < 10 THEN '0' + CAST(@hours AS VARCHAR(10)) + '' ELSE CAST(NULLIF(@hours,0) AS VARCHAR(10)) END + ':' ,'00:')
     + ISNULL('' + CASE WHEN @minutes < 10 THEN '0' + CAST(@minutes AS VARCHAR(10)) + '' ELSE CAST(@minutes AS VARCHAR(10)) end + '' ,'00')
END
RETURN @result
END