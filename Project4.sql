USE nyc_taxi_db;
SHOW TABLES;

SELECT * FROM yellow_tripdata_small;
SELECT * FROM taxi_zone_lookup;

-- Number of trips recorded
SELECT COUNT(*) AS NumberOfTrips FROM yellow_tripdata_small
WHERE tpep_pickup_datetime >= '2026-01-01' AND tpep_pickup_datetime < '2026-02-01';

-- Average Trip Distance
SELECT ROUND(AVG(trip_distance), 2) AS AvgDistance FROM yellow_tripdata_small
WHERE trip_distance > 0 AND trip_distance < 100;
  
-- Average fare amount
SELECT ROUND(AVG(fare_amount), 2) AS AvgFareAmount FROM yellow_tripdata_small
WHERE fare_amount > 0;

-- Busiest Hours of the day
SELECT HOUR(tpep_pickup_datetime) AS PickupHour, COUNT(*) AS TripCount FROM yellow_tripdata_small
GROUP BY PickupHour
ORDER BY TripCount DESC;

-- Busiest Days of the week
SELECT DAYNAME(tpep_pickup_datetime) AS DayOfPickup, COUNT(*) AS TripCount FROM yellow_tripdata_small
GROUP BY DayOfPickup, DAYOFWEEK(tpep_pickup_datetime)
ORDER BY TripCount DESC;

-- Pickup locations that generate the most trips
SELECT z.Borough, z.Zone, COUNT(t.VendorID) AS total_pickups
FROM yellow_tripdata_small t
INNER JOIN taxi_zone_lookup z ON t.PULocationID = z.LocationID
GROUP BY z.Borough, z.Zone
ORDER BY total_pickups DESC
LIMIT 10;

-- Drop-Off Locations which are the most popular
SELECT COALESCE(z.Borough, 'Unknown Borough') AS Dropoff_Borough, 
       COALESCE(z.Zone, 'Unknown Zone') AS Dropoff_Zone, 
       COUNT(t.VendorID) AS total_dropoffs
FROM yellow_tripdata_small t
LEFT JOIN taxi_zone_lookup z ON t.PULocationID = z.LocationID
GROUP BY Dropoff_Borough, Dropoff_Zone
ORDER BY total_dropoffs DESC
LIMIT 10;

-- Average Trip Duration
SELECT ROUND(AVG(TIMESTAMPDIFF(MINUTE, tpep_pickup_datetime, tpep_dropoff_datetime)), 2) AS AvgTripDuration
FROM yellow_tripdata_small
WHERE tpep_dropoff_datetime > tpep_pickup_datetime;
      
-- Locations which generate the highest revenue
SELECT COALESCE(UPPER(CONCAT(z.Borough, '-', z.Zone)), 'Unknown Location') AS Location, 
       ROUND(SUM(t.Total_amount), 2) AS TotalRevenue,
       COUNT(t.VendorID) AS TripCount
FROM yellow_tripdata_small t 
INNER JOIN taxi_zone_lookup z ON t.PULocationId = z.LocationID
GROUP BY Location
ORDER BY TripCount DESC;

-- How trip distance affects fare amount
SELECT 
    CASE 
        WHEN trip_distance < 1.0 THEN '0-1 Mile (Short)'
        WHEN trip_distance BETWEEN 1.0 AND 3.0 THEN '1-3 Miles (Medium)'
        WHEN trip_distance BETWEEN 3.0 AND 10.0 THEN '3-10 Miles (Long)'
        ELSE '10+ Miles (Extended)'
    END AS distance_tier,
    COUNT(*) AS trip_count,
    ROUND(AVG(fare_amount), 2) AS avg_fare
FROM yellow_tripdata_small
GROUP BY distance_tier
ORDER BY avg_fare DESC;

-- Percentage of trips that include tips
SELECT ROUND(
			(SUM(CASE
                    WHEN tip_amount > 0 THEN 1
                    ELSE 0
                    END) * 100) / COUNT(*), 2) AS Percentage
FROM yellow_tripdata_small;

-- Average tip amount
SELECT ROUND(AVG(tip_amount), 2) FROM yellow_tripdata_small AS AvgTipAmount; -- Overall

SELECT z.Borough, z.Zone,
	   ROUND(AVG(t.tip_amount), 2) AS AvgTipAmount
FROM yellow_tripdata_small t
INNER JOIN taxi_zone_lookup z ON t.PULocationID = z.LocationID
GROUP BY z.Borough, z.Zone
HAVING AVG(t.tip_amount) > 2.00
ORDER BY AvgTipAmount DESC 
LIMIT 10; -- For each Location

-- Payment methods most frequently used
SELECT payment_type, COUNT(*) AS Total_Transactions
FROM yellow_tripdata_small
GROUP BY payment_type
ORDER BY Total_Transactions DESC;

-- Peak demand periods
WITH hourly_demand AS (
    SELECT 
        DAYNAME(tpep_pickup_datetime) AS trip_day,
        HOUR(tpep_pickup_datetime) AS trip_hour,
        COUNT(*) AS trip_count
    FROM yellow_tripdata_small
    GROUP BY DAYNAME(tpep_pickup_datetime), HOUR(tpep_pickup_datetime), DAYOFWEEK(tpep_pickup_datetime)
)
SELECT 
    trip_day,
    trip_hour,
    trip_count
FROM hourly_demand
WHERE trip_count > (SELECT AVG(trip_count) FROM hourly_demand)
ORDER BY trip_count DESC;

-- Variation of taxi demand by day and hour
WITH daily_hourly_stats AS (
    SELECT 
        DAYNAME(tpep_pickup_datetime) AS trip_day,
        HOUR(tpep_pickup_datetime) AS trip_hour,
        COUNT(*) AS trip_count
    FROM yellow_tripdata_small
    GROUP BY trip_day, trip_hour, DAYOFWEEK(tpep_pickup_datetime)
)
SELECT trip_day, trip_hour, trip_count,
    RANK() OVER (PARTITION BY trip_day ORDER BY trip_count DESC) AS hourly_rank_within_day
FROM daily_hourly_stats;

-- How unusually long or expensive trips can be identified
WITH trip_percentiles AS (
    SELECT 
        VendorID,
        trip_distance,
        total_amount,
        PERCENT_RANK() OVER (ORDER BY total_amount) AS amount_percentile,
        PERCENT_RANK() OVER (ORDER BY trip_distance) AS distance_percentile
    FROM yellow_tripdata
)
SELECT VendorID, trip_distance, total_amount,
    CASE 
        WHEN amount_percentile >= 0.99 AND distance_percentile >= 0.99 THEN 'Extreme Outlier'
        WHEN amount_percentile >= 0.95 THEN 'High Value / Long Haul'
        ELSE 'Standard Trip'
    END AS trip_classification
FROM trip_percentiles
WHERE amount_percentile >= 0.95
ORDER BY total_amount DESC;
    