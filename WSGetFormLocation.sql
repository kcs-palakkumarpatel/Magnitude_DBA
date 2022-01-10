-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,, Jul 2015>
-- Description:	<Description,,>
-- Call SP:		WSGetFormLocation '0', '0', 1959, 0, 100, 1, 'BEK', '', '26 Sep 2016', '26 Sep 2016', 'All', 1
-- =============================================
CREATE PROCEDURE [dbo].[WSGetFormLocation]
    @EstablishmentId NVARCHAR(MAX) ,
    @UserId NVARCHAR(MAX) ,
    @ActivityId BIGINT ,
    @Period INT ,
    @Rows INT ,
    @Page INT ,
    @Search NVARCHAR(100) ,
    @Status NVARCHAR(50) ,
    @FromDate DATETIME ,
    @ToDate DATETIME ,
    @FilterOn NVARCHAR(50) ,
    @ForMobile BIT
AS
    BEGIN
		--DECLARE @FilterOn NVARCHAR(50)
        IF @ForMobile = 1
            BEGIN
                SET @Rows = 100;
            END;
        DECLARE @AnsStatus NVARCHAR(50) = '' ,
            @TranferFilter BIT = 0 ,
            @ActionFilter BIT = 0 ,
            @InOutFilter BIT = 0 ,
            @IsOut BIT = 1;

        IF @Status IS NULL
            BEGIN
                SET @Status = '';
            END;
        IF @Search IS NULL
            BEGIN
                SET @Search = '';
            END;
        IF @Status = 'Unresolved'
            BEGIN
                SET @AnsStatus = @Status;
                SET @Status = '';
            END;
        
        IF @AnsStatus = 'Unresolved'
            AND @FilterOn = 'Resolved'
            BEGIN
                SET @AnsStatus = 'None';
                SET @FilterOn = 'None';
            END;
            
        IF @FilterOn = 'Resolved'
            BEGIN
                SET @AnsStatus = @FilterOn;
            END;
        ELSE
            IF @FilterOn = 'Transferred'
                BEGIN
                    SET @TranferFilter = 1;
                END;
            ELSE
                IF @FilterOn = 'Actioned'
                    BEGIN
                        SET @ActionFilter = 1;
                    END;
                ELSE
                    IF @FilterOn = 'In'
                        BEGIN
                            SET @InOutFilter = 1;
                            SET @IsOut = 0;
                        END;
                    ELSE
                        IF @FilterOn = 'Out'
                            BEGIN
                                SET @InOutFilter = 1;
                                SET @IsOut = 1;
                            END;
							          
        DECLARE @Start AS INT ,
            @End INT;
        SET @Start = ( ( @Page * @Rows ) - @Rows ) + 1;
        SET @End = @Start + @Rows - 1;

        
        DECLARE @Establishment TABLE
            (
              EstablishemtnId BIGINT
            );
        INSERT  INTO @Establishment
                ( EstablishemtnId 
                )
                SELECT  Data
                FROM    dbo.Split(@EstablishmentId, ',')
                WHERE   Data <> '';

        DECLARE @AppUser TABLE ( AppUserId BIGINT );
        INSERT  INTO @AppUser
                ( AppUserId 
                )
                SELECT  Data
                FROM    dbo.Split(@UserId, ',')
                WHERE   Data <> '';
        SELECT  * ,
                CASE Total / @Rows
                  WHEN 0 THEN 1
                  ELSE ( Total / @Rows ) + 1
                END AS TotalPage ,
                dbo.ChangeDateFormat(CreatedOn, 'MM/dd/yyyy hh:mm AM/PM') AS CaptureDate
        FROM    ( SELECT    A.Latitude ,
                            A.Longitude ,
                            A.ReportId ,
                            A.FormType ,
                            A.CreatedOn ,
                            COUNT(*) OVER ( PARTITION BY 1 ) AS Total ,
                            ROW_NUMBER() OVER ( ORDER BY A.CreatedOn DESC ) AS RowNum
                  FROM      dbo.View_AllAnswerMaster AS A
                            INNER JOIN @Establishment AS E ON A.EstablishmentId = E.EstablishemtnId
                                                              OR @EstablishmentId = '0'
                            INNER JOIN @AppUser AS U ON U.AppUserId = A.UserId
                                                        OR @UserId = '0'
                            LEFT OUTER JOIN dbo.Answers AS Ans ON Ans.AnswerMasterId = A.ReportId
                                                              AND A.IsOut = 0
                            LEFT OUTER JOIN dbo.SeenClientAnswers AS SeenAns ON SeenAns.SeenClientAnswerMasterId = A.ReportId
                                                              AND A.IsOut = 1
                  WHERE     CAST(A.CreatedOn AS DATE) BETWEEN CAST(@FromDate AS DATE)
                                                      AND     CAST(@ToDate AS DATE)
                            AND A.ActivityId = @ActivityId
                            AND ( SmileType = @Status
                                  OR @Status = ''
                                )
                            AND ( AnswerStatus = @AnsStatus
                                  OR @AnsStatus = ''
                                )
          --                  AND ( A.EstablishmentName LIKE '%' + @Search + '%'
          --                        OR A.EI LIKE '%' + @Search + '%'
          --                        OR A.UserName LIKE '%' + @Search + '%'
          --                        OR A.SenderCellNo LIKE '%' + @Search + '%'
          --                        OR dbo.ChangeDateFormat(A.CreatedOn,
          --                                                'MM/dd/yyyy hh:mm AM/PM') LIKE '%'
          --                        + @Search + '%'
								  --OR Ans.Detail LIKE '%'+ @Search +'%'
          --                        --OR A.DisplayText LIKE '%' + @Search + '%'
          --                      )
		    AND (REPLACE(STR(ReportId , 10), SPACE(1), '0') like '%' + @search + '%' OR A.EstablishmentName LIKE '%' + @Search + '%'
                                  OR A.EI LIKE '%' + @Search + '%'
                                  OR A.UserName LIKE '%' + @Search + '%'
                                  OR A.SenderCellNo LIKE '%' + @Search + '%'
                                  OR dbo.ChangeDateFormat(A.CreatedOn,
                                                          'MM/dd/yyyy hh:mm AM/PM') LIKE '%'
                                  + @Search + '%'
                                  OR ISNULL(Ans.Detail, '') LIKE '%' + @Search
                                  + '%'
                                  OR ISNULL(SeenAns.Detail, '') LIKE '%'
                                  + @Search + '%'
                                )
                            AND ( @TranferFilter = 0
                                  OR IsTransferred = 1
                                )
                            AND ( @ActionFilter = 0
                                  OR A.IsActioned = 1
                                )
                            AND ( @InOutFilter = 0
                                  OR IsOut = @IsOut
                                )
                  GROUP BY  A.Latitude ,
                            A.Longitude ,
                            A.ReportId ,
                            A.FormType ,
                            A.CreatedOn
                ) AS R
        WHERE   R.RowNum BETWEEN @Start AND @End;
    END;