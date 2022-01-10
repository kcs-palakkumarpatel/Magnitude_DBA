
  
CREATE view [dbo].[BI_Vw_DimDate]  
as      
select datekey,Date,IsWeekend ,WeekOfMonth,    
Month,MonthName,SubString(MonthName,1,3) as Small_MonthName,Year,QuarterName,FirstDayOfMonth,LastDayOfMonth,    
FirstDayOfQuarter,LastDayOfQuarter,    
case when Date <= GETDATE()-1 and DATEPART(QUARTER, GETDATE()-1)= Quarter and Year(GETDATE()-1)= year then 'Y' else 'N' end QTD,      
case when Date <= GETDATE()-1 and  Year(GETDATE()-1)= year then 'Y' else 'N' end YTD,      
case when Date <= GETDATE()-1 and Month(GETDATE()-1)= month and Year(GETDATE()-1)= year then 'Y' else 'N' end MTD,    
Quarter,      
     
case when Date <= DATEADD(year, -1, GETDATE()-1) and Month(DATEADD(year, -1, GETDATE()-1))= month and Year(DATEADD(year, -1, GETDATE()-1))= year then 'Y' else 'N' end PriorMTD,      
case when Date <= DATEADD(year, -1, GETDATE()-1) and DATEPART(QUARTER,DATEADD(year, -1, GETDATE()-1))= Quarter and Year(DATEADD(year, -1, GETDATE()-1))= year then 'Y' else 'N' end PriorQTD,      
case when Date <= DATEADD(year, -1, GETDATE()-1)  and Year(DATEADD(year, -1, GETDATE()-1))= year then 'Y' else 'N' end PriorYTD,  
  
'Q' + Convert(Varchar,Quarter) as QName,  
Case When Month(Date) <= 6 then '1HY' Else '2HY' End as HYName,  
Case when Year(Date) = Year(GetDate()-1) then Case When Date <= GetDate()-1 then 'YTD' Else 'YTG' End Else   
 Case when Year(Date) < Year(GetDate()-1) then 'YTD' Else    
  Case when Year(Date) > Year(GetDate()-1) then 'YTG' End   
 END  
 End as YTG_YTD  
  
/*  
Case when Year(Date) = Year(GetDate()-1) then 'Q' + Convert(Varchar,Quarter) Else '' End as QName,  
Case when Year(Date) = Year(GetDate()-1) then (Case When Month(Date) <= 6 then '1HY' Else '2HY' End) Else '' End as HYName,  
Case when Year(Date) = Year(GetDate()-1) then Case When Date <= GetDate()-1 then 'YTD' Else 'YTG' End Else '' End as YTG_YTD  
*/  
from dbo.DateDimension     
where Year between 2016 And Year(Getdate())  
