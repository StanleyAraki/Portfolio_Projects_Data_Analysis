/*
    Questions to answer based on data:
        what areas have the houses with the highest total value? (visualize using map)
        What is the distribution of sale prices among houses with a single family land use? (Box and Whisker plot)
        Which tax district is the cheapest for single family
        To what extent does the number of bedrooms, fullbaths, halfbaths, acreage impact the sale price of houses for single families?
            Want to find trends using visualization
        
*/

SELECT * FROM dbo.[Nashville Housing];

-- What TaxDistricts have the houses with the highest total land value? 

SELECT Distinct TaxDistrict, Count(TaxDistrict) AS NumberOfRows
FROM dbo.[Nashville Housing]
WHERE TaxDistrict IS NOT NULL
GROUP BY TaxDistrict
ORDER BY NumberOfRows DESC
    -- Total of 7 districts excluding those that are null. 26,015 rows in the dataset with a tax district

SELECT TaxDistrict, TotalValue 
FROM dbo.[Nashville Housing]
WHERE TaxDistrict IS NOT NULL
ORDER BY TotalValue DESC;

    -- Remove the overlapping data using CTE

Select 
    ParcelID, SaleDate, TaxDistrict, TotalValue, Rank = RANK()OVER(PARTITION BY ParcelID ORDER BY SaleDate DESC)
FROM dbo.[Nashville Housing]
WHERE TaxDistrict IS NOT NULL
ORDER BY parcelID;

    -- Removes rows dated older that have overlapping ParcelIDs (Only keeps most recent values.)
WITH ParcelID_Sorted AS (
    Select 
    ParcelID, SaleDate, TaxDistrict, TotalValue, Rank = RANK()OVER(PARTITION BY ParcelID ORDER BY SaleDate DESC)
    FROM dbo.[Nashville Housing]
    WHERE TaxDistrict IS NOT NULL
)
SELECT ParcelID, SaleDate, TaxDistrict, TotalValue FROM ParcelID_Sorted
WHERE Rank=1
ORDER BY ParcelID -- Returns the data with no duplicates.

    -- Count the number of columns in total

WITH ParcelID_Sorted AS (
    Select 
    ParcelID, SaleDate, TaxDistrict, TotalValue, Rank = RANK()OVER(PARTITION BY ParcelID ORDER BY SaleDate DESC)
    FROM dbo.[Nashville Housing]
    WHERE TaxDistrict IS NOT NULL
),
Parcels_Sorted AS (
    SELECT ParcelID, SaleDate, TaxDistrict, TotalValue FROM ParcelID_Sorted
    WHERE Rank=1
)
SELECT count(ParcelID) FROM Parcels_Sorted; -- 22563



-- What is the distribution of sale prices among houses with a single family land use? (Box and Whisker plot)
    -- Need to get data filtered on single families
    Select ParcelID, LandUse, SaleDate, SalePrice
    FROM dbo.[Nashville Housing]
    WHERE LandUse LIKE '%Single Family%'
    ORDER BY ParcelID

    -- Since the Sale Price changes based on the sale date for houses with the same parcel ID, we need to remove the older data using CTE

    Select Rank = RANK()OVER(PARTITION BY ParcelID ORDER BY SaleDate DESC), ParcelID, LandUse, SaleDate, SalePrice
    FROM dbo.[Nashville Housing]
    WHERE LandUse LIKE '%Single Family%'
    ORDER BY ParcelID -- puts rank on each data, where data with duplicate ParcelID are given ranks based on recency

    -- Filter and query data
    WITH Ranked_ParcelID AS (
        Select Rank = RANK()OVER(PARTITION BY ParcelID ORDER BY SaleDate DESC), ParcelID, LandUse, SaleDate, SalePrice
        FROM dbo.[Nashville Housing]
        WHERE LandUse LIKE '%Single Family%'
    )
    SELECT ParcelID, LandUse, SaleDate, SalePrice
    FROM Ranked_ParcelID
    WHERE Rank = 1
    ORDER BY ParcelID

    -- Data is filtered. Get count on data
    WITH Ranked_ParcelID AS (
        Select Rank = RANK()OVER(PARTITION BY ParcelID ORDER BY SaleDate DESC), ParcelID, LandUse, SaleDate, SalePrice
        FROM dbo.[Nashville Housing]
        WHERE LandUse LIKE '%Single Family%'
    ),
    Filtered_Paracels AS (
        SELECT ParcelID, LandUse, SaleDate, SalePrice
        FROM Ranked_ParcelID
        WHERE Rank = 1
    )
    SELECT Count(ParcelID) AS Row_Count
    FROM Filtered_Paracels -- 30320
