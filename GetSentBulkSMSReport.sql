-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,04 Nov 2015>
-- Description:	<Description,,>
-- Call SP:		GetSentBulkSMSReport 3, '', 'CaptureDate DESC', 1, 100, 1
-- =============================================
CREATE PROCEDURE [dbo].[GetSentBulkSMSReport]
    @ActivityId BIGINT ,
    @Search NVARCHAR(100) ,
    @Sort NVARCHAR(50) ,
    @Page INT ,
    @Rows INT ,
    @AppUserId BIGINT
AS
    BEGIN
        SET @Search = ISNULL(@Search, '');
        DECLARE @Start AS INT ,
            @End INT;
        SET @Start = ( ( @Page * @Rows ) - @Rows ) + 1;
        SET @End = @Start + @Rows - 1;

        SELECT  *
        FROM    ( SELECT    Id ,
                            Contact ,
                            SMSText ,
                            MobileNo ,
                            IsSent ,
                            SMSSentDate ,
                            CaptureDate ,
                            UserName ,
                            CASE Total / @Rows
                              WHEN 0 THEN 1
                              ELSE ( Total / @Rows ) + 1
                            END AS Total ,
                            ROW_NUMBER() OVER ( ORDER BY CASE WHEN @Sort = 'Contact Asc'
                                                              THEN Contact
                                                         END ASC, CASE
                                                              WHEN @Sort = 'Contact DESC'
                                                              THEN Contact
                                                              END DESC, CASE
                                                              WHEN @Sort = 'SMSText Asc'
                                                              THEN SMSText
                                                              END ASC, CASE
                                                              WHEN @Sort = 'SMSText DESC'
                                                              THEN SMSText
                                                              END DESC, CASE
                                                              WHEN @Sort = 'MobileNo Asc'
                                                              THEN MobileNo
                                                              END ASC, CASE
                                                              WHEN @Sort = 'MobileNo DESC'
                                                              THEN MobileNo
                                                              END DESC, CASE
                                                              WHEN @Sort = 'IsSent Asc'
                                                              THEN IsSent
                                                              END ASC, CASE
                                                              WHEN @Sort = 'IsSent DESC'
                                                              THEN IsSent
                                                              END DESC, CASE
                                                              WHEN @Sort = 'SMSSentDate Asc'
                                                              THEN SentDate
                                                              END ASC, CASE
                                                              WHEN @Sort = 'SMSSentDate DESC'
                                                              THEN SentDate
                                                              END DESC, CASE
                                                              WHEN @Sort = 'CaptureDate Asc'
                                                              THEN CreatedOn
                                                              END ASC, CASE
                                                              WHEN @Sort = 'CaptureDate DESC'
                                                              THEN CreatedOn
                                                              END DESC, CASE
                                                              WHEN @Sort = 'UserName Asc'
                                                              THEN UserName
                                                              END ASC, CASE
                                                              WHEN @Sort = 'UserName DESC'
                                                              THEN UserName
                                                              END DESC ) AS RowNum
                  FROM      ( SELECT    PS.Id ,
                                        CASE PS.RefId1
                                          WHEN 0 THEN 'N/A'
                                          ELSE dbo.ConcateString('ContactSummary',
                                                              PS.RefId1)
                                        END AS Contact ,
                                        PS.SMSText ,
                                        PS.MobileNo ,
                                        PS.IsSent ,
                                        dbo.ChangeDateFormat(DATEADD(MINUTE, ES.TimeOffSet, PS.SentDate), 'dd/MMM/yyyy hh:mm AM/PM') AS SMSSentDate ,
                                        dbo.ChangeDateFormat(DATEADD(MINUTE, ES.TimeOffSet, PS.CreatedOn), 'dd/MMM/yyyy hh:mm AM/PM') AS CaptureDate ,
                                        U.Name AS UserName ,
                                        PS.CreatedOn ,
                                        PS.SentDate ,
                                        COUNT(*) OVER ( PARTITION BY 1 ) AS Total
                              FROM      dbo.PendingSMS AS PS
                                        INNER JOIN dbo.AppUser AS U ON U.Id = PS.CreatedBy
                                        INNER JOIN dbo.Establishment AS ES ON ES.Id = PS.RefId
                                        LEFT OUTER JOIN dbo.ContactDetails AS Cd ON Cd.ContactMasterId = PS.RefId1
                              WHERE     ModuleId = 9
                                        AND PS.IsDeleted = 0
                                        AND PS.RefId = @ActivityId
                                        AND ( Detail LIKE '%' + @Search + '%'
                                              OR PS.SMSText LIKE '%' + @Search
                                              + '%'
                                              OR PS.MobileNo LIKE '%'
                                              + @Search + '%'
                                              OR U.Name LIKE '%' + @Search
                                              + '%'
                                              OR dbo.ChangeDateFormat(PS.SentDate,
                                                              'dd/MMM/yyyy') LIKE '%'
                                              + @Search + '%'
                                              OR dbo.ChangeDateFormat(PS.CreatedOn,
                                                              'dd/MMM/yyyy') LIKE '%'
                                              + @Search + '%'
                                            )
                              GROUP BY  PS.Id ,
                                        PS.RefId1 ,
                                        PS.SMSText ,
                                        PS.MobileNo ,
                                        PS.IsSent ,
										ES.TimeOffSet,
                                        PS.SentDate ,
                                        PS.CreatedOn ,
                                        U.Name
                            ) AS R
                ) AS T
        WHERE   RowNum BETWEEN @Start AND @End;;
    END;
