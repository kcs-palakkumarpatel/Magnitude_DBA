  
-- =============================================  
-- Author:  <Author,,Name>  
-- Create date: <Create Date,,>  
-- Description: <Description,,>  
-- =============================================  
  
--select Split ('asdfd,b,c,d,e',',')  
  
CREATE FUNCTION [dbo].[Split_Withspace]  
(  
 @RowData varchar(8000),  
 @SplitOn nvarchar(5)  
)    
RETURNS @RtnValue table   
(  
 Id int identity(1,1),  
 Data varchar(8000)  
)   
AS    
BEGIN   
 Declare @Cnt int  
 Set @Cnt = 1  
  
 While (Charindex(@SplitOn,@RowData)>0)  
 Begin  
  Insert Into @RtnValue (data)  
  Select   
   Data = ltrim(rtrim(Substring(@RowData,1,Charindex(@SplitOn,@RowData)-1)))  
  
  Set @RowData = Substring(@RowData,Charindex(@SplitOn,@RowData)+1,len(@RowData))  
  Set @Cnt = @Cnt + 1  
 End  
   
 Insert Into @RtnValue (data)  
 Select Data = ltrim(rtrim(@RowData))  
  
 Return  
END