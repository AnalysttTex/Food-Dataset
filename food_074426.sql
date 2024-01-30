
--This dataset presents analysis of food samples to their respective nutrients content. 
--These nutrients are divided into 4 tables; food_general, food_fats, food_minerals and food_vitamins. These tables contain data about the food samples under their respective nutrient types.
--These tables share 3 columns; Category, Description and Nutrient Data Bank Number which could be used as a unique ID for the food samples.
--

--Selecting all tables to get a view of general data
--A stored procedure is created to avoid repetition of bogus codes
--It may also be made into a view for easy usage.

create procedure All_Data
as
select * 
from food.dbo.food_general a
right join food.dbo.food_fats b on a.Nutrient_Data_Bank_Number = b.Nutrient_Data_Bank_Number
right join food.dbo.food_minerals c on a.Nutrient_Data_Bank_Number = c.Nutrient_Data_Bank_Number
right join food.dbo.food_vitamins d on a.Nutrient_Data_Bank_Number = d.Nutrient_Data_Bank_Number;

 exec food.dbo.All_Data 

--The entire data can also be stored as a view
-- Modifying columns for easy data wrangling and calculations
--This command is repeated for different columns with their respective data types
--A time conscious alternative is the usage of the 'CAST' function 

alter table food.dbo.food_minerals
alter column Nutrient_Data_Bank_Number int not null

--Otherwise

select Category, Avg(cast(Carbohydrate as real)), avg(cast(Cholesterol as real)), avg(cast (water as decimal(18,0))), avg(cast (sugar_total as decimal(18,0))) 
	from food.dbo.food_general
	group by Category
	order by avg(water) desc;

-- There is need for a primary key in this database through which tables may be linked.
--The most appropiate column for it is the Nutrient Data Bank Number

alter table food.dbo.food_general
add constraint primary_keygen
primary key (nutrient_data_bank_number)

alter table food.dbo.food_fats 
drop primary_keydd;

alter table food_general
add constraint fk_nutrient_number
foreign key (nutrient_data_bank_number) references food_general (nutrient_data_bank_number);

-- Lets pull out the common food parameters by categoory

select a.category, avg(carbohydrate) as carbohydrate, avg(protein) as protein, avg(Sugar_Total) as sugar, avg(water) as moisture, avg(Total_Lipid) as fats, avg(Vitamin_A___RAE) as vitamins 
from food.dbo.food_general a
full outer join food.dbo.food_fats b on a.Nutrient_Data_Bank_Number = b.Nutrient_Data_Bank_Number
full outer join food.dbo.food_minerals c on a.Nutrient_Data_Bank_Number = c.Nutrient_Data_Bank_Number
full outer join food.dbo.food_vitamins d on a.Nutrient_Data_Bank_Number = d.Nutrient_Data_Bank_Number
group by a.Category
order by category;

--Top 7 food samples category that appeared the most in this dataset? 
--This could be used for other calculations such as percentage later on in analysis.

select category, count(category) 
	from food.dbo.food_general
	group by Category
	order by count(category) desc 
	offset 0 rows fetch first 7 rows only

-- Which milk sample is most proteinous and fatty?

select a.category, a.Description, a.Nutrient_Data_Bank_Number, protein, Saturated_Fat, Total_Lipid 
	from food.dbo.food_general a
	right join food.dbo.food_fats b on a.Nutrient_Data_Bank_Number = b.Nutrient_Data_Bank_Number
	where a.category = 'milk'
	order by protein desc, total_lipid desc;

-- A patient is suffering from constipation.recommend 5 food samples for such person?
-- First, we need to understand that the food sample to be recommend must be rich in fibre and zinc.
--Through this we can pull out the top 5 food sample to help combat constipation.

select a.Category, a.Description, Fiber, Zinc
	 from food.dbo.food_general a
right join food.dbo.food_minerals c on a.Nutrient_Data_Bank_Number = c.Nutrient_Data_Bank_Number
	where Zinc != '0'
	order by fiber desc, zinc desc 
	offset 0 rows fetch first 5 rows only;

	exec food.dbo.All_Data
 
 --Does proteinous food contain high moisture content? 
 -- First we select only rows with protein greater than average value. Then we compare with their respective moisture content.

 select Category, Description, Protein, Water
 from food.dbo.food_general
 where protein > (select avg(protein) from food.dbo.food_general)
 order by protein desc
 offset 0 rows fetch first 5 rows only;

 --How do fat soluble vitamins relate to cholesterol content? Does ingestion of fat soluble vitamins affect the total lipid content of the food sample?
 --Fat soluble vitamins in this dataset are; Retinol also known as vitamin A, Vitamin A-RAE, Vitamin E and Vitamin K.
 --These columns are selected and their various parameters compared. The data was pulled out on the basis of their cholesterol content.
 --From the results obtained, it was noticed that food samples of animal origins are prevalent in this categories. 

 select a.Category, a.Description, Cholesterol, Retinol, Total_Lipid, Vitamin_A___RAE, Vitamin_E, Vitamin_K
	from food.dbo.food_general a
	Right join food.dbo.food_fats b on a.Nutrient_Data_Bank_Number = b.Nutrient_Data_Bank_Number
	right join food.dbo.food_vitamins c on a.Nutrient_Data_Bank_Number =  c.Nutrient_Data_Bank_Number
	order by Cholesterol desc;

	-- A patient suffering from osteomalacia needs food samples recommendation. Extract 5 food sample bearing in mind that the patient also suffers from lactose intolerance.
	-- The patient needs food samples high in minerals such as calcium, phosphorus, iron and magnesium. 
	-- However, as the patient suffers from stomach ulcer, food samples to be recommended must be extremely low in protein and food sample must not be dairy related.

	select a.Category, a.Description, protein, Calcium, Phosphorus, Iron, Magnesium
	from food.dbo.food_general a
	right join food.dbo.food_minerals b on a.Nutrient_Data_Bank_Number = b.Nutrient_Data_Bank_Number
	where a.Category != 'milk' 
	and a.Description not like '%milk%'
	and Calcium > (select avg(calcium) from food.dbo.food_minerals)
	and Phosphorus > (select avg(Phosphorus) from food.dbo.food_minerals)
	and Iron > (select avg(iron) from food.dbo.food_minerals)
	and Magnesium > (select avg(Iron) from food.dbo.food_minerals)
	order by protein asc
	offset 0 rows fetch first 7 rows only;