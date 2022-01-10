-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,22 Jun 2015>
-- Description:	<Description,,>
-- Call: select * from GetResolvedSMSEmailText(2528,'NXY')
-- =============================================
CREATE FUNCTION [dbo].[GetResolvedSMSEmailText]
    (
      @AnswerMasterId BIGINT ,
      @EncryptedId NVARCHAR(50)
    )
RETURNS @Result TABLE
    (
      SMSText NVARCHAR(MAX) ,
      EmailText NVARCHAR(MAX) ,
      EmailSubject NVARCHAR(500)
    )
AS
    BEGIN
        DECLARE @Url NVARCHAR(500) ,
            @SMSText NVARCHAR(MAX) ,
            @EmailText NVARCHAR(MAX) ,
            @EmailSubject NVARCHAR(500) ,
          --  @WebAppUrl NVARCHAR(100),
			@LastAction NVARCHAR(MAX) 

        --SELECT  @WebAppUrl = KeyValue 
        --FROM    dbo.AAAAConfigSettings
        --WHERE   KeyName = 'DocViewerRootFolderPathWebApp';
        
        SELECT  @EmailText = E.ResolutionFeedbackEmail ,
                @SMSText = E.ResolutionFeedbackSMS ,
                @EmailSubject = E.ResolutionFeedbackEmailSubject 
        FROM    dbo.AnswerMaster AS Am
                --INNER JOIN dbo.AppUser AS U ON Am.AppUserId = U.Id
                INNER JOIN dbo.Establishment AS E ON Am.EstablishmentId = E.Id
        WHERE   Am.Id = @AnswerMasterId;

		SELECT TOP 1 @LastAction = [Conversation] FROM dbo.CloseLoopAction WHERE AnswerMasterId = @AnswerMasterId AND [Conversation] != 'Resolved' ORDER BY id DESC
        
       
        IF @EmailText <> ''
            OR @SMSText <> ''
            OR @EmailSubject <> ''
			OR @EmailText IS NOT NULL
            OR @SMSText IS NOT NULL
            OR @EmailSubject IS NOT NULL
		
            BEGIN
                    
				SELECT  @Url = KeyValue + 'Fb/CustomerFeedbackForm?rid=' + @EncryptedId +'&IsOut=0&Cid=M90Pe7ZC_Dk1'
                FROM    dbo.AAAAConfigSettings
                WHERE   KeyName = 'DocViewerRootFolderPath';

                SET @SMSText = REPLACE(@SMSText, '[link]', @Url);
				SET @SMSText = REPLACE(@SMSText, '[LastAction]', @LastAction)

                SET @EmailText = REPLACE(@EmailText, '[link]', @Url);
                SET @EmailText = REPLACE(@EmailText, '[LastAction]', @LastAction);

           END;
        INSERT  INTO @Result
                ( SMSText ,
                  EmailText ,
	              EmailSubject
                )
        VALUES  ( ISNULL(@SMSText, '') , -- SMSText - nvarchar(max)
                  ISNULL(@EmailText, '') , -- EmailText - nvarchar(max)
                  ISNULL(@EmailSubject,'')
                );

        RETURN; 
    END;

