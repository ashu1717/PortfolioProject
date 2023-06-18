Select *
From PortfolioProject..Uncleaned_DS_jobs$

--Dropping the index column

Alter Table Uncleaned_DS_jobs$
Drop Column "index"


--Checking for  duplicate data
With RowNumCTE AS(
Select *, ROW_NUMBER() Over (
Partition by [Job description],
			 Rating,
			 [Company Name],
			 [Location],
			 [Salary EStimate]
			 Order by 
			 Rating) Rownum
From PortfolioProject..Uncleaned_DS_jobs$)

--Deleting duplicates

Delete
From  RowNumCTE
Where rownum>1


--Removing Ratings from company name

--Checking if newline character is present between the name and rating

Select [Company Name], Case
						When CHARINDEX(Char(10),[Company Name])>0
						Then 'Newline Character Exists'
						Else 'No newline character'
						End As Newlinecheck
From PortfolioProject..Uncleaned_DS_jobs$

--To remove ratings

Select [Company Name], SUBSTRING([Company Name], 1, CHARINDEX(CHAR(10), [Company Name] + CHAR(10)) - 1)As Company_name
From PortfolioProject..Uncleaned_DS_jobs$

/* In charindex, Company name + Char(10) is there, so to make sure that if an entry does not have a newline character, the charindex does not return 0
*/


UPDATE Uncleaned_DS_jobs$
SET [Company Name] = SUBSTRING([Company Name], 1, CHARINDEX(CHAR(10), [Company Name] + CHAR(10)) - 1)


/*
converting Salary from 79K?131K (Glassdoor est.) to this format 79-131,145-225

Calculating min_salary,max_salary,avg_salary
*/


Select [Salary Estimate]
From PortfolioProject..Uncleaned_DS_jobs$

Select [Salary Estimate],
PARSENAME(Replace(Replace([Salary Estimate],'$',''),'K','.'),4) As Min_Salary,
PARSENAME(Replace(Replace(Replace([Salary Estimate],'-',''),'$',''),'K','.'),3) As Max_Salary,
From PortfolioProject..Uncleaned_DS_jobs$

Alter Table Uncleaned_DS_jobs$
Add Min_Salary Int,
	Max_Salary Int,
	Avg_Salary Int

Update Uncleaned_DS_jobs$
Set Min_Salary = PARSENAME(Replace(Replace([Salary Estimate],'$',''),'K','.'),4),
	Max_Salary = PARSENAME(Replace(Replace(Replace([Salary Estimate],'-',''),'$',''),'K','.'),3),
	Avg_Salary = (Min_salary+max_salary)/2 

Select Avg_salary,(Min_salary+max_salary)/2 
From PortfolioProject..Uncleaned_DS_jobs$

Select [Salary Estimate], Concat(min_salary,'-', max_salary)
From PortfolioProject..Uncleaned_DS_jobs$

Update Uncleaned_DS_jobs$
Set [Salary Estimate] = Concat(Min_salary,'-',max_salary)



--Extracting job_state and job_city from Location Column and for jobs without city deleting the rows

Select Location,
ParseName(Replace(Location,',','.'),2) As Job_CIty,
ParseName(Replace(Location,',','.'),1) As Job_State
From PortfolioProject..Uncleaned_DS_jobs$

Alter Table Uncleaned_DS_jobs$
Add Job_City nvarchar(255),
	Job_State nvarchar(255)

Update Uncleaned_DS_jobs$
Set Job_City = ParseName(Replace(Location,',','.'),2),
	Job_State = ParseName(Replace(Location,',','.'),1)



Delete From Uncleaned_DS_jobs$
where Job_city is null


--Comparing job_state and Headquaerters location

Select Job_City, Job_state, headquarters,
Case
When CHARINDEX(Job_State,Headquarters) > 1 Then '1'
Else '0'
End As Same_state
From PortfolioProject..Uncleaned_DS_jobs$


Alter Table Uncleaned_Ds_jobs$
Add Same_state nvarchar (255)

Update Uncleaned_DS_jobs$
Set 
Same_state = Case
When CHARINDEX(Job_State,Headquarters) > 1 Then '1'
Else '0'
End



--Calculating company Age from Founded Year and for those with -1, age = 0 


Select Founded, 
Case
When Founded = '-1' Then REPLACE(Founded,'-1','0')
Else 2023-Founded 
End As Company_Age
From PortfolioProject..Uncleaned_DS_jobs$

Alter Table Uncleaned_DS_jobs$
Add Company_age nvarchar(255)

Update Uncleaned_DS_jobs$
Set
Company_Age = Case
			  When Founded = '-1' Then REPLACE(Founded,'-1','0')
			  Else 2023-Founded 
			  End 


--extracting key skills mentioned in the job description

Select [Job Description],
Case 
When [Job Description] like '%Python%' then '1'
Else '0'
End As Python,
Case 
When [Job Description] like '%excel%' then '1'
Else '0'
End As excel,
Case 
When [Job Description] like '%tableau%' then '1'
Else '0'
End As Tableau,
Case 
When [Job Description] like '%aws%' then '1'
Else '0'
End As Aws,
Case 
When [Job Description] like '%hadoop%' then '1'
Else '0'
End As Hadoop
From PortfolioProject..Uncleaned_DS_jobs$


Alter Table Uncleaned_Ds_jobs$
Add Python int,
	Excel int,
	Tableau int,
	Aws int,
	Hadoop int


Update Uncleaned_DS_jobs$
Set 
Python =Case 
		When [Job Description] like '%Python%' then '1'
		Else '0'
		End,
Excel =Case 
		When [Job Description] like '%excel%' then '1'
		Else '0'
		End,
Tableau =Case
		 When [Job Description] like '%tableau%' then '1'
		 Else '0'
		 End,
Aws = Case
	  When [Job Description] like '%aws%' then '1'
	  Else '0'
	  End,
Hadoop = Case 
		 When [Job Description] like '%hadoop%' then '1'
		 Else '0'
		 End


--dropping columns like index, level_0, Founded, Competitors

Alter table Uncleaned_DS_jobs$
Drop Column Founded,Competitors


Select *
From PortfolioProject..Uncleaned_DS_jobs$