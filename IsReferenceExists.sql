  
-- =============================================  
-- Author:  <Author,,GD>  
-- Create date: <Create Date,,18 Oct 2014>  
-- Description: <Description,,Check reference Before delete records>  
-- Call SP    : IsReferenceExists 'ContactRole',6,0
 
-- =============================================  
CREATE PROCEDURE [dbo].[IsReferenceExists]  
    @Tablename NVARCHAR(MAX) ,  
    @Id BIGINT ,  
    @IsExists BIT OUT  
AS   
    BEGIN      
        DECLARE @ResultSet TABLE  
            (  
              [Id] BIGINT IDENTITY(1, 1) ,  
              [TableName] VARCHAR(MAX) ,  
              [ColumnName] VARCHAR(MAX) ,  
              [Flag] BIT  
            )      
       
        INSERT  INTO @ResultSet  
                SELECT  K_Table = FK.TABLE_NAME ,  
                        FK_Column = CU.COLUMN_NAME ,  
                        0 AS Flag  
                FROM    INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS C  
                        INNER JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS FK ON C.CONSTRAINT_NAME = FK.CONSTRAINT_NAME  
                        INNER JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS PK ON C.UNIQUE_CONSTRAINT_NAME = PK.CONSTRAINT_NAME  
                        INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE CU ON C.CONSTRAINT_NAME = CU.CONSTRAINT_NAME  
                        INNER JOIN ( SELECT i1.TABLE_NAME ,  
                                            i2.COLUMN_NAME  
                                     FROM   INFORMATION_SCHEMA.TABLE_CONSTRAINTS i1  
                                            INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE i2 ON i1.CONSTRAINT_NAME = i2.CONSTRAINT_NAME  
                                     WHERE  i1.CONSTRAINT_TYPE = 'PRIMARY KEY'  
                                   ) PT ON PT.TABLE_NAME = PK.TABLE_NAME  
                WHERE   PK.TABLE_NAME = @Tablename  
                ORDER BY 1 ,  
                        2      
       
        DECLARE @NewId BIGINT ,  
            @NewTableName VARCHAR(MAX) ,  
            @NewColumnName VARCHAR(MAX)      
        DECLARE @Sql NVARCHAR(MAX) ,  
            @RefCount INT ,  
            @Return BIGINT = 0      
        DECLARE @Parameter_Definition NVARCHAR(MAX)      
        SET @Parameter_Definition = N'@Count_out int OUTPUT'      
      
        UPDATE  @ResultSet  
        SET     Flag = 1  
        WHERE   TableName IN ( 'RolePermissions', 'UserLog',  
                               'AppUserEstablishment', 'CloseLoopTemplate',  
                               'AppUserModule', 'EstablishmentGroupImage' )  
  
        IF @Tablename = 'SeenClient'   
            BEGIN  
                UPDATE  @ResultSet  
                SET     Flag = 1  
                WHERE   TableName IN ( 'SeenClientQuestions' )  
            END  
        ELSE   
            IF @Tablename = 'Contact'   
                BEGIN  
                    UPDATE  @ResultSet  
                    SET     Flag = 1  
                    WHERE   TableName IN ( 'ContactQuestions' )  
                END  
            ELSE   
                IF @Tablename = 'Questionnaire'   
                    BEGIN  
                        UPDATE  @ResultSet  
                        SET     Flag = 1  
                        WHERE   TableName IN ( 'Questions' )  
                    END   
                ELSE   
                    IF @Tablename = 'ContactMaster'   
                        BEGIN  
                            UPDATE  @ResultSet  
                            SET     Flag = 1  
                            WHERE   TableName IN ( 'ContactDetails' ,'ContactGroupRelation','SeenClientAnswerChild','SeenClientAnswerMaster')  
                        END  
                    ELSE   
                        IF @Tablename = 'ContactGroup'   
                            BEGIN  
                                UPDATE  @ResultSet  
                                SET     Flag = 1  
                            END  
              Else 
			            IF @Tablename = 'Theme'   
                            BEGIN  
                                UPDATE  @ResultSet  
                                SET     Flag = 1  
								  WHERE   TableName IN ( 'ThemeImage') 
                            END  
			  ELSE 
			            IF @Tablename = 'ContactRole'   
                            BEGIN  
                                UPDATE  @ResultSet  
                                SET     Flag = 1  
								  WHERE   TableName IN ( 'ContactRoleDetails','ContactRoleActivity','ContactRoleEstablishment') 
                            END  

        WHILE EXISTS ( SELECT   *  
                       FROM     @ResultSet  
                       WHERE    Flag = 0 )   
            BEGIN      
                SELECT TOP 1  
                        @NewId = Id ,  
                    @NewTableName = TableName ,  
                        @NewColumnName = ColumnName  
                FROM    @ResultSet  
                WHERE   Flag = 0      
                PRINT @NewTableName      
                PRINT @NewColumnName      
                IF ( ( SELECT   COUNT(*)  
                       FROM     INFORMATION_SCHEMA.COLUMNS  
                       WHERE    COLUMN_NAME LIKE '%IsDeleted%'  
                                AND TABLE_NAME = @NewTableName  
                     ) > 0 )   
                    BEGIN         
                        SET @Sql = N' SELECT @Count_out = COUNT('  
                            + @NewColumnName + ') FROM [' + @NewTableName  
                            + '] WHERE ' + @NewColumnName + ' = '  
                            + CONVERT(NVARCHAR, @Id) + ' AND IsDeleted = 0'      
                        PRINT @Sql      
                        EXEC sp_executesql @Sql, @Parameter_Definition,  
                            @Count_out = @RefCount OUTPUT      
                        IF @RefCount > 0   
                            BEGIN      
                                SET @Return = @Return + 1      
                            END      
                    END      
                ELSE   
                    BEGIN      
                        SET @Sql = N' SELECT @Count_out = COUNT('  
                            + @NewColumnName + ') FROM ' + @NewTableName  
                            + ' WHERE ' + @NewColumnName + ' = '  
                            + CONVERT(NVARCHAR, @Id) + ''      
                        PRINT @Sql      
                        EXEC sp_executesql @Sql, @Parameter_Definition,  
                            @Count_out = @RefCount OUTPUT      
                        IF @RefCount > 0   
                            BEGIN      
                                SET @Return = @Return + 1      
                            END      
                    END      
                UPDATE  @ResultSet  
                SET     Flag = 1  
                WHERE   Id = @NewId        
            END      
        PRINT @Return  
        IF ( @Return > 0 )   
            BEGIN      
                SET @IsExists = 1      
            END      
        ELSE   
            BEGIN      
                SET @IsExists = 0      
            END      
    END