-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date, ,02 Sep 2015>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[RoundTime]
    (
      @DateTime DATETIME ,
      @TimeString NVARCHAR(20)
    )
RETURNS DATETIME
AS
    BEGIN
        DECLARE @RoundedTime SMALLDATETIME ,
            @Multiplier FLOAT ,
            @RoundTo FLOAT ,
            @Hour INT ,
            @Minutes INT;

        SELECT  @Minutes = ISNULL(CAST(Data AS INT), 0) * 60
        FROM    dbo.Split(@TimeString, ':')
        WHERE   Id = 1;
		
        SELECT  @Minutes += ISNULL(CAST(Data AS INT), 0)
        FROM    dbo.Split(@TimeString, ':')
        WHERE   Id = 2;

        DECLARE @ToDate DATETIME = DATEADD(DAY, 1, @DateTime);

        DECLARE @Tbl TABLE
            (
              IntervalDate DATETIME
            );
			--PRINT @Minutes
        IF @Minutes > 0
            BEGIN
                WHILE ( @DateTime < @ToDate )
                    BEGIN
                        SELECT  @DateTime = DATEADD(MINUTE, @Minutes,
                                                    @DateTime);
                        INSERT  INTO @Tbl
                                ( IntervalDate )
                                SELECT  @DateTime;
                    END;
            END;

        SELECT TOP 1
                @DateTime = IntervalDate
        FROM    @Tbl
        WHERE   IntervalDate > GETUTCDATE();

        RETURN @DateTime;
    END;