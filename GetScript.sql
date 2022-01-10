CREATE FUNCTION GetScript
    (
      @DatabaseName NVARCHAR(100) ,
      @SpName NVARCHAR(500) ,
      @Prefixname NVARCHAR(50) ,
      @RemoveWord NVARCHAR(200) ,
      @FilePath NVARCHAR(200)
    )
RETURNS INT
AS
    BEGIN
		
        DECLARE @StoreProcedureName NVARCHAR(500);
		
        DECLARE @procs TABLE
            (
              objectid INT ,
              definition NVARCHAR(MAX) ,
              uses_ansi_nulls BIT ,
              uses_quoted_identifier BIT
            );

        INSERT  INTO @procs
                SELECT  m.object_id ,
                        m.definition ,
                        m.uses_ansi_nulls ,
                        m.uses_quoted_identifier
                FROM    sys.sql_modules AS m
                        INNER JOIN sys.objects AS o ON m.object_id = o.object_id
                                                       AND o.object_id = OBJECT_ID(@SpName)
                WHERE   o.type = 'P';



        DECLARE @endStmt NCHAR(6) ,
            @object_id INT ,
            @definition NVARCHAR(MAX) ,
            @uses_ansi_nulls BIT ,
            @uses_quoted_identifier BIT ,
            @NewSpName NVARCHAR(500) ,
            @LineContain NVARCHAR(MAX) ,
            @Cmd VARCHAR(500);

            
        DECLARE @xstate INT;
        DECLARE @OLE INT; 
        DECLARE @FileID INT; 
        
        IF @RemoveWord <> ''
            BEGIN
                SET @StoreProcedureName = REPLACE(@SpName, @RemoveWord, '');
            END;
        ELSE
            SET @StoreProcedureName = @SpName;
        
        
        SET @NewSpName = @Prefixname + @StoreProcedureName;
        DECLARE @File VARCHAR(100) = @FilePath + @NewSpName + '.sql';
		
        DECLARE @Result BIT;
        SELECT  @Result = dbo.fc_FileExists(@File);

        IF @Result > 0
            BEGIN
                SET @Cmd = 'Del ' + @File;
                EXEC xp_cmdshell @Cmd;
            END;
	      
      
        SELECT  @object_id = objectid ,
                @endStmt = CHAR(13) + CHAR(10) + 'GO' + CHAR(13) + CHAR(10)
        FROM    @procs;

        
        EXECUTE sp_OACreate 'Scripting.FileSystemObject', @OLE OUT; 
        EXECUTE sp_OAMethod @OLE, 'OpenTextFile', @FileID OUT, @File, 8, 1; 
		

        WHILE ISNULL(@object_id, 0) > 0
            BEGIN
                SELECT  @definition = definition ,
                        @uses_ansi_nulls = uses_ansi_nulls ,
                        @uses_quoted_identifier = uses_quoted_identifier
                FROM    @procs;
		


                SET @LineContain = @DatabaseName;
                EXECUTE sp_OAMethod @FileID, 'WriteLine', NULL, @LineContain;

                SET @LineContain = @endStmt;
                EXECUTE sp_OAMethod @FileID, 'WriteLine', NULL, @LineContain;


                IF @uses_ansi_nulls = 1
                    BEGIN
                        SET @LineContain = 'SET ANSI_NULLS ON' + @endStmt;
                        EXECUTE sp_OAMethod @FileID, 'WriteLine', NULL,
                            @LineContain;
                    END;
                ELSE
                    BEGIN
                        SET @LineContain = 'SET ANSI_NULLS OFF' + @endStmt;
                        EXECUTE sp_OAMethod @FileID, 'WriteLine', NULL,
                            @LineContain;
                    END;


                IF @uses_quoted_identifier = 1
                    BEGIN
                        SET @LineContain = 'SET QUOTED_IDENTIFIER ON'
                            + @endStmt;
                        EXECUTE sp_OAMethod @FileID, 'WriteLine', NULL,
                            @LineContain;
                    END;
                ELSE
                    BEGIN
                        SET @LineContain = 'SET QUOTED_IDENTIFIER OFF'
                            + @endStmt;
                        EXECUTE sp_OAMethod @FileID, 'WriteLine', NULL,
                            @LineContain;
                    END;
		

                SET @LineContain = 'IF EXISTS(SELECT name FROM sys.procedures WHERE name = '
                    + QUOTENAME(@NewSpName, '''') + ')'; 
                EXECUTE sp_OAMethod @FileID, 'WriteLine', NULL, @LineContain;

                SET @LineContain = '	BEGIN';
                EXECUTE sp_OAMethod @FileID, 'WriteLine', NULL, @LineContain;

                SET @LineContain = '		DROP PROCEDURE ' + @NewSpName;
                EXECUTE sp_OAMethod @FileID, 'WriteLine', NULL, @LineContain;

                SET @LineContain = '	END';
                EXECUTE sp_OAMethod @FileID, 'WriteLine', NULL, @LineContain;


                SET @LineContain = @endStmt;
                EXECUTE sp_OAMethod @FileID, 'WriteLine', NULL, @LineContain;
		
                SET @definition = REPLACE(@definition, @SpName, @NewSpName);
                IF LEN(@definition) <= 4000
                    BEGIN
                        SET @LineContain = dbo.RemoveCommentsfromSP(@definition);
                        EXECUTE sp_OAMethod @FileID, 'WriteLine', NULL,
                            @LineContain;
                    END;
                ELSE
                    BEGIN
                        DECLARE @crlf VARCHAR(2) ,
                            @len BIGINT ,
                            @offset BIGINT ,
                            @part BIGINT;
                        SELECT  @crlf = CHAR(13) + CHAR(10) ,
                                @len = LEN(@definition) ,
                                @offset = 1 ,
                                @part = CHARINDEX(@crlf, @definition) - 1;
				
                        WHILE @offset <= @len
                            BEGIN
					
					
                                SET @LineContain = SUBSTRING(@definition,
                                                             @offset, @part);
                                
                                SET @LineContain = dbo.RemoveCommentsfromSP(@LineContain);
                                IF @LineContain <> ''
                                    BEGIN
                                        EXECUTE sp_OAMethod @FileID,
                                            'WriteLine', NULL, @LineContain;
                                    END;

                                SET @offset = @offset + @part + LEN(@crlf);
                                SET @part = CHARINDEX(@crlf, @definition,
                                                      @offset) - @offset;  
                            END;
                    END;

                SET @LineContain = @endStmt;
                EXECUTE sp_OAMethod @FileID, 'WriteLine', NULL, @LineContain;

                SET @object_id = 0;
            END;
            
        SET @LineContain = 'IF EXISTS(SELECT name FROM sys.procedures WHERE name = '
            + QUOTENAME(@SpName, '''') + ')'; 
        EXECUTE sp_OAMethod @FileID, 'WriteLine', NULL, @LineContain;

        SET @LineContain = '	BEGIN';
        EXECUTE sp_OAMethod @FileID, 'WriteLine', NULL, @LineContain;

        SET @LineContain = '		DROP PROCEDURE ' + @SpName;
        EXECUTE sp_OAMethod @FileID, 'WriteLine', NULL, @LineContain;

        SET @LineContain = '	END';
        EXECUTE sp_OAMethod @FileID, 'WriteLine', NULL, @LineContain;

        SET @LineContain = @endStmt;
        EXECUTE sp_OAMethod @FileID, 'WriteLine', NULL, @LineContain;
        
        
        EXECUTE sp_OADestroy @FileID; 
        EXECUTE sp_OADestroy @OLE; 
        
                        
        RETURN 1;
    END;