-- =============================================
-- Author:			Sunil Vaghasiya
-- Create date:	21-Mar-2017
-- Description:	Get All Answers by Answer master Id
-- Call SP:		GetAnswersByAnswerMasterId 59749
-- =============================================
CREATE PROCEDURE [dbo].[GetAnswersByAnswerMasterId]
    @AnswerMasterId BIGINT
AS
    BEGIN
        DECLARE @ImageFile NVARCHAR(MAX) ,
            @Url NVARCHAR(MAX) ,
            @ImgIcon NVARCHAR(MAX);
       

        IF ( ( SELECT   COUNT(*)
               FROM     Answers
               WHERE    QuestionTypeId = 17
                        AND LEN(Detail) > 5
                        AND AnswerMasterId = @AnswerMasterId
             ) > 0 )
            BEGIN 
                --SELECT  @ImgIcon = KeyValue
                --FROM    dbo.AAAAConfigSettings
                --WHERE   KeyName = 'DocViewerRootFolderPath';
                --SELECT  @Url = KeyValue + 'UploadFiles/FeedBack/'
                --FROM    dbo.AAAAConfigSettings
                --WHERE   KeyName = 'WebAppUrl';


				     SELECT  @ImgIcon = KeyValue
                FROM    dbo.AAAAConfigSettings
                WHERE   KeyName = 'DocViewerRootFolderPathCMS';
                SELECT  @Url = KeyValue + 'FeedBack/'
                FROM    dbo.AAAAConfigSettings
                WHERE   KeyName = 'DocViewerRootFolderPathWebApp';

                SELECT  @ImageFile = CASE WHEN Detail IS NULL THEN ''
                                          ELSE REPLACE(ISNULL(Detail, ''), ',',
                                                       '"><img src="'
                                                       + @ImgIcon
                                                       + '/Content/Image/image.png"><a> | <a title="Click to view attachement" style=''height:15px;width:15px'' target=_blank href="'
                                                       + @Url)
                                     END
                FROM    Answers
                WHERE   QuestionTypeId = 17
                        AND AnswerMasterId = @AnswerMasterId;
            END;

        SELECT  Q.QuestionTitle + IIF(ISNULL(A.RepetitiveGroupId, 0) > 0,' ('+ A.RepetitiveGroupName + '-' + CAST( A.RepeatCount AS VARCHAR(20)) + ')' , '') AS QuestionTitle ,
                CASE A.QuestionTypeId
                  WHEN 8 THEN dbo.ChangeDateFormat(Detail, 'dd/MMM/yyyy')
                  WHEN 9 THEN dbo.ChangeDateFormat(Detail, 'hh:mm AM/PM')
                  WHEN 8
                  THEN dbo.ChangeDateFormat(Detail, 'dd/MMM/yyyy hh:mm AM/PM')
                  WHEN 17
                  THEN '<a title="Click to view attachement" style=''height:15px;width:15px'' target=_blank href="'
                       + @Url + @ImageFile + '"><img src="' + @ImgIcon
                       + '/Content/Image/image.png"><a>'
                  ELSE ISNULL(A.Detail, '')
                END AS Detail
        FROM    dbo.Answers AS A
                INNER JOIN dbo.Questions AS Q ON Q.Id = A.QuestionId
        WHERE   AnswerMasterId = @AnswerMasterId
                AND Q.IsDisplayInDetail = 1
				ORDER BY Q.Position, ISNULL(A.RepetitiveGroupId, 0) ASC
    END;
