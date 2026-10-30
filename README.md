# NYC Taxi Trip & Transportation Analytics using SQL

## 1. Business Problem
A transportation analytics firm requires detailed operational insights from New York City taxi trip data. The primary objective is to analyze urban mobility patterns, peak travel hours, demand fluctuations across geographic locations, fare structures, and tip distribution dynamics. By using SQL to analyze massive trip records, this project provides data-driven strategies to improve fleet utilization, dynamic driver routing, pricing models, and overall customer service quality.

## 2. Dataset
This project analyzes the public trip record dataset released by the NYC Taxi & Limousine Commission (TLC).
Source: https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page

## 3. Database Schema
1. Open the source link and go to the 2026 section of "Trip Record Data Download Links".
2. Download "Yellow Taxi Trip Records" PARQUET file under January 2026.
3. Go to "Taxi Zone Maps and Lookup Tables" and download the CSV file.
4. Convert the .parquet file to .sql file with the help of python.
5. Import the dataset on MySQL Workbench.
6. Connect the taxi zone lookup table to the Yellow Taxi Trip Records twice using foreign keys:
   yellow_tripdata.pu_location_id $\rightarrow$ taxi_zone_lookup.location_id (for pickup location details)
   yellow_tripdata.do_location_id $\rightarrow$ taxi_zone_lookup.location_id (for drop-off location details)
   
## 4. Business Questions
1. How many trips were recorded?
2. What is the average trip distance?
3. What is the average fare amount?
4. What are the busiest hours of the day?
5. What are the busiest days of the week?
6. Which pickup locations generate the most trips?
7. Which drop-off locations are most popular?
8. What is the average trip duration?
9. Which locations generate the highest revenue?
10. How does trip distance affect fare amount?
11. What percentage of trips include tips?
12. What is the average tip amount?
13. Which payment methods are most frequently used?
14. What are the peak demand periods?
15. How does taxi demand vary by day and hour?
16. How can unusually long or expensive trips be identified?

## 5. SQL Concepts Used
1. Date/time functions - DAYNAME(), HOUR(), DAYOFWEEK()
2. GROUP BY
3. ORDER BY
4. CASE
5. Common Table Expressions - WITH clause
6. Window functions - COUNT(), SUM()
7. Ranking - RANK() OVER (PARTITION BY... ORDER BY...), PERCENT_RANK() OVER (ORDER BY...)
8. Aggregations
9. Filtering

## 6. Key Findings
1. A significant volume of trips in midtown Manhattan cover less than 1.5 miles but suffer high trip durations due to severe traffic congestion, leading to high time-based charges.
2. Taxi trips to and from major airports like JFK and LaGuardia earn significantly higher average fares and tips than trips that stay within Manhattan.
3. Taxi demand spikes significantly during weekday evening rush hours and late Friday/Saturday nights.
   
## 7. Business Recommendations
1.  Shift drivers toward busy airports and downtown cores during peak commuting times.
2.  Make it easier for passengers to pay digitally so drivers get higher tips and don't have to carry as much cash.
   
## 8. Conclusion
This SQL transportation analysis provides clear visibility into NYC urban mobility patterns. By examining trip density, fare structures, spatial zones, and payment behaviors, operators can optimize fleet efficiency, driver scheduling, and revenue performance.
