-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,03 Nov 2015>
-- Description:	<Description,,>
-- Call SP:		WSSendBulkSMSToContact 'Test ##[10069]##','MjAyNTU=,MjAyNTQ=','',20013,20039,0
-- =============================================
CREATE PROCEDURE [dbo].[WSSendBulkSMSToContact]
    @SMSText NVARCHAR(MAX) ,
    @ContactId NVARCHAR(MAX) ,
    @ContactId2 NVARCHAR(MAX) ,
    @AppUserId BIGINT ,
    @ActivityId BIGINT ,
    @IsGroup BIT
AS
    BEGIN
        SELECT  *
        FROM    dbo.ContactMaster;

        DECLARE @Contact TABLE
            (
              Id BIGINT IDENTITY(1, 1) ,
              ContactMasterId BIGINT
            );

        DECLARE @Question TABLE
            (
              Id BIGINT IDENTITY(1, 1) ,
              QuestionId BIGINT ,
              Detail NVARCHAR(MAX)
            );
        IF @IsGroup = 0
            BEGIN
                INSERT  INTO @Contact
                        ( ContactMasterId
                        )
                        SELECT  Data
                        FROM    dbo.Split(@ContactId, ',')
                        WHERE   Data <> ''
                                AND Data IS NOT NULL;

                INSERT  INTO @Contact
                        ( ContactMasterId
                        )
                        SELECT  Data
                        FROM    dbo.Split(@ContactId2, ',')
                        WHERE   Data <> ''
                                AND Data IS NOT NULL;

            END;
        ELSE
            BEGIN
                INSERT  INTO @Contact
                        ( ContactMasterId
                        )
                        SELECT  CGR.ContactMasterId
                        FROM    dbo.ContactGroupRelation AS CGR
                                INNER JOIN dbo.Split(@ContactId, ',') AS CG ON CG.Data = CGR.ContactGroupId
                        WHERE   CGR.IsDeleted = 0;

                INSERT  INTO @Contact
                        ( ContactMasterId
                        )
                        SELECT  CGR.ContactMasterId
                        FROM    dbo.ContactGroupRelation AS CGR
                                INNER JOIN dbo.Split(@ContactId2, ',') AS CG ON CG.Data = CGR.ContactGroupId
                        WHERE   CGR.IsDeleted = 0;
            END;
		
        DECLARE @ContactMasterId BIGINT ,
            @Start INT= 1 ,
            @End INT ,
            @SMS NVARCHAR(MAX) ,
            @QStart INT = 1 ,
            @QEnd INT ,
            @Details NVARCHAR(MAX) ,
            @QuestionId NVARCHAR(10) ,
            @MobileNo NVARCHAR(50);

        SELECT  @End = COUNT(1)
        FROM    @Contact;
		PRINT @Start
		PRINT @End

        WHILE ( @Start <= @End )
            BEGIN
                SELECT  @ContactMasterId = ContactMasterId
                FROM    @Contact
                WHERE   Id = @Start;

                SET @SMS = @SMSText;

                SET @MobileNo = '';

                SELECT  @MobileNo = Detail
                FROM    dbo.ContactDetails
                WHERE   ContactMasterId = @ContactMasterId
                        AND QuestionTypeId = 11;

                IF @MobileNo IS NOT NULL
                    AND @MobileNo <> ''
                    BEGIN

                        INSERT  INTO @Question
                                ( QuestionId ,
                                  Detail 
                                )
                                SELECT  ContactQuestionId ,
                                        CASE QuestionTypeId
                                          WHEN 8
                                          THEN dbo.ChangeDateFormat(Detail,
                                                              'MM/dd/yyyy')
                                          WHEN 9
                                          THEN dbo.ChangeDateFormat(Detail,
                                                              'hh:mm AM/PM')
                                          WHEN 22
                                          THEN dbo.ChangeDateFormat(Detail,
                                                              'MM/dd/yyyy hh:mm AM/PM')
                                          ELSE Detail
                                        END
                                FROM    dbo.ContactDetails
                                WHERE   ContactMasterId = @ContactMasterId;

                        SELECT  @QEnd = COUNT(1)
                        FROM    @Question;

                        WHILE @QStart <= @QEnd
                            BEGIN
                                SELECT  @QuestionId = QuestionId ,
                                        @Details = Detail
                                FROM    @Question
                                WHERE   Id = @QStart;
						
                                SET @SMS = REPLACE(@SMS,
                                                   '##[' + @QuestionId + ']##',
                                                   ISNULL(@Details, ''));
                                SET @QStart += 1;
                            END;

                        IF @SMS IS NOT NULL
                            AND @SMS <> ''
                            BEGIN
                                INSERT  INTO dbo.PendingSMS
                                        ( ModuleId ,
                                          MobileNo ,
                                          SMSText ,
                                          IsSent ,
                                          ScheduleDateTime ,
                                          RefId ,
                                          RefId1 ,
                                          CreatedOn ,
                                          CreatedBy 
				                        )
                                VALUES  ( 9 , -- ModuleId - bigint
                                          @MobileNo , -- MobileNo - nvarchar(1000)
                                          @SMS , -- SMSText - nvarchar(1000)
                                          0 , -- IsSent - bit
                                          GETUTCDATE() ,
                                          @ActivityId , -- RefId - bigint
                                          @ContactMasterId ,
                                          GETUTCDATE() , -- CreatedOn - datetime
                                          @AppUserId -- CreatedBy - bigint
				                        );
                            END;
                    END;

                SET @Start += 1;
            END;

    END;