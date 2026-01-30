/*
DATA DRILL
#1
Org Chart Overhaul
Your Objective
Unravel this parent-child hierarchy puzzle by mapping each employee's chain of command and calculating their direct and total reports.

Starting with a list of employees and their managers, your task is to create 3 new columns:

Reporting Hierarchy: The chain of command from the highest-ranking manager down to you

Direct Reports: The number of employees that report to you as their manager

Total Reports: The total number of employees beneath you in the reporting hierarchy (your direct reports, plus their direct reports, etc.)

What is the sum of the "Total Reports" column?
*/
-- select * from OfficeSpace;

WITH Employee (Employee_Name, Manager_Name,Reporting_Hierarchy) 
			AS(
						-- Anchor node : these are the employee with no manager
						Select  trim([Employee Name]),
								trim([Manager Name]) ,
								CAST( trim([Employee Name]) as nvarchar(max)) as Reporting_Hierarchy
						from    officespace 
						where   nullif([Manager Name], '') is null 
						union all
						-- recursive node 
						select trim(o.[Employee Name]), 
							   trim(o.[Manager Name]),
							   CAST( e.Reporting_Hierarchy + ' > ' + trim([Employee Name]) as nvarchar(max)) Reporting_Hierarchy
						from   officespace o
						inner join  Employee e on e.Employee_Name = o.[Manager Name]
					),
/* get the count of direct reportees to each manager */
direct_reports as ( select	m.[Manager Name]  manager , 
							count((m.[Manager Name])) cnt -- finds the count of direct reports for each employee
					from	OfficeSpace m where m.[Manager Name] != ''
					group by m.[Manager Name]
				  ),
/* 
   Used the STRING_Split function to split the value from the column Reporting_Hierarchy.
   Employee CTE table has comma seperated value in Reporting_Hierarchy column.
   Following query splits each list of Reporting_Hierarchy and joins them with the original row.
*/
total_reportees  as (select   Employee.Employee_Name,
						      Employee.Reporting_Hierarchy,
							  trim(value) list_of_emp
					 from		Employee 
					 cross apply string_split(Employee.Reporting_Hierarchy,'>')
					 where Employee.Employee_Name !=  trim(value)
				   ) 
SELECT  e.Employee_Name, 
			e.Manager_Name,
			e.Reporting_Hierarchy,
			isnull(dr.cnt,0) Direct_Reports,
			count(tr.list_of_emp) Total_reports 
from Employee e
left join total_reportees tr on tr.list_of_emp = e.Employee_Name
left join direct_reports dr on e.Employee_Name = dr.manager
	group by e.Employee_Name, 
			 e.Manager_Name,
			 e.Reporting_Hierarchy,
			 dr.cnt 
	
