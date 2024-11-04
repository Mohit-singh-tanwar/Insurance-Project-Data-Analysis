use project_insurance;
select * from brokerage;
select * from fees;
select * from budgets;
select * from invoice;
select * from meeting;
select * from opportunity;
---------------------------------------------------------------------------------------
# KPI 1st : No of invoice by account executive
select account_executive,income_class,count(income_class) from invoice 
group by income_class,account_executive;
-------------------------------------------------------------------------------------

# KPI 2nd : Yearly Meeting Count
select year(meeting_date),count(year(meeting_date)) as count_year  from meeting
group by year(meeting_date) ;
---------------------------------------------------------------------------------------
# KPI 4th : Stage funnel by revenue
select stage,sum(revenue_amount) from opportunity
group by stage;
----------------------------------------------------------------------------------------
# KPI 5th : No of meeting By Account Exe
select AccountExecutive,count(AccountExecutive) as count_of_meeting_date from  meeting
group by AccountExecutive order by count_of_meeting_date desc ;
---------------------------------------------------------------------------------------
# KPI 6th : Top open opportunity

select opportunity_name,sum(revenue_amount) from opportunity
group by opportunity_name order by sum(revenue_amount) desc limit 4;

# total opportunity
select count(opportunity_name) as Total_Opportunities from opportunity;
# open opportunity
select count(opportunity_name) as Open_Opportunities from opportunity
where stage="Propose Solution" or stage="Qualify Opportunity" ;

# total opportunity by product wise
select product_group,count(product_group) as total_opportunities_by_product_wise from opportunity
group by product_group;
----------------------------------------------------------------------------
# KPI 3.1 : cross sell(invoice)
select income_class ,sum(Amount) as Invoice from invoice  
where income_class in ('Cross Sell') 
group by income_class;

#KPI 3.1 : cross sell(Achieved)
(SELECT(
	SELECT  SUM(Amount)   FROM brokerage 
	where brokerage.income_class in ("Cross Sell"))
+ SUM(Amount) AS Achieved,income_class FROM fees where fees.income_class in ("Cross Sell") 
group by income_class);

#KPI 3.1 : cross sell(Target)
select sum(cross_sell_budget) as Target from budgets;
----------------------------------------------------
#KPI 3.2 : new (invoice)
select income_class ,sum(Amount) as Invoice from invoice  
where income_class in ('New') 
group by income_class;

#KPI 3.2 : new (acheive)
SELECT
	(SELECT  SUM(Amount)  FROM brokerage where brokerage.income_class in ("New") ) +
							SUM(Amount) AS Achieved,income_class FROM fees 
                            where fees.income_class in ("New")
                            group by income_class ;
                            
#KPI 3.2 : new (Target)
select sum(new_budget) as Target from budgets;
----------------------------------------------------------------
#KPI 3.3 : Renewal (invoice)
select income_class ,sum(Amount) as Invoice from invoice  
where income_class in ('Renewal') 
group by income_class;

#KPI 3.3 : Renewal (Achieved)
SELECT
	(SELECT  SUM(Amount)  FROM brokerage where brokerage.income_class in ("Renewal") ) +
							SUM(Amount) AS Achieved,income_class FROM fees 
                            where fees.income_class in ("Renewal")
                            group by income_class ;

#KPI 3.3 : Renewal (Target)
select sum(renewal_budget) as Target from budgets;

--------------------------------------------------------------------------
################################################################################################
#### Cross Sell Placed Percentage
################################################################################################
create view pro as
(SELECT(
	SELECT  SUM(Amount)   FROM brokerage 
	where brokerage.income_class in ("Cross Sell"))
+ SUM(Amount) AS Achieved,income_class FROM fees where fees.income_class in ("Cross Sell") 
group by income_class);
create view pro1 as
select sum(cross_sell_budget) as Target from budgets;

#Cross Sell Placed Percentage
select concat(round((Achieved/Target)*100,2),"%" ) as "Cross_Sell_Plcd_Ach%" from pro,pro1;
--------------------------------------------------------------------------
#Cross Sell Invoice Percentage
select concat(round((select sum(amount) from invoice where income_class = 'Cross sell')/ (select sum(cross_sell_budget) from budgets)*100,2),'%') As "Cross sell invoice Ach %" ;
################################################################################################
# New Percentage
################################################################################################
create view pro2 as
(SELECT(
	SELECT  SUM(Amount)   FROM brokerage 
	where brokerage.income_class in ("New"))
+ SUM(Amount) AS Achieved,income_class FROM fees where fees.income_class in ("New") 
group by income_class);
create view pro3 as
select sum(new_budget) as Target from budgets;
------------------------------------------------
#New plcd Achv%age
select concat(round((Achieved/Target)*100,2),"%" ) as "New_Plcd_Ach%" from pro2,pro3;
-------------------------------------------------------------------------------------
#New invoice Achv%age
select concat(round((select sum(amount) from invoice where income_class = 'New')/(select sum(new_budget) from budgets)*100,2),'%') As "New invoice Ach %" ;
-------------------------------------------------------------------------------------
################################################################################################
# Renewal Percentage
################################################################################################
create view pro4 as
(SELECT(
	SELECT  SUM(Amount)   FROM brokerage 
	where brokerage.income_class in ("Renewal"))
+ SUM(Amount) AS Achieved,income_class FROM fees where fees.income_class in ("Renewal") 
group by income_class);
create view pro5 as
select sum(renewal_budget) as Target from budgets;
------------------------------------------------
#Renwal plcd Achv%age
select concat(round((Achieved/Target)*100,2),"%" ) as "Renew_Plcd_Ach%" from pro4,pro5;
-------------------------------------------------------------------------------------
#Renwal invoice Achv%age
select concat(round((select sum(amount) from invoice where income_class = 'Renewal')/ (select sum(renewal_budget) from budgets)*100,2),'%') As "Renewal invoice Ach %" ;
################################################################################################