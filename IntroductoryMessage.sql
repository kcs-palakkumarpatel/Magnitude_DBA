-- =============================================
-- Author:			Sunil Vaghasiya
-- Create date:	26-May-2017
-- Description: IntroductoryMessage Html Formate 
-- Call:select dbo.IntroductoryMessage(365106,0)
-- =============================================
CREATE FUNCTION dbo.IntroductoryMessage
    (
      @SeenClientAnswerMasterId BIGINT ,
      @SeenClientClientId BIGINT
    )
RETURNS NVARCHAR(MAX)
AS
    BEGIN
        DECLARE @IntroductoryMessage NVARCHAR(MAX);
        DECLARE @EstablishmentName NVARCHAR(500) ,
            @UserName NVARCHAR(50) ,
            @UserEmail NVARCHAR(50) ,
            @UserMobile NVARCHAR(50) ,
            @UserProfileImage NVARCHAR(500) ,
            @GraphicImageUrl NVARCHAR(500) ,
            @SeenClientId BIGINT ,
            @URL NVARCHAR(500);

        SELECT  @GraphicImageUrl = KeyValue 
        FROM    dbo.AAAAConfigSettings
        WHERE   KeyName = 'DocViewerRootFolderPathCMS';

        SELECT  @URL = KeyValue 
        FROM    dbo.AAAAConfigSettings
        WHERE   KeyName = 'DocViewerRootFolderPathWebApp';

        SELECT  @EstablishmentName = EstablishmentName ,
                @UserName = U.Name ,
                --@IntroductoryMessage = IntroductoryMessage ,
				@IntroductoryMessage = '<html><head><meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1" shrink-to-fit=YES/><meta name="viewport" content="width=device-width, shrink-to-fit=YES" /><style>img{max-width:100%;max-height:100%height:auto;width:auto !important;}</style></head><body></body></html>' + IntroductoryMessage + '',
                @UserEmail = U.Email ,
                @UserMobile = U.Mobile ,
                @UserProfileImage = ISNULL(U.ImageName, '') ,
                @SeenClientId = Am.SeenClientId
        FROM    dbo.SeenClientAnswerMaster AS Am
                INNER JOIN dbo.AppUser AS U ON Am.AppUserId = U.Id
                INNER JOIN dbo.Establishment AS E ON Am.EstablishmentId = E.Id
        WHERE   Am.Id = @SeenClientAnswerMasterId;

        DECLARE @Tbl TABLE
            (
              Id BIGINT IDENTITY(1, 1) ,
              QuestionId BIGINT ,
              Detail NVARCHAR(MAX)
            );

        DECLARE @Start BIGINT = 1 ,
            @End BIGINT ,
            @Id BIGINT ,
            @Details NVARCHAR(MAX) ,
            @QuestionId NVARCHAR(10);

        INSERT  INTO @Tbl
                ( QuestionId ,
                  Detail 
                )
             SELECT  CQ.Id  ,
             ISNULL(     CASE CA.QuestionTypeId WHEN 8 THEN CASE Detail WHEN '' THEN '' ELSE dbo.ChangeDateFormat(Detail, 'dd/MMM/yyyy') END
                          WHEN 9 THEN CASE Detail WHEN '' THEN '' ELSE dbo.ChangeDateFormat(Detail, 'hh:mm AM/PM') END
                          WHEN 22 THEN CASE Detail WHEN '' THEN '' ELSE dbo.ChangeDateFormat(Detail, 'dd/MMM/yyyy hh:mm AM/PM') END
                          WHEN 17 THEN dbo.GetFileTypeQuestionImageString(Detail, 1, CQ.Id) ELSE Detail
                        END, '') AS  [Detail]
                FROM    dbo.SeenClientAnswerMaster  AS CAM
				INNER JOIN SeenClientQuestions AS CQ ON CQ.SeenClientId = CAM.SeenClientId AND CQ.IsDeleted = 0
				LEFT JOIN dbo.SeenClientAnswers AS CA ON CA.QuestionId =CQ.Id AND CA.SeenClientAnswerMasterId = @SeenClientAnswerMasterId AND
                ISNULL(CA.SeenClientAnswerChildId,0) = IIF(@SeenClientClientId > 0, @SeenClientClientId, 0)
                WHERE     CAM.Id = @SeenClientAnswerMasterId AND CQ.QuestionTypeId NOT IN (16, 23) AND  CAM.IsDeleted = 0 ;

				     INSERT  INTO @Tbl
                ( QuestionId ,
                  Detail 
                )
                SELECT  Id ,
                        CASE QuestionTypeId WHEN 16 THEN QuestionTitle ELSE '<img src=''' + @GraphicImageUrl + 'SeenClientQuestions/' + ImagePath + ''' alt="' + ImagePath + '" class="view-image" />' END
                FROM    dbo.SeenClientQuestions
                WHERE   SeenClientId = @SeenClientId AND QuestionTypeId IN ( 16, 23 );

        SELECT  @End = COUNT(1) FROM    @Tbl;

        IF @IntroductoryMessage <> '' OR @IntroductoryMessage IS NOT NULL
            BEGIN
                WHILE @Start <= @End
                    BEGIN
                        SELECT  @QuestionId = QuestionId ,@Details = Detail FROM    @Tbl WHERE   Id = @Start;
                       SET @IntroductoryMessage = REPLACE(@IntroductoryMessage, '##[' + @QuestionId + ']##', @Details);
                        SET @Start += 1;
                    END;

                SELECT  @UserProfileImage = KeyValue + 'AppUser/' + @UserProfileImage
                FROM    dbo.AAAAConfigSettings
                WHERE   KeyName = 'DocViewerRootFolderPathCMS';        


				  --SELECT  @UserProfileImage = KeyValue + 'UploadFiles/AppUser/' + @UserProfileImage
      --          FROM    dbo.AAAAConfigSettings
      --          WHERE   KeyName = 'DocViewerRootFolderPath';    
        
                SET @IntroductoryMessage = REPLACE(@IntroductoryMessage, '##[username]##', @UserName);

                SET @IntroductoryMessage = REPLACE(@IntroductoryMessage, '##[establishment]##', @EstablishmentName);

                SET @IntroductoryMessage = REPLACE(@IntroductoryMessage, '##[useremail]##', @UserEmail);

                SET @IntroductoryMessage = REPLACE(@IntroductoryMessage, '##[usermobile]##', @UserMobile);

                SET @IntroductoryMessage = REPLACE(@IntroductoryMessage, '##[userprofilepicture]##', '<img src=''' + @UserProfileImage + ''' alt=''' + @UserName + '''  class="view-image" />');
            END;
        RETURN ISNULL(@IntroductoryMessage, '');
    END;



