-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,03 Nov 2015>
-- Description:	<Description,,>
-- Call SP:		WSSearchContactForBulkSMS 4, 0, '', 1, 100
--				WSSearchContactForBulkSMS 4, 1, '', 1, 100
-- =============================================
CREATE PROCEDURE [dbo].[WSSearchContactForBulkSMS]
    @GroupId BIGINT ,
    @IsGroup BIT ,
    @Search NVARCHAR(100) ,
    @Page INT ,
    @Rows INT
AS
    BEGIN
        SET @Search = ISNULL(@Search, '');
        DECLARE @Start AS INT ,
            @End INT;
        SET @Start = ( ( @Page * @Rows ) - @Rows ) + 1;
        SET @End = @Start + @Rows - 1;
        
        DECLARE @Result TABLE
            (
              Id BIGINT NOT NULL ,
              Name NVARCHAR(MAX) ,
              IsGroup BIT NOT NULL ,
              Total INT NOT NULL ,
              RowNum INT NOT NULL
            );
        IF @IsGroup = 0
            BEGIN
                INSERT  INTO @Result
                        ( Id ,
                          Name ,
                          IsGroup ,
                          Total ,
                          RowNum
                        )
                        SELECT  T.Id ,
                                T.Name ,
                                0 ,
                                T.Total ,
                                T.RowNum
                        FROM    ( SELECT    Id ,
                                            Name ,
                                            CASE Total / @Rows
                                              WHEN 0 THEN 1
                                              ELSE ( Total / @Rows ) + 1
                                            END AS Total ,
                                            ROW_NUMBER() OVER ( ORDER BY Name ) AS RowNum
                                  FROM      ( SELECT    COUNT(*) OVER ( PARTITION BY 1 ) AS Total ,
                                                        CM.Id ,
                                                        dbo.ConcateString('ContactSummary',
                                                              CM.Id) AS Name
                                              FROM      dbo.ContactMaster AS CM
                                                        INNER JOIN dbo.ContactDetails
                                                        AS CD ON CM.Id = CD.ContactMasterId
                                                        INNER JOIN dbo.ContactQuestions
                                                        AS CQ ON CD.ContactQuestionId = CQ.Id
                                              WHERE     CD.IsDeleted = 0
                                                        AND CM.IsDeleted = 0
                                                        AND CQ.IsDeleted = 0
                                                        AND Detail LIKE '%'
                                                        + @Search + '%'
                                                        AND CM.GroupId = @GroupId
                                              GROUP BY  CM.Id
                                            ) AS R
                                ) AS T
                        WHERE   RowNum BETWEEN @Start AND @End;;
            END;
        ELSE
            IF @IsGroup = 1
                BEGIN
                    INSERT  INTO @Result
                            ( Id ,
                              Name ,
                              IsGroup ,
                              Total ,
                              RowNum
                            )
                            SELECT  Id ,
                                    ContactGropName ,
                                    1 ,
                                    CASE Total / @Rows
                                      WHEN 0 THEN 1
                                      ELSE ( Total / @Rows ) + 1
                                    END AS Total ,
                                    RowNum
                            FROM    ( SELECT    COUNT(*) OVER ( PARTITION BY 1 ) AS Total ,
                                                ROW_NUMBER() OVER ( ORDER BY ContactGropName ) AS RowNum ,
                                                Id ,
                                                ContactGropName
                                      FROM      dbo.ContactGroup
                                      WHERE     IsDeleted = 0
                                                AND ContactGropName LIKE '%'
                                                + @Search + '%'
                                                AND GroupId = @GroupId
                                    ) AS R
                            WHERE   RowNum BETWEEN @Start AND @End;
                END;
        
        SELECT  *
        FROM    @Result
        WHERE   RowNum BETWEEN @Start AND @End;;
                
    END;