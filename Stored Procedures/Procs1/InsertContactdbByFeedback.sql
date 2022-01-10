
-- =============================================
-- Author:		Vasu Patel
-- Create date: 27 Mar 2017
-- Description:	Insert Or Update Contact Database By Feedback From
-- Call:					dbo.InsertContactdbByFeedback  63517
-- =============================================
CREATE PROCEDURE [dbo].[InsertContactdbByFeedback]
    @AnswerMasterId BIGINT
AS
    BEGIN
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
        DECLARE @TempExistsTable AS TABLE
            (
              ContactMasterId BIGINT ,
              Details NVARCHAR(500) ,
              Email NVARCHAR(50) ,
              Mobile NVARCHAR(20) ,
              RoleName VARCHAR(500) ,
              UserName VARCHAR(500)
            );

        DECLARE @Id BIGINT;
        DECLARE @TempTable TABLE
            (
              ContactId BIGINT ,
              GroupId BIGINT ,
              ContactQuestionId BIGINT ,
              ContactOptionId BIGINT ,
              QuestionTypeId BIGINT ,
              Detail NVARCHAR(500)
            );
        INSERT  INTO @TempTable
                ( ContactId ,
                  GroupId ,
                  ContactQuestionId ,
                  ContactOptionId ,
                  QuestionTypeId ,
                  Detail
                )
                --SELECT  CQ.ContactId ,
                --        E.GroupId ,
                --        CQ.Id ,
                --        CO.Id ,
                --        CQ.QuestionTypeId ,
                --        A.Detail
                --FROM    dbo.Questions AS Q
                --        INNER JOIN dbo.Answers AS A ON A.QuestionId = Q.Id
                --        INNER JOIN dbo.ContactQuestions AS CQ ON CQ.Id = Q.ContactQuestionIdRef
                --        INNER JOIN dbo.AnswerMaster AS AM ON AM.Id = A.AnswerMasterId
                --        INNER JOIN dbo.Establishment AS E ON E.Id = AM.EstablishmentId
                --        LEFT OUTER JOIN dbo.ContactOptions AS CO ON CO.ContactQuestionId = CQ.Id
                --        LEFT OUTER JOIN dbo.Options AS o ON o.Id = A.OptionId
                --WHERE   A.AnswerMasterId = @AnswerMasterId
                --        AND Q.ContactQuestionIdRef IS NOT NULL
                --        AND ISNULL(CO.Position, 0) = ISNULL(o.Position, 0);
				SELECT CQ.ContactId,
               E.GroupId,
               CQ.Id,
               ISNULL(CO.Id, 0) AS ID,
               CQ.QuestionTypeId,
               A.Detail
        FROM dbo.Questions AS Q
            INNER JOIN dbo.Answers AS A
                ON A.QuestionId = Q.Id
            INNER JOIN dbo.ContactQuestions AS CQ
                ON CQ.Id = Q.ContactQuestionIdRef
            INNER JOIN dbo.AnswerMaster AS AM
                ON AM.Id = A.AnswerMasterId
            INNER JOIN dbo.Establishment AS E
                ON E.Id = AM.EstablishmentId
            LEFT OUTER JOIN dbo.ContactOptions AS CO
                ON CO.ContactQuestionId = CQ.Id
            LEFT OUTER JOIN dbo.Options AS o
                --ON o.Id = A.OptionId
                ON o.QuestionId = A.QuestionId
        WHERE A.AnswerMasterId = @AnswerMasterId
              AND Q.ContactQuestionIdRef IS NOT NULL
              AND ISNULL(CO.Position, 0) = ISNULL(o.Position, 0)
              AND A.Detail NOT LIKE '%,%'
        UNION
        SELECT CQ.ContactId,
               E.GroupId,
               CQ.Id,
               CO.Id AS ID,
               CQ.QuestionTypeId,
               CASE
                   WHEN ISNULL(o.Name, '') = '' THEN
                       ''
                   ELSE
                       o.Name
               END AS Detail
        FROM dbo.Questions AS Q
            INNER JOIN dbo.Answers AS A
                ON A.QuestionId = Q.Id
            INNER JOIN dbo.ContactQuestions AS CQ
                ON CQ.Id = Q.ContactQuestionIdRef
            INNER JOIN dbo.AnswerMaster AS AM
                ON AM.Id = A.AnswerMasterId
            INNER JOIN dbo.Establishment AS E
                ON E.Id = AM.EstablishmentId
            LEFT OUTER JOIN dbo.ContactOptions AS CO
                ON CO.ContactQuestionId = CQ.Id
            LEFT OUTER JOIN dbo.Options AS o
                ON o.QuestionId = A.QuestionId
        WHERE A.AnswerMasterId = @AnswerMasterId
              AND o.Name IN (
                                SELECT Data FROM Split(A.Detail, ',')
                            )
              AND Q.ContactQuestionIdRef IS NOT NULL
              AND ISNULL(CO.Position, 0) = ISNULL(o.Position, 0);

        DECLARE @GroupId BIGINT ,
            @EmailId NVARCHAR(50) ,
            @Mobile NVARCHAR(20) ,
            @Count BIGINT;

        SELECT TOP 1
                @GroupId = GroupId
        FROM    @TempTable;
        SELECT  @EmailId = Detail
        FROM    @TempTable
        WHERE   QuestionTypeId = 10;
        SELECT  @Mobile = Detail
        FROM    @TempTable
        WHERE   QuestionTypeId = 11;

        INSERT  INTO @TempExistsTable
                EXEC dbo.IsContactMasterExists @GroupId, 0, @EmailId, @Mobile;

        SELECT  @Count = COUNT(1)
        FROM    @TempExistsTable;
        IF ( @EmailId != ''
             OR @Mobile != ''
           )
            BEGIN
                IF ( @Count = 1 )
                    BEGIN
                        UPDATE  dbo.ContactDetails
                        SET     Detail = T.Detail
                        FROM    @TempTable AS T
                                INNER JOIN dbo.ContactDetails C ON C.ContactQuestionId = T.ContactQuestionId
                        WHERE   C.ContactMasterId = ( SELECT TOP 1
                                                              ContactMasterId
                                                      FROM    @TempExistsTable
                                                    );
                    END;
                ELSE
                    IF ( @Count = 0 )
                        BEGIN
                            INSERT  INTO dbo.ContactMaster
                                    ( ContactId ,
                                      GroupId ,
                                      Remarks ,
                                      CreatedOn ,
                                      CreatedBy ,
                                      IsDeleted
                                    )
                                    SELECT TOP 1
                                            ContactId ,
                                            GroupId ,
                                            'Inserted From Feedback Id = '
                                            + CONVERT(NVARCHAR(10), @AnswerMasterId) ,
                                            GETUTCDATE() ,
                                            0 ,
                                            0
                                    FROM    @TempTable;
                            SET @Id = @@IDENTITY;
                            INSERT  INTO dbo.ContactDetails
                                    ( ContactMasterId ,
                                      ContactQuestionId ,
                                      ContactOptionId ,
                                      QuestionTypeId ,
                                      Detail ,
                                      CreatedOn ,
                                      CreatedBy ,
                                      IsDeleted
                                    )
                                    SELECT  @Id ,
                                            ContactQuestionId ,
                                            ContactOptionId ,
                                            QuestionTypeId ,
                                            Detail ,
                                            GETUTCDATE() ,
                                            0 ,
                                            0
                                    FROM    @TempTable;
                        END;
                
            END;
			END TRY

BEGIN CATCH
	INSERT INTO dbo.ErrorLog
        (
            PageId,
            MethodName,
            ErrorType,
            ErrorMessage,
            ErrorDetails,
            ErrorDate,
            UserId,
            Solution,
            CreatedOn,
            CreatedBy
        )
        VALUES
        (ERROR_LINE(),
         'dbo.InsertContactdbByFeedback',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         N'',
         @AnswerMasterId,
         GETUTCDATE(),
         N''
        );
END CATCH
    END;
