-- =============================================
-- Author:		GD
-- Create date: 10 Sep 2015
-- Description:	
-- Call SP:		spGetOverAllPosition 2, '1,3,7,8,11', '01 Jan 2015', '10 Sep 2015', 0
-- =============================================
CREATE PROCEDURE [dbo].[spGetOverAllPosition]
    @EstablishmentId BIGINT ,
    @GroupId NVARCHAR(MAX) ,
    @FromDate DATETIME ,
    @ToDate DATETIME ,
    @IsOut BIT
AS
    BEGIN
        DECLARE @MaxPosition INT;
        SET @GroupId += ',' + CONVERT(NVARCHAR(10), @EstablishmentId);
        DECLARE @Result TABLE
            (
              EstablishmentId BIGINT ,
              EstablishmentName NVARCHAR(500) ,
              Position INT
            );
        IF @IsOut = 1
            BEGIN
                INSERT  INTO @Result
                        ( EstablishmentId ,
                          EstablishmentName ,
                          Position
			            )
                        SELECT  R.EstablishmentId ,
                                R.EstablishmentName ,
                                ROW_NUMBER() OVER ( ORDER BY [R].[Count] DESC ) AS [Rank]
                        FROM    ( SELECT    Am.EstablishmentId ,
                                            Est.EstablishmentName ,
                                            SUM(EI) * 1.0 / COUNT(1) AS [Count]
                                  FROM      dbo.SeenClientAnswerMaster AS Am
                                            INNER JOIN dbo.Establishment AS Est ON Est.Id = Am.EstablishmentId
                                            INNER JOIN ( SELECT
                                                              Data
                                                         FROM dbo.Split(@GroupId,
                                                              ',')
                                                       ) AS E ON E.Data = Am.EstablishmentId
                                  WHERE     Am.IsDeleted = 0
                                            AND CAST(DATEADD(MINUTE,
                                                             Am.TimeOffSet,
                                                             Am.CreatedOn) AS DATE) BETWEEN @FromDate
                                                              AND
                                                              @ToDate
                                  GROUP BY  Am.EstablishmentId ,
                                            Est.EstablishmentName
                                ) AS R;
            END;
        ELSE
            BEGIN
                INSERT  INTO @Result
                        ( EstablishmentId ,
                          EstablishmentName ,
                          Position
			            )
                        SELECT  R.EstablishmentId ,
                                R.EstablishmentName ,
                                ROW_NUMBER() OVER ( ORDER BY [R].[Count] DESC ) AS [Rank]
                        FROM    ( SELECT    Am.EstablishmentId ,
                                            Est.EstablishmentName ,
                                            SUM(EI) * 1.0 / COUNT(1) AS [Count]
                                  FROM      dbo.AnswerMaster AS Am
                                            INNER JOIN dbo.Establishment AS Est ON Est.Id = Am.EstablishmentId
                                            INNER JOIN ( SELECT
                                                              Data
                                                         FROM dbo.Split(@GroupId,
                                                              ',')
                                                       ) AS E ON E.Data = Am.EstablishmentId
                                  WHERE     Am.IsDeleted = 0
                                            AND CAST(DATEADD(MINUTE,
                                                             Am.TimeOffSet,
                                                             Am.CreatedOn) AS DATE) BETWEEN @FromDate
                                                              AND
                                                              @ToDate
                                  GROUP BY  Am.EstablishmentId ,
                                            Est.EstablishmentName
                                ) AS R;
            END;

        UPDATE  @Result
        SET     EstablishmentName = 'Your'
        WHERE   EstablishmentId = @EstablishmentId;

        SELECT  @MaxPosition = MAX(Position)
        FROM    @Result;

        SELECT  * ,
                @MaxPosition + 1 - Position AS [Rank]
        FROM    @Result
        ORDER BY Position;
    END;