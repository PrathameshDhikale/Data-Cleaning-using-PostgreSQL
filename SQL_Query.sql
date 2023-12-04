--Skills used: Create Table, Substring, Update, Position, Split_Part, Alter Table, Case Statement, Window Function (row number),  Temporary table



--Create a Database in PostgreSQL

--Loading tables in the Database. Here table name is nashville

DROP TABLE IF EXISTS nashville
CREATE TABLE nashville
(
 UniqueID INT,
 ParcelID TEXT,
 LandUse TEXT,
 PropertyAddress TEXT,
 SaleDate DATE,
 SalePrice TEXT,
 LegalReference	TEXT,
 SoldAsVacant TEXT,
 OwnerName TEXT,
 OwnerAddress TEXT,
 Acreage REAL,
 TaxDistrict TEXT,
 LandValue INT,
 BuildingValue INT,
 TotalValue	INT,
 YearBuilt INT,
 Bedrooms INT,
 FullBath INT,
 HalfBath INT
)
COPY nashville
FROM 'filepath'                           --Paste the path of your file here
DELIMITER ','
CSV HEADER;

--Fill property address (There are some missing data from the column property address. By observing the relation between parcelid and property address, the required values are obtained)

UPDATE nashville AS h1
SET propertyaddress = h2.propertyaddress
FROM nashville AS h2
WHERE h1.parcelid = h2.parcelid AND h1.uniqueid <> h2.uniqueid
  AND h1.propertyaddress IS NULL AND h2.propertyaddress IS NOT NULL

SELECT * 
FROM nashville

--Extract address and city from property address using Subtring, Position, Length

SELECT SUBSTRING (propertyaddress,1,POSITION(',' IN propertyaddress)-1), SUBSTRING (propertyaddress,POSITION(',' IN propertyaddress)+1, LENGTH (propertyaddress))
FROM nashville

ALTER TABLE nashville
ADD COLUMN propertyaddsplit TEXT        --Address split

UPDATE nashville
SET propertyaddsplit = SUBSTRING (propertyaddress,1,POSITION(',' IN propertyaddress)-1)

ALTER TABLE nashville
ADD COLUMN propertycitysplit TEXT       -- City split

UPDATE nashville
SET propertycitysplit = SUBSTRING (propertyaddress,POSITION(',' IN propertyaddress)+1, LENGTH (propertyaddress))

--Extract Owner Address using Split_Part

SELECT SPLIT_PART(owneraddress, ',', 1), SPLIT_PART(owneraddress, ',', 2), SPLIT_PART(owneraddress, ',', 3)
FROM nashville

ALTER TABLE nashville
ADD COLUMN owneraddsplit TEXT

UPDATE nashville
SET owneraddsplit = SPLIT_PART(owneraddress, ',', 1)

ALTER TABLE nashville
ADD COLUMN ownercitysplit TEXT

UPDATE nashville
SET ownercitysplit = SPLIT_PART(owneraddress, ',', 2)

ALTER TABLE nashville
ADD COLUMN ownersstatesplit TEXT

UPDATE nashville
SET ownersstatesplit = SPLIT_PART (owneraddress, ',', 3)

-- Change Y and N into Yes and No in soldasvacant column using Case statement

SELECT soldasvacant, COUNT (soldasvacant)
FROM nashville
GROUP BY soldasvacant;

UPDATE nashville
SET soldasvacant =
				   CASE WHEN soldasvacant = 'Y' THEN 'Yes'
						WHEN soldasvacant = 'N' THEN 'No'
						ELSE soldasvacant
						END

--Remove Duplicate using window function

CREATE TEMPORARY TABLE new_nash AS
	(
	SELECT *,
			  ROW_NUMBER () OVER (PARTITION BY ParcelID,
											 LandUse,
											 PropertyAddress,
											 SaleDate,
											 SalePrice,
											 LegalReference,
											 SoldAsVacant,
											 OwnerName,
											 OwnerAddress,
											 Acreage,
											 TaxDistrict,
											 LandValue,
											 BuildingValue,
											 TotalValue,
											 YearBuilt,
											 Bedrooms,
											 FullBath,
											 HalfBath) row_num
	FROM nashville)
DELETE 
FROM new_nash
WHERE row_num >1;

SELECT *
FROM new_nash

--Delete unused columns

ALTER TABLE new_nash
DROP COLUMN propertyaddress;

ALTER TABLE new_nash
DROP COLUMN owneraddress;