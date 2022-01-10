CREATE PROCEDURE [dbo].[NewClientSetUp] @GroupId BIGINT
AS
BEGIN
    SET XACT_ABORT ON;
    SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    BEGIN TRAN;
    BEGIN
        DECLARE @IndustryId BIGINT,
                @ContactId BIGINT,
                @ThemeId BIGINT;

        SELECT @IndustryId = IndustryId,
               @ContactId = ContactId,
               @ThemeId = ThemeId
        FROM dbo.[Group]
        WHERE Id = @GroupId
              AND IsDeleted = 0;



        --CloseloopTemplate
        DELETE FROM dbo.CloseLoopTemplate
        WHERE EstablishmentGroupId NOT IN (
                                              SELECT Id FROM dbo.EstablishmentGroup WHERE GroupId = @GroupId
                                          );
        --HeaderSetting
        DELETE FROM dbo.HeaderSetting
        WHERE GroupId != @GroupId;
        --FeedbackOnceHistory
        DELETE FROM dbo.FeedbackOnceHistory
        WHERE EstablishmentId IN (
                                     SELECT Id
                                     FROM dbo.Establishment
                                     WHERE EstablishmentGroupId IN (
                                                                       SELECT Id FROM dbo.EstablishmentGroup WHERE GroupId != @GroupId
                                                                   )
                                 );
        --EstablishmentNameNew
        DELETE FROM dbo.EstablishmentNameNew
        WHERE EstablishmentId IN (
                                     SELECT Id
                                     FROM dbo.Establishment
                                     WHERE EstablishmentGroupId IN (
                                                                       SELECT Id FROM dbo.EstablishmentGroup WHERE GroupId != @GroupId
                                                                   )
                                 );


        --PendingEmail
        DELETE FROM dbo.PendingEmail
        WHERE Id IN (
                        (SELECT Id
                         FROM dbo.PendingEmail
                         WHERE RefId IN (
                                            SELECT Id
                                            FROM dbo.SeenClientAnswerMaster
                                            WHERE EstablishmentId IN (
                                                                         SELECT Id
                                                                         FROM dbo.Establishment
                                                                         WHERE EstablishmentGroupId IN (
                                                                                                           SELECT Id FROM dbo.EstablishmentGroup WHERE GroupId != @GroupId
                                                                                                       )
                                                                     )
                                        ))
                        UNION ALL
                        (SELECT Id
                         FROM dbo.PendingEmail
                         WHERE RefId IN (
                                            SELECT Id
                                            FROM dbo.AnswerMaster
                                            WHERE EstablishmentId IN (
                                                                         SELECT Id
                                                                         FROM dbo.Establishment
                                                                         WHERE EstablishmentGroupId IN (
                                                                                                           SELECT Id FROM dbo.EstablishmentGroup WHERE GroupId != @GroupId
                                                                                                       )
                                                                     )
                                        ))
                    );

        DELETE FROM dbo.PendingSMS
        WHERE Id IN (
                        (SELECT Id
                         FROM dbo.PendingSMS
                         WHERE RefId IN (
                                            SELECT Id
                                            FROM dbo.SeenClientAnswerMaster
                                            WHERE EstablishmentId IN (
                                                                         SELECT Id
                                                                         FROM dbo.Establishment
                                                                         WHERE EstablishmentGroupId IN (
                                                                                                           SELECT Id FROM dbo.EstablishmentGroup WHERE GroupId != @GroupId
                                                                                                       )
                                                                     )
                                        ))
                        UNION ALL
                        (SELECT Id
                         FROM dbo.PendingSMS
                         WHERE RefId IN (
                                            SELECT Id
                                            FROM dbo.AnswerMaster
                                            WHERE EstablishmentId IN (
                                                                         SELECT Id
                                                                         FROM dbo.Establishment
                                                                         WHERE EstablishmentGroupId IN (
                                                                                                           SELECT Id FROM dbo.EstablishmentGroup WHERE GroupId != @GroupId
                                                                                                       )
                                                                     )
                                        ))
                    );
        --contact
        DELETE FROM tblContact
        WHERE ContactId != @ContactId;

        DELETE FROM dbo.ContactOptions
        WHERE ContactQuestionId NOT IN (
                                           SELECT Id FROM dbo.ContactQuestions WHERE ContactId = @ContactId
                                       );





        DELETE FROM dbo.ChatDetails
        WHERE ChatId IN (
                            (SELECT ChatId
                             FROM dbo.ChatDetails
                             WHERE SeenClientAnswerMasterId IN (
                                                                   SELECT Id
                                                                   FROM dbo.SeenClientAnswerMaster
                                                                   WHERE EstablishmentId IN (
                                                                                                SELECT Id
                                                                                                FROM dbo.Establishment
                                                                                                WHERE EstablishmentGroupId IN (
                                                                                                                                  SELECT Id FROM dbo.EstablishmentGroup WHERE GroupId != @GroupId
                                                                                                                              )
                                                                                            )
                                                               ))
                            UNION ALL
                            (SELECT ChatId
                             FROM dbo.ChatDetails
                             WHERE AnswerMasterId IN (
                                                         SELECT Id
                                                         FROM dbo.AnswerMaster
                                                         WHERE EstablishmentId IN (
                                                                                      SELECT Id
                                                                                      FROM dbo.Establishment
                                                                                      WHERE EstablishmentGroupId IN (
                                                                                                                        SELECT Id FROM dbo.EstablishmentGroup WHERE GroupId != @GroupId
                                                                                                                    )
                                                                                  )
                                                     ))
                        );
        --EstablishmentGroupImage
        DELETE FROM dbo.EstablishmentGroupImage
        WHERE EstablishmentGroupId NOT IN (
                                              SELECT Id FROM dbo.EstablishmentGroup WHERE GroupId = @GroupId
                                          );
        DELETE FROM dbo.EstablishmentGroupModuleAlias
        WHERE EstablishmentGroupId NOT IN (
                                              SELECT Id FROM dbo.EstablishmentGroup WHERE GroupId = @GroupId
                                          );
        --ConditionLogic
        DELETE FROM dbo.ConditionLogic
        WHERE QuestionId IN (
                                SELECT Id
                                FROM dbo.Questions
                                WHERE QuestionnaireId IN (
                                                             SELECT DISTINCT
                                                                 q.Id
                                                             FROM dbo.EstablishmentGroup eg
                                                                 INNER JOIN dbo.Questionnaire q
                                                                     ON q.Id = eg.QuestionnaireId
                                                                        AND eg.IsDeleted = 0
                                                                        AND q.IsDeleted = 0
                                                                        AND eg.GroupId != @GroupId
                                                         )
                            );
        --RoutingLogic
        DELETE FROM dbo.RoutingLogic
        WHERE QueueQuestionId IN (
                                     SELECT Id
                                     FROM dbo.Questions
                                     WHERE QuestionnaireId IN (
                                                                  SELECT DISTINCT
                                                                      q.Id
                                                                  FROM dbo.EstablishmentGroup eg
                                                                      INNER JOIN dbo.Questionnaire q
                                                                          ON q.Id = eg.QuestionnaireId
                                                                             AND eg.IsDeleted = 0
                                                                             AND q.IsDeleted = 0
                                                                             AND eg.GroupId != @GroupId
                                                              )
                                 );

        --PendingNotification
        DELETE FROM dbo.PendingNotification
        WHERE AppUserId IN (
                               SELECT Id FROM dbo.AppUser WHERE GroupId != @GroupId
                           );
        DELETE FROM dbo.PendingNotificationWeb
        WHERE AppUserId IN (
                               SELECT Id FROM dbo.AppUser WHERE GroupId != @GroupId
                           );
        --FlagMaster
        DELETE FROM dbo.FlagMaster
        WHERE AppUserId IN (
                               SELECT Id FROM dbo.AppUser WHERE GroupId != @GroupId
                           );
        --SeenClient
        DELETE FROM dbo.SeenClientOptions
        WHERE QuestionId IN (
                                SELECT Id
                                FROM dbo.SeenClientQuestions
                                WHERE SeenClientId IN (
                                                          SELECT DISTINCT
                                                              s.Id
                                                          FROM dbo.EstablishmentGroup eg
                                                              INNER JOIN dbo.SeenClient s
                                                                  ON s.Id = eg.SeenClientId
                                                                     AND eg.IsDeleted = 0
                                                                     AND s.IsDeleted = 0
                                                                     AND eg.GroupId != @GroupId
                                                      )
                            );





        --Questionnarie
        DELETE FROM dbo.Options
        WHERE QuestionId IN (
                                SELECT Id
                                FROM dbo.Questions
                                WHERE QuestionnaireId IN (
                                                             SELECT DISTINCT
                                                                 q.Id
                                                             FROM dbo.EstablishmentGroup eg
                                                                 INNER JOIN dbo.Questionnaire q
                                                                     ON q.Id = eg.QuestionnaireId
                                                                        AND eg.IsDeleted = 0
                                                                        AND q.IsDeleted = 0
                                                                        AND eg.GroupId != @GroupId
                                                         )
                            );




        --TimerFlag
        DELETE FROM dbo.TimerFlag
        WHERE RefId IN (
                           SELECT Id
                           FROM dbo.AnswerMaster
                           WHERE EstablishmentId IN (
                                                        SELECT Id
                                                        FROM dbo.Establishment
                                                        WHERE EstablishmentGroupId IN (
                                                                                          SELECT Id FROM dbo.EstablishmentGroup WHERE GroupId != @GroupId
                                                                                      )
                                                    )
                       );
        --EstablishmentStatus
        DELETE FROM dbo.EstablishmentStatus
        WHERE EstablishmentId IN (
                                     SELECT Id
                                     FROM dbo.Establishment
                                     WHERE EstablishmentGroupId IN (
                                                                       SELECT Id FROM dbo.EstablishmentGroup WHERE GroupId != @GroupId
                                                                   )
                                 );
        --StatusHistory
        DELETE FROM dbo.StatusHistory
        WHERE ReferenceNo IN (
                                 SELECT Id
                                 FROM dbo.SeenClientAnswerMaster
                                 WHERE EstablishmentId IN (
                                                              SELECT Id
                                                              FROM dbo.Establishment
                                                              WHERE EstablishmentGroupId IN (
                                                                                                SELECT Id FROM dbo.EstablishmentGroup WHERE GroupId != @GroupId
                                                                                            )
                                                          )
                             );
        --FilterValues
        DELETE FROM dbo.FilterValues
        WHERE ActivityId IN (
                                SELECT Id FROM dbo.EstablishmentGroup WHERE GroupId != @GroupId
                            );
        --tblUserEstablishment
        DELETE FROM dbo.tblUserEstablishment
        WHERE AppUserId IN (
                               SELECT Id FROM dbo.AppUser WHERE GroupId != @GroupId
                           );

        --UserTokenDetails
        DELETE FROM dbo.UserTokenDetails
        WHERE AppUserId IN (
                               SELECT Id FROM dbo.AppUser WHERE GroupId != @GroupId
                           );
        --CloseLoopAction
        --UPDATE CloseLoopAction SET IsDeleted=1
        --WHERE AppUserId IN (
          --                     SELECT Id FROM dbo.AppUser WHERE GroupId != @GroupId
            --               );
        --AnswerMaster
        DELETE FROM Answers
        WHERE AnswerMasterId IN (
                                    SELECT Id
                                    FROM dbo.AnswerMaster
                                    WHERE EstablishmentId IN (
                                                                 SELECT Id
                                                                 FROM dbo.Establishment
                                                                 WHERE EstablishmentGroupId IN (
                                                                                                   SELECT Id FROM dbo.EstablishmentGroup WHERE GroupId != @GroupId
                                                                                               )
                                                             )
                                );
        UPDATE dbo.Questions
        SET IsDeleted = 1
        WHERE QuestionnaireId IN (
                                     SELECT DISTINCT
                                         q.Id
                                     FROM dbo.EstablishmentGroup eg
                                         INNER JOIN dbo.Questionnaire q
                                             ON q.Id = eg.QuestionnaireId
                                                AND eg.IsDeleted = 0
                                                AND q.IsDeleted = 0
                                                AND eg.GroupId != @GroupId
                                 );
        DELETE FROM dbo.AnswerMaster
        WHERE EstablishmentId IN (
                                     SELECT Id
                                     FROM dbo.Establishment
                                     WHERE EstablishmentGroupId IN (
                                                                       SELECT Id FROM dbo.EstablishmentGroup WHERE GroupId != @GroupId
                                                                   )
                                 );
        --SeenClientAnswerMaster
        DELETE FROM dbo.SeenClientAnswers
        WHERE SeenClientAnswerMasterId IN (
                                              SELECT Id
                                              FROM dbo.SeenClientAnswerMaster
                                              WHERE EstablishmentId IN (
                                                                           SELECT Id
                                                                           FROM dbo.Establishment
                                                                           WHERE EstablishmentGroupId IN (
                                                                                                             SELECT Id FROM dbo.EstablishmentGroup WHERE GroupId != @GroupId
                                                                                                         )
                                                                       )
                                          );
        DELETE FROM dbo.SeenClientAnswerChild
        WHERE SeenClientAnswerMasterId IN (
                                              SELECT Id
                                              FROM dbo.SeenClientAnswerMaster
                                              WHERE EstablishmentId IN (
                                                                           SELECT Id
                                                                           FROM dbo.Establishment
                                                                           WHERE EstablishmentGroupId IN (
                                                                                                             SELECT Id FROM dbo.EstablishmentGroup WHERE GroupId != @GroupId
                                                                                                         )
                                                                       )
                                          );
        DELETE FROM dbo.SeenClientQuestions
        WHERE SeenClientId IN (
                                  SELECT DISTINCT
                                      s.Id
                                  FROM dbo.EstablishmentGroup eg
                                      INNER JOIN dbo.SeenClient s
                                          ON s.Id = eg.SeenClientId
                                             AND eg.IsDeleted = 0
                                             AND s.IsDeleted = 0
                                             AND eg.GroupId != @GroupId
                              );
        DELETE FROM dbo.SeenClientAnswerMaster
        WHERE EstablishmentId IN (
                                     SELECT Id
                                     FROM dbo.Establishment
                                     WHERE EstablishmentGroupId IN (
                                                                       SELECT Id FROM dbo.EstablishmentGroup WHERE GroupId != @GroupId
                                                                   )
                                 );

        DELETE FROM dbo.EditedSeenClientAnswers
        WHERE SeenClientAnswerMasterId IN (
                                              SELECT Id
                                              FROM dbo.EditedSeenClientAnswerMaster
                                              WHERE EstablishmentId IN (
                                                                           SELECT Id
                                                                           FROM dbo.Establishment
                                                                           WHERE EstablishmentGroupId IN (
                                                                                                             SELECT Id FROM dbo.EstablishmentGroup WHERE GroupId != @GroupId
                                                                                                         )
                                                                       )
                                          );

        DELETE FROM dbo.EditedSeenClientAnswerMaster
        WHERE EstablishmentId IN (
                                     SELECT Id
                                     FROM dbo.Establishment
                                     WHERE EstablishmentGroupId IN (
                                                                       SELECT Id FROM dbo.EstablishmentGroup WHERE GroupId != @GroupId
                                                                   )
                                 );
        --Contact
        DELETE FROM dbo.ContactDetails
        WHERE ContactMasterId IN (
                                     SELECT Id FROM dbo.ContactMaster WHERE GroupId != @GroupId
                                 );
        DELETE FROM dbo.ContactGroupDetails
        WHERE ContactGroupId IN (
                                    SELECT Id FROM dbo.ContactGroup WHERE GroupId != @GroupId
                                );
        DELETE FROM dbo.ContactGroupRelation
        WHERE ContactMasterId IN (
                                     SELECT Id FROM dbo.ContactMaster WHERE GroupId != @GroupId
                                 );
        DELETE FROM ContactGroup
        WHERE GroupId != @GroupId;

        DELETE FROM dbo.ContactMaster
        WHERE GroupId != @GroupId;

        DELETE FROM dbo.ContactRoleActivity
        WHERE ContactRoleId IN (
                                   SELECT Id FROM dbo.ContactRole WHERE GroupId != @GroupId
                               );

        DELETE FROM dbo.ContactRoleDetails
        WHERE ContactRoleId IN (
                                   SELECT Id FROM dbo.ContactRole WHERE GroupId != @GroupId
                               );

        DELETE FROM dbo.ContactRoleEstablishment
        WHERE ContactRoleId IN (
                                   SELECT Id FROM dbo.ContactRole WHERE GroupId != @GroupId
                               );

        DELETE FROM ContactRole
        WHERE GroupId != @GroupId;

        DELETE FROM DefaultContact
        WHERE AppUserId IN (
                               SELECT Id FROM dbo.AppUser WHERE GroupId != @GroupId
                           );

        DELETE FROM dbo.ContactQuestions
        WHERE ContactId != @ContactId;

        DELETE FROM dbo.Contact
        WHERE Id != @ContactId;
        --ReportAuditLog
        DELETE FROM dbo.ReportAuditLog
        WHERE AppUserId IN (
                               SELECT Id FROM dbo.AppUser WHERE GroupId != @GroupId
                           );
        DELETE FROM ReportAuditLog_History
        WHERE EstablishmentId IN (
                                     SELECT Id
                                     FROM dbo.Establishment
                                     WHERE EstablishmentGroupId IN (
                                                                       SELECT Id FROM dbo.EstablishmentGroup WHERE GroupId != @GroupId
                                                                   )
                                 );

        --AppManagerUserRights
        DELETE FROM dbo.AppManagerUserRights
        WHERE EstablishmentId IN (
                                     SELECT Id
                                     FROM dbo.Establishment
                                     WHERE EstablishmentGroupId IN (
                                                                       SELECT Id FROM dbo.EstablishmentGroup WHERE GroupId != @GroupId
                                                                   )
                                 );
        --AppUserContactRole
        DELETE FROM dbo.AppUserContactRole
        WHERE AppUserId IN (
                               SELECT Id FROM dbo.AppUser WHERE GroupId != @GroupId
                           );

        --AppUserEstablishment
        DELETE FROM AppUserEstablishment
        WHERE AppUserId IN (
                               SELECT Id FROM dbo.AppUser WHERE GroupId != @GroupId
                           );
        --AppUserModule
        DELETE FROM AppUserModule
        WHERE AppUserId IN (
                               SELECT Id FROM dbo.AppUser WHERE GroupId != @GroupId
                           );



        --AppUser
        DELETE FROM dbo.AppUser
        WHERE GroupId != @GroupId;

        --Establishment
        DELETE FROM dbo.Establishment
        WHERE EstablishmentGroupId IN (
                                          SELECT Id FROM dbo.EstablishmentGroup WHERE GroupId != @GroupId
                                      );
        --EstablishmentGroup

        CREATE TABLE #tempEstablishmentGroup
        (
            Id INT IDENTITY(1, 1),
            EstablishmentGroupId BIGINT,
            SeenclientId BIGINT,
            QuestionnarieId BIGINT,
            HowItWorksId BIGINT,
            GroupId BIGINT
        );

        INSERT INTO #tempEstablishmentGroup
        (
            EstablishmentGroupId,
            SeenclientId,
            QuestionnarieId,
            HowItWorksId,
            GroupId
        )
        SELECT Id,
               SeenClientId,
               QuestionnaireId,
               HowItWorksId,
               GroupId
        FROM dbo.EstablishmentGroup
        WHERE GroupId != @GroupId;


        DELETE FROM dbo.EstablishmentGroup
        WHERE GroupId != @GroupId;

        --SeenClient
        DELETE FROM dbo.SeenClient
        WHERE Id IN (
                        SELECT DISTINCT SeenclientId FROM #tempEstablishmentGroup
                    );

        -- Questionnaire
        DELETE FROM dbo.Questionnaire
        WHERE Id IN (
                        SELECT DISTINCT QuestionnarieId FROM #tempEstablishmentGroup
                    );

        --How it works
        DELETE FROM dbo.HowItWorks
        WHERE Id IN (
                        SELECT DISTINCT HowItWorksId FROM #tempEstablishmentGroup
                    );


        --Group
        DELETE FROM dbo.[Group]
        WHERE Id != @GroupId;

        --Industry
        DELETE FROM dbo.Industry
        WHERE Id != @IndustryId;
        --Theme
        DELETE FROM dbo.ThemeImage
        WHERE ThemeId != @ThemeId;

        DELETE FROM dbo.Theme
        WHERE Id != @ThemeId;

    END;
    COMMIT;
END;
