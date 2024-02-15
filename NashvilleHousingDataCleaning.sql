-- Data Cleaning in SQL
SELECT * 
FROM PortfolioProject..NashvilleHousing



---- Standardize SaleDate Format ----
SELECT SaleDate 
FROM PortfolioProject..NashvilleHousing

-- Determine type of SaleDate column
SELECT DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE COLUMN_NAME = 'SaleDate'

SELECT SaleDate, CONVERT(date, SaleDate)
FROM PortfolioProject..NashvilleHousing

-- Update type from datetime to date
ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate DATE



---- Populate NULL PropertyAddress Data ----
SELECT PropertyAddress 
FROM PortfolioProject..NashvilleHousing
WHERE PropertyAddress IS NULL

SELECT *
FROM PortfolioProject..NashvilleHousing
WHERE PropertyAddress IS NULL

SELECT *
FROM PortfolioProject..NashvilleHousing
ORDER BY ParcelID

-- Matching ParcelIDs have the same PropertyAddress, UniqueId differentiates between houses with matching ParcelIDs
SELECT orig.[UniqueID ], orig.ParcelID, orig.PropertyAddress, copy.[UniqueID ],copy.ParcelID, copy.PropertyAddress, ISNULL(orig.PropertyAddress, copy.PropertyAddress) AS PropertyAddressToPopulate
FROM PortfolioProject..NashvilleHousing AS orig
JOIN PortfolioProject..NashvilleHousing AS copy
ON orig.ParcelID = copy.ParcelID AND orig.[UniqueID ] <> copy.[UniqueID ]
WHERE orig.PropertyAddress IS NULL

-- Update NULL ProperyAddresses 
UPDATE orig
SET PropertyAddress = ISNULL(orig.PropertyAddress, copy.PropertyAddress)
FROM PortfolioProject..NashvilleHousing AS orig
JOIN PortfolioProject..NashvilleHousing AS copy
ON orig.ParcelID = copy.ParcelID AND orig.[UniqueID ] <> copy.[UniqueID ]
WHERE orig.PropertyAddress IS NULL

SELECT PropertyAddress 
FROM PortfolioProject..NashvilleHousing



---- Breaking out PropertyAddress into Address, City ----
SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address, 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM PortfolioProject..NashvilleHousing

-- Create new columns for Address and City then Update columns using SUBSTRING
ALTER TABLE NashvilleHousing
ADD Address NVARCHAR(255)

UPDATE NashvilleHousing
SET Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD City NVARCHAR(255)

UPDATE NashvilleHousing
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT PropertyAddress, Address, City
FROM PortfolioProject..NashvilleHousing




---- Breaking out OwnerAddress into Address, City, State ----
SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS OwnerStreetAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS OwnerCity,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS OwnerState
FROM PortfolioProject..NashvilleHousing

-- Create new columns for Address, City, and State the Update columns using PARSENAME
ALTER TABLE NashvilleHousing
ADD OwnerStreetAddress NVARCHAR(255)

ALTER TABLE NashvilleHousing
ADD OwnerCityAddress NVARCHAR(255)

ALTER TABLE NashvilleHousing
ADD OwnerStateAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerStreetAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

UPDATE NashvilleHousing
SET OwnerCityAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

UPDATE NashvilleHousing
SET OwnerStateAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT OwnerAddress, OwnerStreetAddress, OwnerCityAddress, OwnerStateAddress
FROM NashvilleHousing
WHERE OwnerAddress IS NOT NULL



---- Standardize SoldAsVacant Data from Y and N to Yes and No ----
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant

SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'N' THEN 'No'
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	ELSE SoldAsVacant
END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = 
CASE
	WHEN SoldAsVacant = 'N' THEN 'No'
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	ELSE SoldAsVacant
END


---- Remove Duplicates ----

-- Determine duplicate data rows
SELECT *,
ROW_NUMBER() OVER (PARTITION BY ParcelID, 
								PropertyAddress, 
								SalePrice, 
								SaleDate, 
								LegalReference
								ORDER BY UniqueID) AS row_num
FROM PortfolioProject..NashvilleHousing
ORDER BY ParcelID 

-- Put all duplicate data in CTE then delete
WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER (PARTITION BY ParcelID, 
								PropertyAddress, 
								SalePrice, 
								SaleDate, 
								LegalReference
								ORDER BY UniqueID) AS row_num
FROM PortfolioProject..NashvilleHousing
)
-- SELECT *
DELETE
FROM RowNumCTE
WHERE row_num > 1