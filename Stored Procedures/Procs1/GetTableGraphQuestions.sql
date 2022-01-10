-- =============================================
-- Author:			SV
-- Create date:
-- Description:
-- Call SP:		dbo.GetTableGraphQuestions
-- GetTableGraphQuestions 19553, 8751,'0','0',1
-- =============================================
CREATE PROCEDURE dbo.GetTableGraphQuestions
    @AppuserId BIGINT ,
    @ActivityId BIGINT ,
    @EstablishmentId NVARCHAR(MAX) ,
    @UserId NVARCHAR(MAX) ,
    @IsOut BIT
AS
    BEGIN
	SET NOCOUNT ON;

        DECLARE @Result TABLE
            (
              Id BIGINT NOT NULL ,
              QuestionTitle NVARCHAR(250) NOT NULL ,
              [Count] BIGINT NOT NULL ,
              QuestionId BIGINT NOT NULL ,
              CurrentDate DATETIME NOT NULL
            );

        DECLARE @QuestionnaireId BIGINT ,
            @SeenClientId BIGINT ,
            @QuestionnaireType NVARCHAR(10) ,
            @TotalEntry BIGINT ,
            @CurrnetDate DATETIME ,
            @EstablishmentGroupType NVARCHAR(10);

        SELECT TOP 1
                @QuestionnaireId = QuestionnaireId ,
                @SeenClientId = SeenClientId ,
                @QuestionnaireType = CASE @IsOut
                                       WHEN 0 THEN Q.QuestionnaireType
                                       ELSE S.SeenClientType
                                     END ,
                @CurrnetDate = DATEADD(MINUTE, E.TimeOffSet, @CurrnetDate) ,
                @EstablishmentGroupType = Eg.EstablishmentGroupType
        FROM    dbo.EstablishmentGroup AS Eg WITH(NOLOCK)
                LEFT OUTER JOIN dbo.Establishment AS E WITH(NOLOCK) ON Eg.Id = E.EstablishmentGroupId
                                                          AND ISNULL(E.IsDeleted,
                                                              0) = 0
                INNER JOIN dbo.Questionnaire AS Q WITH(NOLOCK) ON Eg.QuestionnaireId = Q.Id
                LEFT OUTER JOIN dbo.SeenClient AS S WITH(NOLOCK) ON Eg.SeenClientId = S.Id
        WHERE   Eg.Id = @ActivityId;
		
        IF ( @EstablishmentId = '0' )
            BEGIN
                SET @EstablishmentId = ( SELECT dbo.AllEstablishmentByAppUserAndActivity(@AppuserId,
                                                              @ActivityId)
                                       );
            END;
      
        DECLARE @ActivityType NVARCHAR(50);
        SELECT  @ActivityType = EstablishmentGroupType
        FROM    dbo.EstablishmentGroup
        WHERE   Id = @ActivityId;
        IF ( @UserId = '0'
             AND @ActivityType != 'Customer'
           )
            BEGIN
                SET @UserId = ( SELECT  dbo.AllUserSelected(@AppuserId,
                                                            @EstablishmentId,
                                                            @ActivityId)
                              );
            END;


        SET @CurrnetDate = ISNULL(@CurrnetDate, CAST(GETUTCDATE() AS DATE));
        
        IF @IsOut = 1
            BEGIN
                SELECT  @TotalEntry = COUNT(1)
                FROM    dbo.View_SeenClientAnswerMaster AS Am
                        INNER JOIN ( SELECT Data
                                     FROM   dbo.Split(@EstablishmentId, ',')
                                   ) AS RE ON ( RE.Data = Am.EstablishmentId
                                                OR @EstablishmentId = '0'
                                              )
                        INNER JOIN ( SELECT Data
                                     FROM   dbo.Split(@UserId, ',')
                                   ) AS RU ON RU.Data = Am.AppUserId
                                              OR @UserId = '0'
                WHERE   CAST(CreatedOn AS DATE) = CAST(@CurrnetDate AS DATE)
                        AND ActivityId = @ActivityId
                        AND ISNULL(Am.IsDisabled, 0) = 0;
            END;
        ELSE
            BEGIN
                SELECT  @TotalEntry = COUNT(1)
                FROM    dbo.View_AnswerMaster AS Am
                        INNER JOIN ( SELECT Data
                                     FROM   dbo.Split(@EstablishmentId, ',')
                                   ) AS RE ON ( RE.Data = Am.EstablishmentId
                                                OR @EstablishmentId = '0'
                                              )
                        INNER JOIN ( SELECT Data
                                     FROM   dbo.Split(@UserId, ',')
                                   ) AS RU ON RU.Data = Am.AppUserId
                                              OR @UserId = '0'
                WHERE   CAST(CreatedOn AS DATE) = CAST(@CurrnetDate AS DATE)
                        AND ActivityId = @ActivityId
                        AND ISNULL(Am.IsDisabled, 0) = 0;
            END;
            
        IF @IsOut = 0
            BEGIN
                INSERT  INTO @Result
                        ( Id ,
                          QuestionTitle ,
                          [Count] ,
                          QuestionId ,
                          CurrentDate
                                
                        )
                        SELECT  Id ,
                                ShortName ,
                                @TotalEntry ,
                                Id ,
                                @CurrnetDate
                        FROM    dbo.Questions 
                        WHERE   QuestionnaireId = @QuestionnaireId
                                AND QuestionTypeId IN ( 5, 6, 7, 18, 21 )
                                AND DisplayInTableView = 1
                                --AND IsActive = 1
                                AND IsDeleted = 0
                        ORDER BY Position ASC; /* Added By Disha - 03-OCT-2016 */

                INSERT  INTO @Result
                        ( Id ,
                          QuestionTitle ,
                          [Count] ,
                          QuestionId ,
                          CurrentDate
                        )
                        SELECT  -2 ,
                                TableGroupName ,
                                @TotalEntry ,
                                -2 ,
                                @CurrnetDate
                        FROM    dbo.Questions 
                        WHERE   QuestionnaireId = @QuestionnaireId
                                AND QuestionTypeId = 19
                                --AND IsActive = 1
                                AND IsDeleted = 0
                                AND TableGroupName IS NOT NULL
                                AND TableGroupName <> ''
                        GROUP BY TableGroupName;
            END;
        ELSE
            BEGIN
                INSERT  INTO @Result
                        ( Id ,
                          QuestionTitle ,
                          [Count] ,
                          QuestionId ,
                          CurrentDate                                
                        )
                        SELECT  Id ,
                                ShortName ,
                                @TotalEntry ,
                                Id ,
                                @CurrnetDate
                        FROM    dbo.SeenClientQuestions 
                        WHERE   SeenClientId = @SeenClientId
                                AND QuestionTypeId IN ( 5, 6, 7, 18, 21 )
                                AND DisplayInTableView = 1
                                AND IsDeleted = 0
                        ORDER BY Position ASC; /* Added By Disha - 03-OCT-2016 */

                INSERT  INTO @Result
                        ( Id ,
                          QuestionTitle ,
                          [Count] ,
                          QuestionId ,
                          CurrentDate
                        )
                        SELECT  -2 ,
                                TableGroupName ,
                                @TotalEntry ,
                                -2 ,
                                @CurrnetDate
                        FROM    dbo.SeenClientQuestions 
                        WHERE   SeenClientId = @SeenClientId
                                AND QuestionTypeId = 19
                                AND IsDeleted = 0
                                AND TableGroupName IS NOT NULL
                                AND TableGroupName <> ''
                        GROUP BY TableGroupName;
            END;
  
        SELECT  *
        FROM    @Result;          
SET NOCOUNT OFF;
    END;
