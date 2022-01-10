-- =============================================
-- Author:      Vasudev
-- Create Date: 18 Oct 2019
-- Description: diff of between two date
-- =============================================
CREATE PROCEDURE [dbo].[DifferenceDate]
(
    -- Add the parameters for the stored procedure here
    @StartDate datetime ,
    @EndDate datetime 
)
AS
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

SELECT @result= ISNULL(' ' + CAST(NULLIF(@days,0) AS VARCHAR(10)) + ':','')
     + ISNULL('' + CAST(NULLIF(@hours,0) AS VARCHAR(10)) + ':','')
     + ISNULL('' + CAST(@minutes AS VARCHAR(10)) + '','')

SELECT @result
END
