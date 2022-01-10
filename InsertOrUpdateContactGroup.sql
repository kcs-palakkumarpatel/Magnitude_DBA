-- =============================================  
-- Author:			Sunil Vaghasiya
-- Create date:	09-June-2017
-- Description:	Description,,InsertOrUpdateContactGroup
-- Call:					InsertOrUpdateContactGroup  
-- =============================================  
CREATE PROCEDURE [dbo].[InsertOrUpdateContactGroup]
    @Id BIGINT ,
    @GroupId BIGINT ,
    @ContactGropName NVARCHAR(50) ,
    @Description NVARCHAR(50) ,
    @ExistingContact NVARCHAR(MAX) ,
	@ExistingGroup NVARCHAR(MAX),
    @DeletedContact NVARCHAR(MAX) ,
    @UserId BIGINT ,
    @PageId BIGINT,
	@IsCreatedByCapture BIT    
AS
    BEGIN
	
	if @GroupId = 0
		SET @GroupId = (Select GroupId From AppUser where id = @UserId)

			DECLARE @table TABLE (
				id BIGINT,Value BIGINT)

					DECLARE @table1 TABLE (
				id BIGINT,Value NVARCHAR(max))

        IF ( @Id = 0 )
		BEGIN
    IF ( @ExistingGroup != '' )
                BEGIN
                    INSERT  INTO @table
                            ( id ,
                              Value
                            )
                            SELECT  1 ,
                                    ContactMasterId
                            FROM    dbo.ContactGroupRelation
                                    INNER JOIN dbo.ContactMaster ON ContactMaster.Id = ContactGroupRelation.ContactMasterId
                                                              AND ContactMaster.IsDeleted = 0
                            WHERE   ContactGroupRelation.IsDeleted = 0
                                    AND ContactGroupId IN (
                                    SELECT  Data
                                    FROM    dbo.Split(@ExistingGroup, ',') ) GROUP BY ContactMasterId; 
                    INSERT  INTO @table1
                            ( id ,
                              Value
                            )
                            SELECT  id ,
                                    STUFF((SELECT   ', '
                                                    + CAST(Value AS VARCHAR(10)) [text()]
                                           FROM     @table
                                           WHERE    id = t.id
                                    FOR   XML PATH('') ,
                                              TYPE)
        .value('.', 'NVARCHAR(MAX)'), 1, 2, ' ') ExistingContact
                            FROM    @table t
                            GROUP BY id;
                    SELECT  @ExistingContact = @ExistingContact + ',';
                    SELECT  @ExistingContact += Value
                    FROM    @table1;
                END;

                INSERT  INTO dbo.[ContactGroup]
                        ( [ContactGropName] ,
                          [GroupId] ,
                          [Description] ,
						  [IsCreatedByCapture],
                          [CreatedOn] ,
                          [CreatedBy] ,
                          [IsDeleted]  
                        )
                VALUES  ( ISNULL(@ContactGropName,'I as DR') ,
                          @GroupId ,
                          @Description ,
						  @IsCreatedByCapture,
                          GETUTCDATE() ,
                          @UserId ,
                          0  
                        )  
                SELECT  @Id = SCOPE_IDENTITY()  
                INSERT  INTO dbo.ActivityLog
                        ( UserId ,
                          PageId ,
                          AuditComments ,
                          TableName ,
                          RecordId ,
                          CreatedOn ,
                          CreatedBy ,
                          IsDeleted   
                        )
                VALUES  ( @UserId ,
                          @PageId ,
                          'Insert record in table ContactGroup' ,
                          'ContactGroup' ,
                          @Id ,
                          GETUTCDATE() ,
                          @UserId ,
                          0  
                        )  
                IF @ExistingContact IS NOT NULL
                    AND @ExistingContact <> ''
                    BEGIN  
                        INSERT  INTO dbo.ContactGroupRelation
                                ( ContactMasterId ,
                                  ContactGroupId ,
                                  CreatedBy  
                                )
                                SELECT DISTINCT Data ,
                                        @Id ,
                                        @UserId
                                FROM    dbo.Split(@ExistingContact, ',')
                    END  

					--IF @ExistingGroup IS NOT NULL
     --               AND @ExistingGroup <> ''
     --               BEGIN  
     --                   INSERT  INTO dbo.ContactGroupRelation
     --                           ( ContactMasterId ,
     --                             ContactGroupId ,
     --                             CreatedBy  
     --                           )
     --                           SELECT DISTINCT Data ,
     --                                   @Id ,
     --                                   @UserId
     --                           FROM    dbo.Split(@ExistingGroup, ',')
     --               END  

				END
       ELSE
            BEGIN  

            IF ( @ExistingGroup != '' )
                BEGIN
                    INSERT  INTO @table
                            ( id ,
                              Value
                            )
                            SELECT  1 ,
                                    ContactMasterId
                            FROM    dbo.ContactGroupRelation
                                    INNER JOIN dbo.ContactMaster ON ContactMaster.Id = ContactGroupRelation.ContactMasterId
                                                              AND ContactMaster.IsDeleted = 0
                            WHERE   ContactGroupRelation.IsDeleted = 0
                                    AND ContactGroupId IN (
                                    SELECT  Data
                                    FROM    dbo.Split(@ExistingGroup, ',') ) GROUP BY ContactMasterId; 
                    INSERT  INTO @table1
                            ( id ,
                              Value
                            )
                            SELECT  id ,
                                    STUFF((SELECT   ', '
                                                    + CAST(Value AS VARCHAR(10)) [text()]
                                           FROM     @table
                                           WHERE    id = t.id
                                    FOR   XML PATH('') ,
                                              TYPE)
        .value('.', 'NVARCHAR(MAX)'), 1, 2, ' ') ExistingContact
                            FROM    @table t
                            GROUP BY id;
                    SELECT  @ExistingContact = @ExistingContact + ',';
                    SELECT  @ExistingContact += Value
                    FROM    @table1;
                END;

                UPDATE  dbo.[ContactGroup]
                SET     [ContactGropName] = ISNULL(@ContactGropName,'I as DR') ,
                        [Description] = @Description ,
                        [UpdatedOn] = GETUTCDATE() ,
                        [UpdatedBy] = @UserId
                WHERE   [Id] = @Id  
                INSERT  INTO dbo.ActivityLog
                        ( UserId ,
                          PageId ,
                          AuditComments ,
                          TableName ,
                          RecordId ,
                          CreatedOn ,
                          CreatedBy ,
                          IsDeleted   
                        )
                VALUES  ( @UserId ,
                          @PageId ,
                          'Update record in table ContactGroup' ,
                          'ContactGroup' ,
                          @Id ,
                          GETUTCDATE() ,
                          @UserId ,
                          0  
                        )  
                IF @DeletedContact IS NOT NULL
                    AND @DeletedContact <> ''
                    BEGIN                
                        UPDATE  dbo.ContactGroupRelation
                        SET     IsDeleted = 1 ,
                                DeletedOn = GETUTCDATE() ,
                                DeletedBy = @UserId
                        WHERE   ContactMasterId IN (
                                SELECT  Data
                                FROM    dbo.Split(@DeletedContact, ',') )
                                AND ContactGroupId = @Id  /* Disha - 07-OCT-2016 - Added condition for deleting contacts of Updating Group as it was deleting all contacts in all groups */
                    END
                --ELSE
                --    BEGIN
                --        UPDATE  dbo.ContactGroupRelation
                --        SET     IsDeleted = 1 ,
                --                DeletedOn = GETUTCDATE() ,
                --                DeletedBy = @UserId
                --        WHERE   ContactMasterId IN (
                --                SELECT  ContactMasterId
                --                FROM    ContactGroupRelation
                --                WHERE   ContactGroupId = @Id ) 
                --    END
                  
                IF @ExistingContact IS NOT NULL
                    AND @ExistingContact <> ''
                    BEGIN  
                        INSERT  INTO dbo.ContactGroupRelation
                                ( ContactMasterId ,
                                  ContactGroupId ,
                                  CreatedBy  
                                )
                                SELECT  DISTINCT Data ,
                                        @Id ,
                                        @UserId
                                FROM    dbo.Split(@ExistingContact, ',')
                                WHERE   Data NOT IN (
                                        SELECT  ContactMasterId
                                        FROM    dbo.ContactGroupRelation
                                        WHERE   ContactGroupId = @Id
                                                AND IsDeleted = 0 )  
                    END  
            END  
        SELECT  ISNULL(@Id, 0) AS InsertedId  
    END
