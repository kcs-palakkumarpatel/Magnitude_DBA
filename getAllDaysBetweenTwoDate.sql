CREATE FUNCTION [dbo].[getAllDaysBetweenTwoDate]
    (
      @FromDate DATETIME ,
      @ToDate DATETIME
    )
RETURNS @retval TABLE ( AllDay DATE,id INT IDENTITY(1,1) )
AS
    BEGIN
        DECLARE @TOTALCount INT
        SET @FromDate = DATEADD(DAY, -1, @FromDate)
        SELECT  @TOTALCount = DATEDIFF(DD, @FromDate, @ToDate);
        WITH    d AS ( SELECT TOP ( @TOTALCount )
                                AllDays = DATEADD(DAY,
                                                  ROW_NUMBER() OVER ( ORDER BY object_id ),
                                                  REPLACE(@FromDate, '-', ''))
                       FROM     sys.all_objects
                     )
            INSERT  INTO @retval
                    SELECT  AllDays
                    FROM    d
        
        RETURN 
    END