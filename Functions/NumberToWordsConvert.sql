
CREATE FUNCTION [dbo].[NumberToWordsConvert]
(
	@arg numeric(15)
)
RETURNS varchar(5000)
AS
BEGIN
	-- Declare the return variable here
		DECLARE @Mappings TABLE (aIndex int , aValue varchar(100))
		DECLARE @temp varchar(100)
		DECLARE @t1 numeric(15), @t2 numeric(15)
		DECLARE @ret_str varchar(5000)
		set @ret_str = ''
        Insert into @Mappings values (0,'')
        Insert into @Mappings values (1,'One')
        Insert into @Mappings values (2,'Two')
		Insert into @Mappings values (3, 'Three')
        Insert into @Mappings values (4, 'Four')
        Insert into @Mappings values (5, 'Five')
        Insert into @Mappings values (6, 'Six')
        Insert into @Mappings values (7, 'Seven')
        Insert into @Mappings values (8, 'Eight')
        Insert into @Mappings values (9, 'Nine')
        Insert into @Mappings values (10, 'Ten')
        Insert into @Mappings values (11, 'Eleven')
        Insert into @Mappings values (12, 'Twelve')
        Insert into @Mappings values (13, 'Thirteen')
        Insert into @Mappings values (14, 'Fourteen')
        Insert into @Mappings values (15, 'Fifteen')
        Insert into @Mappings values (16, 'Sixteen')
        Insert into @Mappings values (17, 'Seventeen')
        Insert into @Mappings values (18, 'Eighteen')
        Insert into @Mappings values (19, 'Nineteen;')
        Insert into @Mappings values (20, 'Twenty')
        Insert into @Mappings values (21, 'Twenty One;')
        Insert into @Mappings values (22, 'Twenty Two')
        Insert into @Mappings values (23, 'Twenty Three')
        Insert into @Mappings values (24, 'Twenty Four')
        Insert into @Mappings values (25, 'Twenty Five')
        Insert into @Mappings values (26, 'Twenty Six')
        Insert into @Mappings values (27, 'Twenty Seven')
        Insert into @Mappings values (28, 'Twenty Eight')
        Insert into @Mappings values (29, 'Twenty Nine')
        Insert into @Mappings values (30, 'Thirty')
        Insert into @Mappings values (31, 'Thirty One')
        Insert into @Mappings values (32, 'Thirty Two')
        Insert into @Mappings values (33, 'Thirty Three')
        Insert into @Mappings values (34, 'Thirty Four')
        Insert into @Mappings values (35, 'Thirty Five')
        Insert into @Mappings values (36, 'Thirty Six')
        Insert into @Mappings values (37, 'Thirty Seven')
        Insert into @Mappings values (38, 'Thirty Eight')
        Insert into @Mappings values (39, 'Thirty Nine')
        Insert into @Mappings values (40, 'Fourty')
        Insert into @Mappings values (41, 'Fourty One')
        Insert into @Mappings values (42, 'Fourty Two')
        Insert into @Mappings values (43, 'Fourty Three')
        Insert into @Mappings values (44, 'Fourty Four')
        Insert into @Mappings values (45, 'Fourty Five')
        Insert into @Mappings values (46, 'Fourty Six')
        Insert into @Mappings values (47, 'Fourty Seven')
        Insert into @Mappings values (48, 'Fourty Eight')
        Insert into @Mappings values (49, 'Fourty Nine')
        Insert into @Mappings values (50, 'Fifty')
        Insert into @Mappings values (51, 'Fifty One')
        Insert into @Mappings values (52, 'Fifty Two')
        Insert into @Mappings values (53, 'Fifty Three')
        Insert into @Mappings values (54, 'Fifty Four')
        Insert into @Mappings values (55, 'Fifty Five')
        Insert into @Mappings values (56, 'Fifty Six')
        Insert into @Mappings values (57, 'Fifty Seven')
        Insert into @Mappings values (58, 'Fifty Eight')
        Insert into @Mappings values (59, 'Fifty Nine')
        Insert into @Mappings values (60, 'Sixty')
        Insert into @Mappings values (61, 'Sixty One')
        Insert into @Mappings values (62, 'Sixty Two')
        Insert into @Mappings values (63, 'Sixty Three')
        Insert into @Mappings values (64, 'Sixty Four')
        Insert into @Mappings values (65, 'Sixty Five')
        Insert into @Mappings values (66, 'Sixty Six')
        Insert into @Mappings values (67, 'Sixty Seven')
        Insert into @Mappings values (68, 'Sixty Eight')
        Insert into @Mappings values (69, 'Sixty Nine')
        Insert into @Mappings values (70, 'Seventy')
        Insert into @Mappings values (71, 'Seventy One')
        Insert into @Mappings values (72, 'Seventy Two')
        Insert into @Mappings values (73, 'Seventy Three')
        Insert into @Mappings values (74, 'Seventy Four')
        Insert into @Mappings values (75, 'Seventy Five')
        Insert into @Mappings values (76, 'Seventy Six')
        Insert into @Mappings values (77, 'Seventy Seven')
        Insert into @Mappings values (78, 'Seventy Eight')
        Insert into @Mappings values (79, 'Seventy Nine')
        Insert into @Mappings values (80, 'Eighty')
        Insert into @Mappings values (81, 'Eighty One')
        Insert into @Mappings values (82, 'Eighty Two')
        Insert into @Mappings values (83, 'Eighty Three')
        Insert into @Mappings values (84, 'Eighty Four')
        Insert into @Mappings values (85, 'Eighty Five')
        Insert into @Mappings values (86, 'Eighty Six')
        Insert into @Mappings values (87, 'Eighty Seven')
        Insert into @Mappings values (88, 'Eighty Eight')
        Insert into @Mappings values (89, 'Eighty Nine')
        Insert into @Mappings values (90, 'Ninty')
        Insert into @Mappings values (91, 'Ninty One')
        Insert into @Mappings values (92, 'Ninty Two')
        Insert into @Mappings values (93, 'Ninty Three')
        Insert into @Mappings values (94, 'Ninty Four')
        Insert into @Mappings values (95, 'Ninty Five')
        Insert into @Mappings values (96, 'Ninty Six')
        Insert into @Mappings values (97, 'Ninty Seven')
        Insert into @Mappings values (98, 'Ninty Eight')
        Insert into @Mappings values (99, 'Ninty Nine')
        Insert into @Mappings values (100, 'Hundred')
        Insert into @Mappings values (200, 'Two Hundred')
        Insert into @Mappings values (300, 'Three Hundred')
        Insert into @Mappings values (400, 'Four Hundred')
        Insert into @Mappings values (500, 'Five Hundred')
        Insert into @Mappings values (600, 'Six Hundred')
        Insert into @Mappings values (700, 'Seven Hundred')
        Insert into @Mappings values (800, 'Eight Hundred')
        Insert into @Mappings values (900, 'Nine Hundred')
        
        
                
        If @arg >= 10000000
        Begin
            set @t1 = @arg % 10000000
            set @t2 = floor(@arg/10000000)
            set @ret_str = dbo.NumberToWordsConvert(@t2) + ' Crore ' + dbo.NumberToWordsConvert(@t1)
        End
        
        else if @arg >= 100000
        Begin
            set @t1 = @arg % 100000
            set @t2 = floor(@arg/100000)
            select @temp=aValue from @Mappings where aIndex = @t2
            set @ret_str = @temp + ' Lakh ' + dbo.NumberToWordsConvert(@t1)
        End
                
        else if @arg >= 1000
        Begin
            set @t1 = @arg % 1000
            set @t2 = floor(@arg/1000)
            select @temp=aValue from @Mappings where aIndex = @t2
            set @ret_str = @temp + ' Thousand ' + dbo.NumberToWordsConvert(@t1)
        End
		
        else if @arg >= 100
        Begin
            set @t1 = @arg % 100
            set @t2 = @arg - @t1
            select @temp=aValue from @Mappings where aIndex = @t2
            set @ret_str = @ret_str + @temp + ' ' + dbo.NumberToWordsConvert(@t1)
        End
		else if @arg < 100
        Begin
			select @temp=aValue from @Mappings where aIndex = @arg
			set @ret_str = @ret_str + @temp + ' '
        End

		return UPPER(rtrim(@ret_str))

END