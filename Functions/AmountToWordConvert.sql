--SELECT dbo.AmountToWordConvert(0.26)
--SELECT dbo.AmountToWordConvert(1.26)
--select dbo.AmountToWordConvert(19600)
CREATE FUNCTION [dbo].[AmountToWordConvert] 
	(
		@amt numeric(15,2)
	)
RETURNS varchar(5000)
AS
	BEGIN
		DECLARE @Rps bigint, 
				@Ps int,
				@amtstr varchar(5000)

        --On Error Resume Next
        If @amt > 100000000000000
        begin
			return ''
        end
        
        set @Ps = (@amt % 1) * 100
        set @Rps = floor(@amt)
        If @Rps > 0 AND @Ps > 0
        Begin
        
        
            set  @amtstr = dbo.NumberToWordsConvert(@Rps) + ' Rupees And ' + dbo.NumberToWordsConvert(@Ps) +  ' Paisa Only '
        End
        
        else If @Rps > 0 AND @Ps = 0
        Begin
        
        
            set  @amtstr = dbo.NumberToWordsConvert(@Rps) + ' Rupees Only '
        End
        else If @Rps = 0 AND @Ps > 0
        Begin
        
            set  @amtstr = dbo.NumberToWordsConvert(@Ps) + ' Paisa Only '
        End
	RETURN @amtstr
	END