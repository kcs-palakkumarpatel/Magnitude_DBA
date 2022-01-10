/*
 =============================================
 Author:		Disha Patel
 Create date:   04-NOV-2016
 Description:	Delete selected data for IN/OUT, Activity, Establishment, AppUser
 Call SP: DataClean 298,'2015','0',3,0,0,0,41,2
 =============================================
*/

CREATE PROCEDURE [dbo].[DataClean]
    @GroupId BIGINT ,
    @ActivityIds NVARCHAR(2000) ,
    @EstablishmentIds NVARCHAR(2000) ,
    @InOut INT , /* 1=IN , 2=OUT, 3=IN and OUT */
    @IsContact BIT ,
    @IsActivity BIT ,
    @IsEstablishment BIT ,
    @IsAppUser BIT ,
    @PageId BIGINT ,
    @UserId BIGINT
AS
    BEGIN
        IF @IsContact = 1
            BEGIN
				/* Contact Details */
                UPDATE  CD
                SET     CD.IsDeleted = 1 ,
                        CD.DeletedOn = GETUTCDATE() ,
                        CD.DeletedBy = @UserId
                FROM    dbo.ContactDetails CD
                        INNER JOIN dbo.ContactMaster CM ON CM.Id = CD.ContactMasterId
                                                           AND CM.GroupId = @GroupId
                WHERE   CD.IsDeleted = 0

				/* Contact Master */
                UPDATE  CM
                SET     IsDeleted = 1 ,
                        DeletedOn = GETUTCDATE() ,
                        DeletedBy = @UserId
                FROM    dbo.ContactMaster CM
                WHERE   CM.GroupId = @GroupId
                        AND CM.IsDeleted = 0

				/* Contact Group Relation */
                UPDATE  CGR
                SET     CGR.IsDeleted = 1 ,
                        CGR.DeletedOn = GETUTCDATE() ,
                        CGR.DeletedBy = @UserId
                FROM    dbo.ContactGroupRelation CGR
                        INNER JOIN dbo.ContactGroup CG ON CG.Id = CGR.ContactGroupId
                                                          AND CG.GroupId = @GroupId
                WHERE   CGR.IsDeleted = 0

				/* Contact Group Details */
                UPDATE  CGD
                SET     CGD.IsDeleted = 1 ,
                        CGD.DeletedOn = GETUTCDATE() ,
                        CGD.DeletedBy = @UserId
                FROM    dbo.ContactGroupDetails CGD
                        INNER JOIN dbo.ContactGroup CG ON CG.Id = CGD.ContactGroupId
                                                          AND CG.GroupId = @GroupId
                WHERE   CGD.IsDeleted = 0

				/* Contact Group */
                UPDATE  CG
                SET     CG.IsDeleted = 1 ,
                        CG.DeletedOn = GETUTCDATE() ,
                        CG.DeletedBy = @UserId
                FROM    dbo.ContactGroup CG
                WHERE   CG.GroupId = @GroupId
                        AND CG.IsDeleted = 0

				/* App User Contact Role */
                UPDATE  AUCR
                SET     AUCR.IsDeleted = 1 ,
                        AUCR.DeletedOn = GETUTCDATE() ,
                        AUCR.DeletedBy = @UserId
                FROM    dbo.AppUserContactRole AUCR
                        INNER JOIN dbo.ContactRole CR ON CR.Id = AUCR.ContactRoleId
                                                         AND CR.GroupId = @GroupId
                WHERE   AUCR.IsDeleted = 0

				/* Contact Role Establishment*/
                UPDATE  CRE
                SET     CRE.IsDeleted = 1 ,
                        CRE.DeletedOn = GETUTCDATE() ,
                        CRE.DeletedBy = @UserId
                FROM    dbo.ContactRoleEstablishment CRE
                        INNER JOIN dbo.ContactRole CR ON CR.Id = CRE.ContactRoleId
                                                         AND CR.GroupId = @GroupId
                WHERE   CRE.IsDeleted = 0
				
				/* Contact Role Activity*/
                UPDATE  CRA
                SET     CRA.IsDeleted = 1 ,
                        CRA.DeletedOn = GETUTCDATE() ,
                        CRA.DeletedBy = @UserId
                FROM    dbo.ContactRoleActivity CRA
                        INNER JOIN dbo.ContactRole CR ON CR.Id = CRA.ContactRoleId
                                                         AND CR.GroupId = @GroupId
                WHERE   CRA.IsDeleted = 0

				/* Contact Role Details*/
                UPDATE  CRD
                SET     CRD.IsDeleted = 1 ,
                        CRD.DeletedOn = GETUTCDATE() ,
                        CRD.DeletedBy = @UserId
                FROM    dbo.ContactRoleDetails CRD
                        INNER JOIN dbo.ContactRole CR ON CR.Id = CRD.ContactRoleId
                                                         AND CR.GroupId = @GroupId
                WHERE   CRD.IsDeleted = 0

				/* Contact Role */
                UPDATE  CR
                SET     CR.IsDeleted = 1 ,
                        CR.DeletedOn = GETUTCDATE() ,
                        CR.DeletedBy = @UserId
                FROM    dbo.ContactRole CR
                WHERE   CR.GroupId = @GroupId
                        AND CR.IsDeleted = 0
            END

        IF @InOut = 1
            OR @InOut = 3
            BEGIN
                IF ( @EstablishmentIds = '0' )
                    BEGIN
						/* IN */
                        UPDATE  CA
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.CloseLoopAction CA
                                INNER JOIN dbo.AnswerMaster AM ON AM.Id = CA.AnswerMasterId
                                INNER JOIN dbo.Establishment E ON E.Id = AM.EstablishmentId
                                INNER JOIN dbo.Split(@ActivityIds, ',') S ON S.Data = E.EstablishmentGroupId
                        WHERE   CA.IsDeleted = 0

                        UPDATE  AM
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.AnswerMaster AM
                                INNER JOIN dbo.Establishment E ON E.Id = AM.EstablishmentId
                                INNER JOIN dbo.Split(@ActivityIds, ',') S ON S.Data = E.EstablishmentGroupId
                        WHERE   AM.IsDeleted = 0

                        UPDATE  A
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.Answers A
                                INNER JOIN dbo.AnswerMaster AM ON AM.Id = A.AnswerMasterId
                                INNER JOIN dbo.Establishment E ON E.Id = AM.EstablishmentId
                                INNER JOIN dbo.Split(@ActivityIds, ',') S ON S.Data = E.EstablishmentGroupId
                        WHERE   A.IsDeleted = 0
                    END
                ELSE
                    BEGIN
						/* IN */
                        UPDATE  CA
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.CloseLoopAction CA
                                INNER JOIN dbo.AnswerMaster AM ON AM.Id = CA.AnswerMasterId
                                INNER JOIN dbo.Split(@EstablishmentIds, ',') S ON S.Data = AM.EstablishmentId
                        WHERE   CA.IsDeleted = 0

                        UPDATE  AM
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.AnswerMaster AM
                                INNER JOIN dbo.Split(@EstablishmentIds, ',') S ON S.Data = AM.EstablishmentId
                        WHERE   AM.IsDeleted = 0

                        UPDATE  A
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.Answers A
                                INNER JOIN dbo.AnswerMaster AM ON AM.Id = A.AnswerMasterId
                                INNER JOIN dbo.Split(@EstablishmentIds, ',') S ON S.Data = AM.EstablishmentId
                        WHERE   A.IsDeleted = 0
                    END
            END

        IF @InOut = 2
            OR @InOut = 3
            BEGIN
                IF ( @EstablishmentIds = '0' )
                    BEGIN
					/* OUT */
                        UPDATE  CA
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.CloseLoopAction CA
                                INNER JOIN dbo.SeenClientAnswerMaster SAM ON SAM.Id = CA.SeenClientAnswerMasterId
                                INNER JOIN dbo.Establishment E ON E.Id = SAM.EstablishmentId
                                INNER JOIN dbo.Split(@ActivityIds, ',') S ON S.Data = E.EstablishmentGroupId
                        WHERE   CA.IsDeleted = 0

                        UPDATE  SAM
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.SeenClientAnswerMaster SAM
                                INNER JOIN dbo.Establishment E ON E.Id = SAM.EstablishmentId
                                INNER JOIN dbo.Split(@ActivityIds, ',') S ON S.Data = E.EstablishmentGroupId
                        WHERE   SAM.IsDeleted = 0

                        UPDATE  SA
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.SeenClientAnswers SA
                                INNER JOIN dbo.SeenClientAnswerMaster SAM ON SAM.Id = SA.SeenClientAnswerMasterId
                                INNER JOIN dbo.Establishment E ON E.Id = SAM.EstablishmentId
                                INNER JOIN dbo.Split(@ActivityIds, ',') S ON S.Data = E.EstablishmentGroupId
                        WHERE   SA.IsDeleted = 0

                        UPDATE  SAC
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.SeenClientAnswerChild SAC
                                INNER JOIN dbo.SeenClientAnswerMaster SAM ON SAM.Id = SAC.SeenClientAnswerMasterId
                                INNER JOIN dbo.Establishment E ON E.Id = SAM.EstablishmentId
                                INNER JOIN dbo.Split(@ActivityIds, ',') S ON S.Data = E.EstablishmentGroupId
                        WHERE   SAC.IsDeleted = 0

						/* IN */
                        UPDATE  CA
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.CloseLoopAction CA
                                INNER JOIN dbo.AnswerMaster AM ON AM.Id = CA.AnswerMasterId
                                INNER JOIN dbo.SeenClientAnswerMaster SAM ON SAM.Id = AM.SeenClientAnswerMasterId
                                INNER JOIN dbo.Establishment E ON E.Id = SAM.EstablishmentId
                                INNER JOIN dbo.Split(@ActivityIds, ',') S ON S.Data = E.EstablishmentGroupId
                        WHERE   CA.IsDeleted = 0

                        UPDATE  AM
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.AnswerMaster AM
                                INNER JOIN dbo.SeenClientAnswerMaster SAM ON SAM.Id = AM.SeenClientAnswerMasterId
                                INNER JOIN dbo.Establishment E ON E.Id = SAM.EstablishmentId
                                INNER JOIN dbo.Split(@ActivityIds, ',') S ON S.Data = E.EstablishmentGroupId
                        WHERE   AM.IsDeleted = 0

                        UPDATE  A
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.Answers A
                                INNER JOIN dbo.AnswerMaster AM ON AM.Id = A.AnswerMasterId
                                INNER JOIN dbo.SeenClientAnswerMaster SAM ON SAM.Id = AM.SeenClientAnswerMasterId
                                INNER JOIN dbo.Establishment E ON E.Id = SAM.EstablishmentId
                                INNER JOIN dbo.Split(@ActivityIds, ',') S ON S.Data = E.EstablishmentGroupId
                        WHERE   A.IsDeleted = 0
                    END
                ELSE
                    BEGIN
						/* OUT */
                        UPDATE  CA
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.CloseLoopAction CA
                                INNER JOIN dbo.SeenClientAnswerMaster SAM ON SAM.Id = CA.SeenClientAnswerMasterId
                                INNER JOIN dbo.Split(@EstablishmentIds, ',') S ON S.Data = SAM.EstablishmentId
                        WHERE   CA.IsDeleted = 0

                        UPDATE  SAM
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.SeenClientAnswerMaster SAM
                                INNER JOIN dbo.Split(@EstablishmentIds, ',') S ON S.Data = SAM.EstablishmentId
                        WHERE   SAM.IsDeleted = 0

                        UPDATE  SA
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.SeenClientAnswers SA
                                INNER JOIN dbo.SeenClientAnswerMaster SAM ON SAM.Id = SA.SeenClientAnswerMasterId
                                INNER JOIN dbo.Split(@EstablishmentIds, ',') S ON S.Data = SAM.EstablishmentId
                        WHERE   SA.IsDeleted = 0

                        UPDATE  SAC
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.SeenClientAnswerChild SAC
                                INNER JOIN dbo.SeenClientAnswerMaster SAM ON SAM.Id = SAC.SeenClientAnswerMasterId
                                INNER JOIN dbo.Split(@EstablishmentIds, ',') S ON S.Data = SAM.EstablishmentId
                        WHERE   SAC.IsDeleted = 0

						/* IN */
                        UPDATE  CA
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.CloseLoopAction CA
                                INNER JOIN dbo.AnswerMaster AM ON AM.Id = CA.AnswerMasterId
                                INNER JOIN dbo.SeenClientAnswerMaster SAM ON SAM.Id = AM.SeenClientAnswerMasterId
                                INNER JOIN dbo.Split(@EstablishmentIds, ',') S ON S.Data = SAM.EstablishmentId
                        WHERE   CA.IsDeleted = 0

                        UPDATE  AM
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.AnswerMaster AM
                                INNER JOIN dbo.SeenClientAnswerMaster SAM ON SAM.Id = AM.SeenClientAnswerMasterId
                                INNER JOIN dbo.Split(@EstablishmentIds, ',') S ON S.Data = SAM.EstablishmentId
                        WHERE   AM.IsDeleted = 0

                        UPDATE  A
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.Answers A
                                INNER JOIN dbo.AnswerMaster AM ON AM.Id = A.AnswerMasterId
                                INNER JOIN dbo.SeenClientAnswerMaster SAM ON SAM.Id = AM.SeenClientAnswerMasterId
                                INNER JOIN dbo.Split(@EstablishmentIds, ',') S ON S.Data = SAM.EstablishmentId
                        WHERE   A.IsDeleted = 0
                    END
            END

        IF @IsActivity = 1
            BEGIN
				/* IN */
                UPDATE  CA
                SET     IsDeleted = 1 ,
                        DeletedOn = GETUTCDATE() ,
                        DeletedBy = @UserId
                FROM    dbo.CloseLoopAction CA
                        INNER JOIN dbo.AnswerMaster AM ON AM.Id = CA.AnswerMasterId
                        INNER JOIN dbo.Establishment E ON E.Id = AM.EstablishmentId
                        INNER JOIN dbo.Split(@ActivityIds, ',') S ON S.Data = E.EstablishmentGroupId
                WHERE   CA.IsDeleted = 0

                UPDATE  AM
                SET     IsDeleted = 1 ,
                        DeletedOn = GETUTCDATE() ,
                        DeletedBy = @UserId
                FROM    dbo.AnswerMaster AM
                        INNER JOIN dbo.Establishment E ON E.Id = AM.EstablishmentId
                        INNER JOIN dbo.Split(@ActivityIds, ',') S ON S.Data = E.EstablishmentGroupId
                WHERE   AM.IsDeleted = 0

                UPDATE  A
                SET     IsDeleted = 1 ,
                        DeletedOn = GETUTCDATE() ,
                        DeletedBy = @UserId
                FROM    dbo.Answers A
                        INNER JOIN dbo.AnswerMaster AM ON AM.Id = A.AnswerMasterId
                        INNER JOIN dbo.Establishment E ON E.Id = AM.EstablishmentId
                        INNER JOIN dbo.Split(@ActivityIds, ',') S ON S.Data = E.EstablishmentGroupId
                WHERE   A.IsDeleted = 0

				/* OUT */
                UPDATE  CA
                SET     IsDeleted = 1 ,
                        DeletedOn = GETUTCDATE() ,
                        DeletedBy = @UserId
                FROM    dbo.CloseLoopAction CA
                        INNER JOIN dbo.SeenClientAnswerMaster SAM ON SAM.Id = CA.SeenClientAnswerMasterId
                        INNER JOIN dbo.Establishment E ON E.Id = SAM.EstablishmentId
                        INNER JOIN dbo.Split(@ActivityIds, ',') S ON S.Data = E.EstablishmentGroupId
                WHERE   CA.IsDeleted = 0

                UPDATE  SAM
                SET     IsDeleted = 1 ,
                        DeletedOn = GETUTCDATE() ,
                        DeletedBy = @UserId
                FROM    dbo.SeenClientAnswerMaster SAM
                        INNER JOIN dbo.Establishment E ON E.Id = SAM.EstablishmentId
                        INNER JOIN dbo.Split(@ActivityIds, ',') S ON S.Data = E.EstablishmentGroupId
                WHERE   SAM.IsDeleted = 0

                UPDATE  SA
                SET     IsDeleted = 1 ,
                        DeletedOn = GETUTCDATE() ,
                        DeletedBy = @UserId
                FROM    dbo.SeenClientAnswers SA
                        INNER JOIN dbo.SeenClientAnswerMaster SAM ON SAM.Id = SA.SeenClientAnswerMasterId
                        INNER JOIN dbo.Establishment E ON E.Id = SAM.EstablishmentId
                        INNER JOIN dbo.Split(@ActivityIds, ',') S ON S.Data = E.EstablishmentGroupId
                WHERE   SA.IsDeleted = 0

                UPDATE  SAC
                SET     IsDeleted = 1 ,
                        DeletedOn = GETUTCDATE() ,
                        DeletedBy = @UserId
                FROM    dbo.SeenClientAnswerChild SAC
                        INNER JOIN dbo.SeenClientAnswerMaster SAM ON SAM.Id = SAC.SeenClientAnswerMasterId
                        INNER JOIN dbo.Establishment E ON E.Id = SAM.EstablishmentId
                        INNER JOIN dbo.Split(@ActivityIds, ',') S ON S.Data = E.EstablishmentGroupId
                WHERE   SAC.IsDeleted = 0

				/* AppUser */
                UPDATE  AUE
                SET     IsDeleted = 1 ,
                        DeletedOn = GETUTCDATE() ,
                        DeletedBy = @UserId
                FROM    dbo.AppUserEstablishment AUE
                        INNER JOIN dbo.Establishment E ON E.Id = AUE.EstablishmentId
                        INNER JOIN dbo.Split(@ActivityIds, ',') S ON S.Data = E.EstablishmentGroupId
                WHERE   AUE.IsDeleted = 0

                UPDATE  AUM
                SET     IsDeleted = 1 ,
                        DeletedOn = GETUTCDATE() ,
                        DeletedBy = @UserId
                FROM    dbo.AppUserModule AUM
                        INNER JOIN dbo.Split(@ActivityIds, ',') S ON S.Data = AUM.EstablishmentGroupId
                WHERE   AUM.IsDeleted = 0

                UPDATE  MU
                SET     IsDeleted = 1 ,
                        DeletedOn = GETUTCDATE() ,
                        DeletedBy = @UserId
                FROM    dbo.AppManagerUserRights MU
                        INNER JOIN dbo.Establishment E ON E.Id = MU.EstablishmentId
                        INNER JOIN dbo.Split(@ActivityIds, ',') S ON S.Data = E.EstablishmentGroupId
                WHERE   MU.IsDeleted = 0

                UPDATE  AU
                SET     IsDeleted = 1 ,
                        DeletedOn = GETUTCDATE() ,
                        DeletedBy = @UserId
                FROM    dbo.AppUser AU
                        INNER JOIN dbo.AppUserEstablishment AUE ON AUE.AppUserId = AU.Id
                        INNER JOIN dbo.Establishment E ON E.Id = AUE.EstablishmentId
                        INNER JOIN dbo.Split(@ActivityIds, ',') S ON S.Data = E.EstablishmentGroupId
                WHERE   AU.IsDeleted = 0

				/* Establishment */
                UPDATE  E
                SET     IsDeleted = 1 ,
                        DeletedOn = GETUTCDATE() ,
                        DeletedBy = @UserId
                FROM    dbo.Establishment E
                        INNER JOIN dbo.Split(@ActivityIds, ',') S ON S.Data = E.EstablishmentGroupId
                WHERE   E.IsDeleted = 0

				/* Activity */
                UPDATE  EGMA
                SET     IsDeleted = 1 ,
                        DeletedOn = GETUTCDATE() ,
                        DeletedBy = @UserId
                FROM    dbo.EstablishmentGroupModuleAlias EGMA
                        INNER JOIN dbo.Split(@ActivityIds, ',') S ON S.Data = EGMA.EstablishmentGroupId
                WHERE   EGMA.IsDeleted = 0

                UPDATE  EG
                SET     IsDeleted = 1 ,
                        DeletedOn = GETUTCDATE() ,
                        DeletedBy = @UserId
                FROM    dbo.EstablishmentGroup EG
                        INNER JOIN dbo.Split(@ActivityIds, ',') S ON S.Data = EG.Id
                WHERE   EG.IsDeleted = 0
            END

        IF @IsEstablishment = 1
            BEGIN
                IF ( @EstablishmentIds = '0' )
                    BEGIN
					/* IN */
                        UPDATE  CA
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.CloseLoopAction CA
                                INNER JOIN dbo.AnswerMaster AM ON AM.Id = CA.AnswerMasterId
                                INNER JOIN dbo.Establishment E ON E.Id = AM.EstablishmentId
                                INNER JOIN dbo.Split(@ActivityIds, ',') S ON S.Data = E.EstablishmentGroupId
                        WHERE   CA.IsDeleted = 0

                        UPDATE  AM
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.AnswerMaster AM
                                INNER JOIN dbo.Establishment E ON E.Id = AM.EstablishmentId
                                INNER JOIN dbo.Split(@ActivityIds, ',') S ON S.Data = E.EstablishmentGroupId
                        WHERE   AM.IsDeleted = 0

                        UPDATE  A
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.Answers A
                                INNER JOIN dbo.AnswerMaster AM ON AM.Id = A.AnswerMasterId
                                INNER JOIN dbo.Establishment E ON E.Id = AM.EstablishmentId
                                INNER JOIN dbo.Split(@ActivityIds, ',') S ON S.Data = E.EstablishmentGroupId
                        WHERE   A.IsDeleted = 0

						/* OUT */
                        UPDATE  CA
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.CloseLoopAction CA
                                INNER JOIN dbo.SeenClientAnswerMaster SAM ON SAM.Id = CA.SeenClientAnswerMasterId
                                INNER JOIN dbo.Establishment E ON E.Id = SAM.EstablishmentId
                                INNER JOIN dbo.Split(@ActivityIds, ',') S ON S.Data = E.EstablishmentGroupId
                        WHERE   CA.IsDeleted = 0

                        UPDATE  SAM
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.SeenClientAnswerMaster SAM
                                INNER JOIN dbo.Establishment E ON E.Id = SAM.EstablishmentId
                                INNER JOIN dbo.Split(@ActivityIds, ',') S ON S.Data = E.EstablishmentGroupId
                        WHERE   SAM.IsDeleted = 0

                        UPDATE  SA
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.SeenClientAnswers SA
                                INNER JOIN dbo.SeenClientAnswerMaster SAM ON SAM.Id = SA.SeenClientAnswerMasterId
                                INNER JOIN dbo.Establishment E ON E.Id = SAM.EstablishmentId
                                INNER JOIN dbo.Split(@ActivityIds, ',') S ON S.Data = E.EstablishmentGroupId
                        WHERE   SA.IsDeleted = 0

                        UPDATE  SAC
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.SeenClientAnswerChild SAC
                                INNER JOIN dbo.SeenClientAnswerMaster SAM ON SAM.Id = SAC.SeenClientAnswerMasterId
                                INNER JOIN dbo.Establishment E ON E.Id = SAM.EstablishmentId
                                INNER JOIN dbo.Split(@ActivityIds, ',') S ON S.Data = E.EstablishmentGroupId
                        WHERE   SAC.IsDeleted = 0

						/* AppUser */
                        UPDATE  AUE
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.AppUserEstablishment AUE
                                INNER JOIN dbo.Establishment E ON E.Id = AUE.EstablishmentId
                                INNER JOIN dbo.Split(@ActivityIds, ',') S ON S.Data = E.EstablishmentGroupId
                        WHERE   AUE.IsDeleted = 0

                        UPDATE  AUM
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.AppUserModule AUM
                                INNER JOIN dbo.Split(@ActivityIds, ',') S ON S.Data = AUM.EstablishmentGroupId
                        WHERE   AUM.IsDeleted = 0

                        UPDATE  MU
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.AppManagerUserRights MU
                                INNER JOIN dbo.Establishment E ON E.Id = MU.EstablishmentId
                                INNER JOIN dbo.Split(@ActivityIds, ',') S ON S.Data = E.EstablishmentGroupId
                        WHERE   MU.IsDeleted = 0

                        UPDATE  AU
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.AppUser AU
                                INNER JOIN dbo.AppUserEstablishment AUE ON AUE.AppUserId = AU.Id
                                INNER JOIN dbo.Establishment E ON E.Id = AUE.EstablishmentId
                                INNER JOIN dbo.Split(@ActivityIds, ',') S ON S.Data = E.EstablishmentGroupId
                        WHERE   AU.IsDeleted = 0

						/* Establishment */
                        UPDATE  E
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.Establishment E
                                INNER JOIN dbo.Split(@ActivityIds, ',') S ON S.Data = E.EstablishmentGroupId
                        WHERE   E.IsDeleted = 0
                    END
                ELSE
                    BEGIN
						/* IN */
                        UPDATE  CA
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.CloseLoopAction CA
                                INNER JOIN dbo.AnswerMaster AM ON AM.Id = CA.AnswerMasterId
                                INNER JOIN dbo.Split(@EstablishmentIds, ',') S ON S.Data = AM.EstablishmentId
                        WHERE   CA.IsDeleted = 0

                        UPDATE  AM
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.AnswerMaster AM
                                INNER JOIN dbo.Split(@EstablishmentIds, ',') S ON S.Data = AM.EstablishmentId
                        WHERE   AM.IsDeleted = 0

                        UPDATE  A
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.Answers A
                                INNER JOIN dbo.AnswerMaster AM ON AM.Id = A.AnswerMasterId
                                INNER JOIN dbo.Split(@EstablishmentIds, ',') S ON S.Data = AM.EstablishmentId
                        WHERE   A.IsDeleted = 0

						/* OUT */
                        UPDATE  CA
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.CloseLoopAction CA
                                INNER JOIN dbo.SeenClientAnswerMaster SAM ON SAM.Id = CA.SeenClientAnswerMasterId
                                INNER JOIN dbo.Split(@EstablishmentIds, ',') S ON S.Data = SAM.EstablishmentId
                        WHERE   CA.IsDeleted = 0

                        UPDATE  SAM
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.SeenClientAnswerMaster SAM
                                INNER JOIN dbo.Split(@EstablishmentIds, ',') S ON S.Data = SAM.EstablishmentId
                        WHERE   SAM.IsDeleted = 0

                        UPDATE  SA
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.SeenClientAnswers SA
                                INNER JOIN dbo.SeenClientAnswerMaster SAM ON SAM.Id = SA.SeenClientAnswerMasterId
                                INNER JOIN dbo.Split(@EstablishmentIds, ',') S ON S.Data = SAM.EstablishmentId
                        WHERE   SA.IsDeleted = 0

                        UPDATE  SAC
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.SeenClientAnswerChild SAC
                                INNER JOIN dbo.SeenClientAnswerMaster SAM ON SAM.Id = SAC.SeenClientAnswerMasterId
                                INNER JOIN dbo.Split(@EstablishmentIds, ',') S ON S.Data = SAM.EstablishmentId
                        WHERE   SAC.IsDeleted = 0

						/* AppUser */
                        UPDATE  AUE
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.AppUserEstablishment AUE
                                INNER JOIN dbo.Split(@EstablishmentIds, ',') S ON S.Data = AUE.EstablishmentId
                        WHERE   AUE.IsDeleted = 0

                        UPDATE  AUM
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.AppUserModule AUM
                                INNER JOIN dbo.AppUserEstablishment AUE ON AUE.AppUserId = AUM.AppUserId
                                INNER JOIN dbo.Split(@EstablishmentIds, ',') S ON S.Data = AUE.EstablishmentId
                        WHERE   AUM.IsDeleted = 0

                        UPDATE  MU
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.AppManagerUserRights MU
                                INNER JOIN dbo.Split(@EstablishmentIds, ',') S ON S.Data = MU.EstablishmentId
                        WHERE   MU.IsDeleted = 0

                        UPDATE  AU
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.AppUser AU
                                INNER JOIN dbo.AppUserEstablishment AUE ON AUE.AppUserId = AU.Id
                                INNER JOIN dbo.Split(@EstablishmentIds, ',') S ON S.Data = AUE.EstablishmentId
                        WHERE   AU.IsDeleted = 0

						/* Establishment */
                        UPDATE  E
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.Establishment E
                                INNER JOIN dbo.Split(@EstablishmentIds, ',') S ON S.Data = E.Id
                        WHERE   E.IsDeleted = 0
                    END
            END

        IF @IsAppUser = 1
            BEGIN
                IF ( @EstablishmentIds = '0' )
                    BEGIN
						/* IN */
                        UPDATE  CA
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.CloseLoopAction CA
                                INNER JOIN dbo.AnswerMaster AM ON AM.Id = CA.AnswerMasterId
                                INNER JOIN dbo.Establishment E ON E.Id = AM.EstablishmentId
                                INNER JOIN dbo.Split(@ActivityIds, ',') S ON S.Data = E.EstablishmentGroupId
                        WHERE   CA.IsDeleted = 0

                        UPDATE  AM
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.AnswerMaster AM
                                INNER JOIN dbo.Establishment E ON E.Id = AM.EstablishmentId
                                INNER JOIN dbo.Split(@ActivityIds, ',') S ON S.Data = E.EstablishmentGroupId
                        WHERE   AM.IsDeleted = 0

                        UPDATE  A
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.Answers A
                                INNER JOIN dbo.AnswerMaster AM ON AM.Id = A.AnswerMasterId
                                INNER JOIN dbo.Establishment E ON E.Id = AM.EstablishmentId
                                INNER JOIN dbo.Split(@ActivityIds, ',') S ON S.Data = E.EstablishmentGroupId
                        WHERE   A.IsDeleted = 0

						/* OUT */
                        UPDATE  CA
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.CloseLoopAction CA
                                INNER JOIN dbo.SeenClientAnswerMaster SAM ON SAM.Id = CA.SeenClientAnswerMasterId
                                INNER JOIN dbo.Establishment E ON E.Id = SAM.EstablishmentId
                                INNER JOIN dbo.Split(@ActivityIds, ',') S ON S.Data = E.EstablishmentGroupId
                        WHERE   CA.IsDeleted = 0

                        UPDATE  SAM
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.SeenClientAnswerMaster SAM
                                INNER JOIN dbo.Establishment E ON E.Id = SAM.EstablishmentId
                                INNER JOIN dbo.Split(@ActivityIds, ',') S ON S.Data = E.EstablishmentGroupId
                        WHERE   SAM.IsDeleted = 0

                        UPDATE  SA
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.SeenClientAnswers SA
                                INNER JOIN dbo.SeenClientAnswerMaster SAM ON SAM.Id = SA.SeenClientAnswerMasterId
                                INNER JOIN dbo.Establishment E ON E.Id = SAM.EstablishmentId
                                INNER JOIN dbo.Split(@ActivityIds, ',') S ON S.Data = E.EstablishmentGroupId
                        WHERE   SA.IsDeleted = 0

                        UPDATE  SAC
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.SeenClientAnswerChild SAC
                                INNER JOIN dbo.SeenClientAnswerMaster SAM ON SAM.Id = SAC.SeenClientAnswerMasterId
                                INNER JOIN dbo.Establishment E ON E.Id = SAM.EstablishmentId
                                INNER JOIN dbo.Split(@ActivityIds, ',') S ON S.Data = E.EstablishmentGroupId
                        WHERE   SAC.IsDeleted = 0

						/* AppUser */
                        UPDATE  AUE
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.AppUserEstablishment AUE
                                INNER JOIN dbo.Establishment E ON E.Id = AUE.EstablishmentId
                                INNER JOIN dbo.Split(@ActivityIds, ',') S ON S.Data = E.EstablishmentGroupId
                        WHERE   AUE.IsDeleted = 0

                        UPDATE  AUM
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.AppUserModule AUM
                                INNER JOIN dbo.AppUserEstablishment AUE ON AUE.AppUserId = AUM.AppUserId
                                INNER JOIN dbo.Establishment E ON E.Id = AUE.EstablishmentId
                                INNER JOIN dbo.Split(@ActivityIds, ',') S ON S.Data = E.EstablishmentGroupId
                        WHERE   AUM.IsDeleted = 0

                        UPDATE  MU
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.AppManagerUserRights MU
                                INNER JOIN dbo.Establishment E ON E.Id = MU.EstablishmentId
                                INNER JOIN dbo.Split(@ActivityIds, ',') S ON S.Data = E.EstablishmentGroupId
                        WHERE   MU.IsDeleted = 0

                        UPDATE  AU
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.AppUser AU
                                INNER JOIN dbo.AppUserEstablishment AUE ON AUE.AppUserId = AU.Id
                                INNER JOIN dbo.Establishment E ON E.Id = AUE.EstablishmentId
                                INNER JOIN dbo.Split(@ActivityIds, ',') S ON S.Data = E.EstablishmentGroupId
                        WHERE   AU.IsDeleted = 0
                    END
                ELSE
                    BEGIN
						/* IN */
                        UPDATE  CA
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.CloseLoopAction CA
                                INNER JOIN dbo.AnswerMaster AM ON AM.Id = CA.AnswerMasterId
                                INNER JOIN dbo.Split(@EstablishmentIds, ',') S ON S.Data = AM.EstablishmentId
                        WHERE   CA.IsDeleted = 0

                        UPDATE  AM
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.AnswerMaster AM
                                INNER JOIN dbo.Split(@EstablishmentIds, ',') S ON S.Data = AM.EstablishmentId
                        WHERE   AM.IsDeleted = 0

                        UPDATE  A
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.Answers A
                                INNER JOIN dbo.AnswerMaster AM ON AM.Id = A.AnswerMasterId
                                INNER JOIN dbo.Split(@EstablishmentIds, ',') S ON S.Data = AM.EstablishmentId
                        WHERE   A.IsDeleted = 0

						/* OUT */
                        UPDATE  CA
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.CloseLoopAction CA
                                INNER JOIN dbo.SeenClientAnswerMaster SAM ON SAM.Id = CA.SeenClientAnswerMasterId
                                INNER JOIN dbo.Split(@EstablishmentIds, ',') S ON S.Data = SAM.EstablishmentId
                        WHERE   CA.IsDeleted = 0

                        UPDATE  SAM
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.SeenClientAnswerMaster SAM
                                INNER JOIN dbo.Split(@EstablishmentIds, ',') S ON S.Data = SAM.EstablishmentId
                        WHERE   SAM.IsDeleted = 0

                        UPDATE  SA
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.SeenClientAnswers SA
                                INNER JOIN dbo.SeenClientAnswerMaster SAM ON SAM.Id = SA.SeenClientAnswerMasterId
                                INNER JOIN dbo.Split(@EstablishmentIds, ',') S ON S.Data = SAM.EstablishmentId
                        WHERE   SA.IsDeleted = 0

                        UPDATE  SAC
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.SeenClientAnswerChild SAC
                                INNER JOIN dbo.SeenClientAnswerMaster SAM ON SAM.Id = SAC.SeenClientAnswerMasterId
                                INNER JOIN dbo.Split(@EstablishmentIds, ',') S ON S.Data = SAM.EstablishmentId
                        WHERE   SAC.IsDeleted = 0

						/* AppUser */
                        UPDATE  AUE
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.AppUserEstablishment AUE
                                INNER JOIN dbo.Split(@EstablishmentIds, ',') S ON S.Data = AUE.EstablishmentId
                        WHERE   AUE.IsDeleted = 0

                        UPDATE  AUM
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.AppUserModule AUM
                                INNER JOIN dbo.AppUserEstablishment AUE ON AUE.AppUserId = AUM.AppUserId
                                INNER JOIN dbo.Split(@EstablishmentIds, ',') S ON S.Data = AUE.EstablishmentId
                        WHERE   AUM.IsDeleted = 0

                        UPDATE  MU
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.AppManagerUserRights MU
                                INNER JOIN dbo.Split(@EstablishmentIds, ',') S ON S.Data = MU.EstablishmentId
                        WHERE   MU.IsDeleted = 0

                        UPDATE  AU
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        FROM    dbo.AppUser AU
                                INNER JOIN dbo.AppUserEstablishment AUE ON AUE.AppUserId = AU.Id
                                INNER JOIN dbo.Split(@EstablishmentIds, ',') S ON S.Data = AUE.EstablishmentId
                        WHERE   AU.IsDeleted = 0
                    END
            END
    END