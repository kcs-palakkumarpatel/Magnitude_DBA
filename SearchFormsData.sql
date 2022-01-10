-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,30 Jun 2015>
-- Description:	<Description,,>
-- Call SP:		SearchFormsData '0', '0', 3, 4, 10, 1, '', '', '01 Jan 2015', '31 Dec 2015', '', 1
--				SearchFormsData '1356', '314,315,313', 919, 4, 100, 1, '', '', '01 Jan 2016', '30 Nov 2016', '', 1,314
-- =============================================
CREATE PROCEDURE [dbo].[SearchFormsData]
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
    @ForMobile BIT,
	@AppuserId BIGINT
AS
    BEGIN
        IF @ForMobile = 1
            BEGIN
                SET @Rows = 100;
            END;
        DECLARE @AnsStatus NVARCHAR(50) = '' ,
            @TranferFilter BIT = 0 ,
            @ActionFilter BIGINT = 0 ,
            @InOutFilter BIT = 0 ,
            @IsOut BIT = 1,
			@IsView BIT = 0,
			@IsAlertRead BIT = 0;

        IF @Status IS NULL
            BEGIN
                SET @Status = '';
            END;

		DECLARE @Url VARCHAR(50)
		DECLARE @GroupType INT
		SELECT  @url = KeyValue FROM  dbo.AAAAConfigSettings WHERE KeyName = 'FeedbackUrl'
		SELECT @GroupType = ISNULL(Id,0) FROM dbo.AppUser WHERE GroupId IN (SELECT KeyValue FROM dbo.AAAAConfigSettings WHERE KeyName = 'ExcludeGroupId')
		AND id = @AppuserId
		            
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
					IF @FilterOn = 'UnActioned'
					BEGIN
					PRINT '1';
						SET @ActionFilter = 2;
					END
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
                	ELSE IF @FilterOn = 'OutStanding'
							BEGIN
								SET @IsView = 1;
							END
								ELSE IF @FilterOn = 'UnreadAction'
						BEGIN
							SET @IsAlertRead = 1;
						END
        DECLARE @Start AS INT ,
            @End INT;
        SET @Start = ( ( @Page * @Rows ) - @Rows ) + 1;
        SET @End = @Start + @Rows - 1;

        PRINT @ActionFilter
		

        DECLARE @Establishment TABLE
            (
              EstablishemtnId BIGINT
            );

		IF(@EstablishmentId = '0')
		BEGIN
			SET @EstablishmentId = (SELECT dbo.AllEstablishmentByAppUserAndActivity(@AppuserId,@ActivityId))
		END

		INSERT  INTO @Establishment
                ( EstablishemtnId 
                )
                SELECT  Data
                FROM    dbo.Split(@EstablishmentId, ',')
                WHERE   Data <> '';
        

        

        DECLARE @AppUser TABLE ( AppUserId BIGINT );
       	DECLARE @ActivityType NVARCHAR(50)
		SELECT @ActivityType = EstablishmentGroupType FROM dbo.EstablishmentGroup WHERE id = @ActivityId
		  IF ( @UserId = '0' AND @ActivityType != 'Customer')
            BEGIN
			SET @UserId = (SELECT dbo.AllUserSelected(@AppuserId,@EstablishmentId,@ActivityId))
            END
                
                INSERT  INTO @AppUser
                        ( AppUserId 
                        )
                        SELECT  Data
                        FROM    dbo.Split(@UserId, ',')
                        WHERE   Data <> '';
        
                
        SELECT  * ,
                dbo.AnswerDetails(CASE IsOut
                                    WHEN 0 THEN 'Answers'
                                    ELSE 'SeenClientAnswers'
                                  END, ReportId) AS DisplayText ,
                dbo.ConcateString('ContactSummary', ContactMasterId) AS ContactDetails ,
                dbo.ChangeDateFormat(CreatedOn, 'MM/dd/yyyy hh:mm AM/PM') AS CaptureDate ,
                CASE Total / @Rows
                  WHEN 0 THEN 1
                  ELSE ( Total / @Rows ) + 1
                END AS TotalPage,ISNULL(
																		(SELECT ContactGropName FROM dbo.ContactGroup WHERE id IN(
																		SELECT ContactGroupId FROM dbo.SeenClientAnswerMaster 
																		WHERE id = ReportId AND R.IsOut=1)),'') as ContactGropName,
		CAST ((SELECT CASE R.Isout WHEN 1 THEN ISNULL((SELECT CASE WHEN COUNT(*) = 0 THEN 1 ELSE 0 end FROM dbo.AnswerMaster WHERE   SeenClientAnswerMasterId = R.ReportId),1) ELSE 0 end) AS BIT) AS IsResend,
		R.UnreadAction,
		CASE @AppuserId WHEN R.CreateduserId THEN  CASE  WHEN R.ContactGroupId != 0 THEN '' ELSE ISNULL(@Url,'') END END AS Url,
		ISNULL(@GroupType,0) AS GroupType
        FROM    ( SELECT    A.* ,
                            COUNT(*) OVER ( PARTITION BY 1 ) AS Total ,
                            ROW_NUMBER() OVER ( ORDER BY A.CreatedOn DESC ) AS RowNum,
							UnreadAction = CASE A.IsOut WHEN 0 THEN (SELECT COUNT(*) FROM dbo.PendingNotificationWeb WHERE AppUserId =  @AppuserId  AND IsRead = 0 AND RefId = ReportId AND ModuleId = 11) ELSE 
									(SELECT COUNT(*) FROM dbo.PendingNotificationWeb WHERE AppUserId =  @AppuserId AND IsRead = 0 AND RefId = ReportId AND ModuleId = 12	) end 
                  FROM      dbo.View_AllAnswerMaster AS A
                            INNER JOIN @Establishment AS E ON A.EstablishmentId = E.EstablishemtnId
                                                              OR @EstablishmentId = '0'
                            INNER JOIN @AppUser AS U ON U.AppUserId = A.UserId
                                                        OR U.AppUserId = ISNULL(A.TransferFromUserId,
                                                              0)
                                                        OR @UserId = '0'
                                                        OR A.UserId = 0
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
                                  OR ((@ActionFilter = 1 AND A.IsActioned=1) OR (@ActionFilter=2 AND A.IsActioned = 0 AND a.AnswerStatus = 'Unresolved'))
                               )
							AND ( @IsView = 0
                                  OR A.IsOutStanding  = 1
                                )
							AND (@IsAlertRead = 0 OR (CASE A.IsOut WHEN 0 THEN (SELECT COUNT(*) FROM dbo.PendingNotificationWeb WHERE AppUserId =  @AppuserId  AND IsRead = 0 AND RefId = ReportId AND ModuleId = 11) ELSE 
									(SELECT COUNT(*) FROM dbo.PendingNotificationWeb WHERE AppUserId =  @AppuserId AND IsRead = 0 AND RefId = ReportId AND ModuleId = 12) END) > 0)
                            AND ( @InOutFilter = 0
                                  OR IsOut = @IsOut
                                )
                  GROUP BY  ReportId ,
                            EstablishmentId ,
                            EstablishmentName ,
                            UserId ,
                            UserName ,
                            SenderCellNo ,
                            IsOutStanding ,
                            AnswerStatus ,
                            A.TimeOffSet ,
                            --CaptureDate ,
                            A.CreatedOn ,
                            A.UpdatedOn ,
							A.ContactGroupId,
							A.CreatedUserId,
                            EI ,
                            PI ,
                            SmileType ,
                            QuestionnaireType ,
                            FormType ,
                            IsOut ,
                            QuestionnaireId ,
                            ReadBy ,
                            ContactMasterId ,
                            Latitude ,
                            Longitude ,
                            IsTransferred ,
                            TransferToUser ,
                            TransferFromUser ,
                            A.SeenClientAnswerMasterId ,
                            ActivityId ,
                            IsActioned ,
                            TransferByUserId ,
                            TransferFromUserId,
							A.IsDisabled
                ) AS R
        WHERE   R.RowNum BETWEEN @Start AND @End 
        ORDER BY R.RowNum;
    END;








