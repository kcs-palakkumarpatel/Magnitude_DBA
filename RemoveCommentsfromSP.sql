
CREATE FUNCTION RemoveCommentsfromSP
    (
      @SqlText AS NVARCHAR(MAX)
    )
RETURNS NVARCHAR(MAX)
AS
    BEGIN
    
        DECLARE @definition NVARCHAR(MAX);
        DECLARE @vbCrLf CHAR(2);
		
        SET @definition = @SqlText;
        SET @vbCrLf = CHAR(13) + CHAR(10);  
      
		IF CHARINDEX(@vbCrLf, @definition, CHARINDEX('--', @definition)) =0
			SET @definition = @definition + @vbCrLf      
      
        WHILE CHARINDEX('/*', @definition) > 0
            SELECT  @definition = STUFF(@definition,
                                        CHARINDEX('/*', @definition),
                                        CHARINDEX('*/', @definition)
                                        - CHARINDEX('/*', @definition) + 2, '');
	--===== Replace all single line comments

        WHILE CHARINDEX('--', @definition) > 0
            AND CHARINDEX(@vbCrLf, @definition, CHARINDEX('--', @definition)) > CHARINDEX('--',
                                                              @definition)
            SELECT  @definition = STUFF(@definition,
                                        CHARINDEX('--', @definition),
                                        CHARINDEX(@vbCrLf, @definition,
                                                  CHARINDEX('--', @definition))
                                        - CHARINDEX('--', @definition) + 2, '');
		
        RETURN REPLACE(@definition ,CHAR(13) + CHAR(10) , ' ');
    END;