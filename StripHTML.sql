CREATE FUNCTION dbo.StripHTML( @text varchar(max) ) returns varchar(max) as
begin
    declare @textXML xml
    declare @result varchar(max)
    set @textXML  =CAST((SELECT REPLACE(@text,'&','') FOR XML PATH('')) as XML) ;
	--SET @textXML = REPLACE(@text,CHAR(39),CHAR(34));
    with doc(contents) as
    (
        select chunks.chunk.query('.') from @textXML.nodes('/') as chunks(chunk)
    )
    select @result = contents.value('.', 'varchar(max)') from doc
    return @result
end
