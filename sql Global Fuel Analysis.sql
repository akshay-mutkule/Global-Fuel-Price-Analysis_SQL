create database fuel_price_db;
use fuel_price_db;

select * from cleaned_gfpa; 
select* from  asia_fuel_prices_detailed;
select*from asia_subsidy_tracker;
select * from crude_oil_annual;
select * from fuel_tax_comparison;
select*from global_fuel_prices;
select * from price_trend_monthly;


ALTER TABLE global_fuel_prices ADD PRIMARY KEY (iso3);

ALTER TABLE crude_oil_annual ADD PRIMARY KEY (year);

ALTER TABLE asia_subsidy_tracker ADD PRIMARY KEY (iso3);

ALTER TABLE fuel_tax_comparison ADD PRIMARY KEY (country);

ALTER TABLE price_trend_monthly ADD PRIMARY KEY (date, country);

ALTER TABLE global_fuel_prices 
MODIFY COLUMN iso3 VARCHAR(10) NOT NULL;

ALTER TABLE global_fuel_prices 
ADD PRIMARY KEY (iso3);

ALTER TABLE asia_subsidy_tracker 
MODIFY COLUMN iso3 VARCHAR(10) NOT NULL;

ALTER TABLE asia_subsidy_tracker 
ADD PRIMARY KEY (iso3);

 
ALTER TABLE fuel_tax_comparison 
ADD PRIMARY KEY (country);

ALTER TABLE fuel_tax_comparison 
MODIFY COLUMN country VARCHAR(100) NOT NULL;



ALTER TABLE price_trend_monthly 
MODIFY COLUMN date VARCHAR(20) NOT NULL,
MODIFY COLUMN country VARCHAR(100) NOT NULL;

ALTER TABLE price_trend_monthly 
ADD PRIMARY KEY (date, country);

ALTER TABLE asia_fuel_prices_detailed MODIFY COLUMN iso3 VARCHAR(10) NOT NULL;
ALTER TABLE asia_subsidy_tracker MODIFY COLUMN iso3 VARCHAR(10) NOT NULL;

ALTER TABLE asia_fuel_prices_detailed 
ADD CONSTRAINT fk_asia_prices_global 
FOREIGN KEY (iso3) REFERENCES global_fuel_prices(iso3);

ALTER TABLE asia_subsidy_tracker 
ADD CONSTRAINT fk_subsidy_global 
FOREIGN KEY (iso3) REFERENCES global_fuel_prices(iso3);

ALTER TABLE global_fuel_prices MODIFY COLUMN country VARCHAR(100) NOT NULL;
ALTER TABLE global_fuel_prices ADD UNIQUE (country);


ALTER TABLE price_trend_monthly 
MODIFY COLUMN country VARCHAR(100) NOT NULL,
MODIFY COLUMN year INT NOT NULL;


ALTER TABLE price_trend_monthly 
ADD CONSTRAINT fk_trend_oil 
FOREIGN KEY (year) REFERENCES crude_oil_annual(year);


ALTER TABLE price_trend_monthly 
ADD CONSTRAINT fk_trend_country 
FOREIGN KEY (country) REFERENCES global_fuel_prices(country);


ALTER TABLE fuel_tax_comparison MODIFY COLUMN country VARCHAR(100) NOT NULL;


ALTER TABLE fuel_tax_comparison 
ADD CONSTRAINT fk_tax_global 
FOREIGN KEY (country) REFERENCES global_fuel_prices(country);







-- PROBLEM STATEMENT

-- 1 Top Prices: List the top 5 countries with the highest gasoline prices globally
SELECT country, gasoline_usd_per_liter
 FROM global_fuel_prices
 ORDER BY gasoline_usd_per_liter DESC
 LIMIT 5;
 -- Insights
-- The Netherlands and Norway lead global gasoline costs at $2.10 and $2.08 per liter, respectively.
-- These high prices in Europe and Israel reflect aggressive carbon taxation and a policy-driven market that passes energy transition costs directly to consumers.


-- 2 Regional Averages: Find the average gasoline price for each geographic region.
SELECT region, AVG(gasoline_usd_per_liter) AS avg_gas_price
 FROM global_fuel_prices
 GROUP BY region;
-- Insight
-- Europe maintains the highest regional average at approximately $1.71/L, while the Middle East and Africa remain the most affordable at $0.75/L and $0.78/L. 
-- This gap highlights the disparity between nations with high import duties versus those with proximity to production.



-- 3 Active Subsidies: Identify Asian countries where fuel subsidies are active and their annual cost.
SELECT country, annual_subsidy_cost_bn_usd
 FROM asia_subsidy_tracker 
WHERE gasoline_subsidized = TRUE;


-- 4 Wage vs. Fuel: Calculate the percentage of daily wage spent on a liter of gas in South Asian countries.
 SELECT country, gasoline_pct_daily_wage 
 FROM asia_fuel_prices_detailed
 WHERE sub_region = 'South Asia';
 -- Insights 
 -- In Afghanistan, a single liter of gas consumes 37% of the daily wage, the highest in the region, followed by Nepal at 29.8%. 
 -- These figures reveal that fuel costs are a massive barrier to economic mobility and disposable income for South Asian workers.

-- 5 Oil History: Retrieve the average Brent crude price and the key global event for every year
SELECT year, brent_avg_usd_bbl, key_event 
FROM crude_oil_annual 
ORDER BY year;
 -- Insights 
 -- Brent crude peaked at $100.93 in 2022 during the Russia-Ukraine war and is forecast at $92.40 for 2026 due to the Strait of Hormuz crisis.

-- 6 High Tax Zones: Find all countries where the total tax on fuel exceeds $0.50 per liter.
SELECT country, total_tax_usd_per_liter FROM fuel_tax_comparison
 WHERE total_tax_usd_per_liter > 0.50;

-- Insights
-- France, Norway, and Italy impose the highest tax burdens, exceeding $1.05 per liter, while India sits lower at $0.61/L.

-- 7 Energy Security: List Asian countries that are 100% dependent on oil imports with zero refinery capacity.
SELECT country, oil_import_dependency_pct, refinery_capacity_kbpd 
FROM asia_fuel_prices_detailed 
WHERE oil_import_dependency_pct = 100 
AND refinery_capacity_kbpd = 0;
-- Insights
-- Nepal, Afghanistan, and Cambodia are 100% dependent on oil imports with zero refinery capacity.


-- 8 Historical Peaks: Identify the month and year that had the highest global gasoline price in the dataset
SELECT year, month, AVG(gasoline_usd_per_liter) as avg_price 
FROM price_trend_monthly 
GROUP BY year, month
 ORDER BY avg_price DESC
 LIMIT 1;
 
  -- Insights 
  -- The dataset identifies June 2022 as the absolute historical peak, with a global average gasoline price of $1.37/L

-- 9 Carbon Tax Impact: Compare the average gasoline price of countries with a carbon tax vs. those without.
SELECT f.carbon_tax_active, AVG(g.gasoline_usd_per_liter) 
FROM fuel_tax_comparison f 
JOIN global_fuel_prices g 
ON f.country = g.country 
GROUP BY f.carbon_tax_active;

-- Insights
-- Nations with an active carbon tax see an average gasoline price of $1.71/L, compared to just $0.93/L in nations without one

-- 10 EV Adoption: List countries where EV adoption is above 5% and their current gasoline price.
SELECT country, ev_adoption_pct, gasoline_usd_per_liter 
FROM asia_fuel_prices_detailed 
WHERE ev_adoption_pct > 5.0;

-- Insights
-- South Korea and China lead in EV adoption at 9.8% and 9.4%, coinciding with gasoline prices between $1.24 and $1.42/L.


-- 11 Subsidy Burden: Show the annual subsidy cost as a percentage of GDP for all tracked Asian countries.
SELECT country, subsidy_pct_gdp, annual_subsidy_cost_bn_usd 
FROM asia_subsidy_tracker 
ORDER BY subsidy_pct_gdp DESC;
-- Insights
--  Indonesia’s fuel subsidy accounts for a staggering 5.2% of its GDP, the highest tracked, followed by Malaysia at 3.8%


-- 12 Price Anomalies: Find all countries where diesel is currently more expensive than gasoline.
SELECT country, gasoline_usd_per_liter, diesel_usd_per_liter
FROM global_fuel_prices 
WHERE diesel_usd_per_liter > gasoline_usd_per_liter;
