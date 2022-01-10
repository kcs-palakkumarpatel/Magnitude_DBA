-- =============================================
-- Author:		<Disha Patel>
-- Create date: <05-AUG-2015>
-- Description:	<Export to CSV Forms Data>
/*
ExportFormsDataToCsv '8', '10004', 11, 4, '', '', '01 Jan 2015', '06 Aug 2015', '',0
ExportFormsDataToCsv '8', '10004', 11, 4, '', '', '01 Aug 2015', '06 Aug 2015', '',1
*/
-- =============================================
CREATE PROCEDURE [dbo].[ExportFormsDataToCsv]
    @EstablishmentId NVARCHAR(MAX) ,
    @UserId NVARCHAR(MAX) ,
    @ActivityId BIGINT ,
    @Period INT ,
    @Search NVARCHAR(100) ,
    @Status NVARCHAR(50) ,
    @FromDate DATETIME ,
    @ToDate DATETIME ,
    @FilterOn NVARCHAR(50) ,
    @blIsOut BIT
AS
    BEGIN
        DECLARE @AnsStatus NVARCHAR(50) = '' ,
            @TranferFilter BIT = 0 ,
            @ActionFilter BIT = 0 ,
            @InOutFilter BIT = 0 ,
            @IsOut BIT = 1

        IF @Status IS NULL
            BEGIN
                SET @Status = ''
            END
            
        IF @Search IS NULL
            BEGIN
                SET @Search = ''
            END
        
        IF @Status = 'Unresolved'
            BEGIN
                SET @AnsStatus = @Status
                SET @Status = ''
            END
            
        IF @FilterOn = 'Resolved'
            BEGIN
                SET @AnsStatus = @FilterOn
            END
        ELSE
            IF @FilterOn = 'Transferred'
                BEGIN
                    SET @TranferFilter = 1
                END
            ELSE
                IF @FilterOn = 'Actioned'
                    BEGIN
                        SET @ActionFilter = 1
                    END
                ELSE
                    IF @FilterOn = 'In'
                        BEGIN
                            SET @InOutFilter = 1
                            SET @IsOut = 0
                        END
                    ELSE
                        IF @FilterOn = 'Out'
                            BEGIN
                                SET @InOutFilter = 1
                                SET @IsOut = 1
                            END
        
        DECLARE @Establishment TABLE
            (
              EstablishemtnId BIGINT
            )
        INSERT  INTO @Establishment
                ( EstablishemtnId 
                )
                SELECT  Data
                FROM    dbo.Split(@EstablishmentId, ',')
                WHERE   Data <> ''

        DECLARE @AppUser TABLE ( AppUserId BIGINT )
        INSERT  INTO @AppUser
                ( AppUserId 
                )
                SELECT  Data
                FROM    dbo.Split(@UserId, ',')
                WHERE   Data <> ''

        IF ( @blIsOut = 0 )
            BEGIN
                SELECT  *
                FROM    ( SELECT  DISTINCT
                                    A.*
                          FROM      dbo.View_AllAnswerMasterForExportIN AS A
                                    INNER JOIN @Establishment AS E ON A.EstablishmentId = E.EstablishemtnId
                                                              OR @EstablishmentId = '0'
                                    INNER JOIN @AppUser AS U ON U.AppUserId = A.UserId
                                                              OR @UserId = '0'
                                                              OR A.UserId = 0
                          WHERE     CAST(CreatedOn AS DATE) BETWEEN CAST(@FromDate AS DATE)
                                                            AND
                                                              CAST(@ToDate AS DATE)
                                    AND A.ActivityId = @ActivityId
                                    AND ( SmileType = @Status
                                          OR @Status = ''
                                        )
                                    AND ( AnswerStatus = @AnsStatus
                                          OR @AnsStatus = ''
                                        )
                                    AND ( A.EstablishmentName LIKE '%'
                                          + @Search + '%'
                                          OR A.EI LIKE '%' + @Search + '%'
                                          OR A.UserName LIKE '%' + @Search
                                          + '%'
                                          OR A.SenderCellNo LIKE '%' + @Search
                                          + '%'
                                          OR A.CaptureDate LIKE '%' + @Search
                                          + '%'
                                          OR A.DisplayText LIKE '%' + @Search
                                          + '%'
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
                        ) AS R

            END
        ELSE
            BEGIN
                SELECT  *
                FROM    ( SELECT  DISTINCT
                                    A.*
                          FROM      dbo.View_AllAnswerMasterForExportOUT AS A
                                    INNER JOIN @Establishment AS E ON A.EstablishmentId = E.EstablishemtnId
                                                              OR @EstablishmentId = '0'
                                    INNER JOIN @AppUser AS U ON U.AppUserId = A.UserId
                                                              OR @UserId = '0'
                                                              OR A.UserId = 0
                          WHERE     CAST(CreatedOn AS DATE) BETWEEN CAST(@FromDate AS DATE)
                                                            AND
                                                              CAST(@ToDate AS DATE)
                                    AND A.ActivityId = @ActivityId
                                    AND ( SmileType = @Status
                                          OR @Status = ''
                                        )
                                    AND ( AnswerStatus = @AnsStatus
                                          OR @AnsStatus = ''
                                        )
                                    AND ( A.EstablishmentName LIKE '%'
                                          + @Search + '%'
                                          OR A.EI LIKE '%' + @Search + '%'
                                          OR A.UserName LIKE '%' + @Search
                                          + '%'
                                          OR A.SenderCellNo LIKE '%' + @Search
                                          + '%'
                                          OR A.CaptureDate LIKE '%' + @Search
                                          + '%'
                                          OR A.DisplayText LIKE '%' + @Search
                                          + '%'
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
                        ) AS R
            END
    END