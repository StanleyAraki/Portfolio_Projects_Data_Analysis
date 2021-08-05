SELECT * FROM dbo.[Nashville Housing];

-- Task: Clean data
/*
    PropertyAddress can be split into two parts: Street, City
    Unify format of SoldAsVacant to Yes or No
    OwnerAddress can be split into three parts: Street, City, State
    Fill in missing data using preexisting ones if rows share ParcelIDs
        Overlapping ParcelId = same house
*/


-- Split PropertyAddress into two parts: Street, City
-- Need to split by the comma
SELECT PropertyAddress,
    PARSENAME(REPLACE(PropertyAddress, ',','.'), 2) AS PropertyStreet,
    TRIM(PARSENAME(REPLACE(PropertyAddress, ',','.'), 1)) AS PropertyCity
FROM dbo.[Nashville Housing];

--Add the two new columns and remove the old PropertyAddress column
ALTER TABLE [Nashville Housing]
ADD PropertyStreet NVARCHAR(255)
ALTER TABLE [Nashville Housing]
ADD PropertyCity NVARCHAR(255)

UPDATE [Nashville Housing]
SET PropertyStreet = PARSENAME(REPLACE(PropertyAddress, ',','.'), 2)
UPDATE [Nashville Housing]
SET PropertyCity = TRIM(PARSENAME(REPLACE(PropertyAddress, ',','.'), 1))
ALTER TABLE [Nashville Housing]
DROP COLUMN PropertyAddress

-- Split OwnerAddress into three parts: Street, City, State
-- Need to split by the comma

SELECT OwnerAddress,
    PARSENAME(Replace(OwnerAddress, ',','.'), 3) AS OwnerStreet,
    TRIM(PARSENAME(Replace(OwnerAddress, ',','.'), 2)) AS OwnerCity,
    TRIM(PARSENAME(Replace(OwnerAddress, ',','.'), 1)) AS OwnerState
FROM dbo.[Nashville Housing]

ALTER TABLE [Nashville Housing]
ADD OwnerStreet NVARCHAR(255)
ALTER TABLE [Nashville Housing]
ADD OwnerCity NVARCHAR(255)
ALTER TABLE [Nashville Housing]
ADD OwnerState NVARCHAR(255)

UPDATE [Nashville Housing]
SET OwnerStreet = PARSENAME(Replace(OwnerAddress, ',','.'), 3)
UPDATE [Nashville Housing]
SET OwnerCity = TRIM(PARSENAME(Replace(OwnerAddress, ',','.'), 2))
UPDATE [Nashville Housing]
SET OwnerState = TRIM(PARSENAME(Replace(OwnerAddress, ',','.'), 1))
ALTER TABLE [Nashville Housing]
DROP COLUMN OwnerAddress

-- Unify format of SoldAsVacant with either Yes or No 
SELECT SoldAsVacant FROM dbo.[Nashville Housing];

SELECT SoldAsVacant,
CASE 
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
    END AS SoldAsVacantUpdated
FROM dbo.[Nashville Housing];
    
    -- Now update the table with the new values
UPDATE [Nashville Housing]
SET SoldAsVacant = CASE 
                        WHEN SoldAsVacant = 'Y' THEN 'Yes'
                        WHEN SoldAsVacant = 'N' THEN 'No'
                        ELSE SoldAsVacant
                        END;

    -- Confirm all values are updated
SELECT SoldAsVacant FROM dbo.[Nashville Housing]
WHERE SoldAsVacant IN ('N', 'Y'); -- No rows returned. All good!


-- Fill in some of the missing values in the data using parcelID
-- Idea: If the parcelIDs are the same, that means the row should be matching (besides the UniqueID)

SELECT data1.ParcelID, data1.PropertyCity, data2.ParcelID, data2.PropertyCity
FROM dbo.[Nashville Housing] data1
JOIN dbo.[Nashville Housing] data2
    ON data1.ParcelID = data2.ParcelID
    AND data1.UniqueID != data2.UniqueID
WHERE data1.PropertyCity IS NULL;

    -- Value we can upate based on ParcelID: PropertyStreet, PropertyCity, 

Update data1
SET 
    PropertyCity = ISNULL(data1.PropertyCity, data2.PropertyCity)
FROM dbo.[Nashville Housing] data1
JOIN dbo.[Nashville Housing] data2
    ON data1.ParcelID = data2.ParcelID
    AND data1.UniqueID != Data2.UniqueID
WHERE data1.PropertyCity IS NULL

Update data1
SET
    PropertyStreet = ISNULL(data1.PropertyStreet, data2.PropertyStreet)
FROM dbo.[Nashville Housing] data1
JOIN dbo.[Nashville Housing] data2
    ON data1.ParcelID = data2.ParcelID
    AND data1.UniqueID != Data2.UniqueID
WHERE data1.PropertyStreet IS NULL

    -- Confirm if null values were filled in correctly
    
SELECT data1.ParcelID, data1.PropertyCity, data1.PropertyStreet, data2.ParcelID, data2.PropertyCity, data2.PropertyStreet
FROM dbo.[Nashville Housing] data1
JOIN dbo.[Nashville Housing] data2
    ON data1.ParcelID = data2.ParcelID
    AND data1.UniqueID != data2.UniqueID
WHERE data1.PropertyCity IS NULL -- No rows returned. All good!