------------------------------------------------------------
-- DATA ANALYSIS PORTFOLIO PROJECT - DATA CLEANING IN SQL --
------------------------------------------------------------


SELECT *
FROM PortfolioProject2..NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------------------------------------

-- Standarizing Date Format (Using CONVERT / ALTER TABLE)


SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM PortfolioProject2..NashvilleHousing

UPDATE PortfolioProject2..NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE PortfolioProject2..NashvilleHousing
ADD SaleDateConverted Date; 

UPDATE PortfolioProject2..NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


--------------------------------------------------------------------------------------------------------------------------------------------------------

-- Populating Property Address Data


SELECT *
FROM PortfolioProject2..NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject2..NashvilleHousing a
JOIN PortfolioProject2..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject2..NashvilleHousing a
JOIN PortfolioProject2..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


--------------------------------------------------------------------------------------------------------------------------------------------------------

-- Breaking Out Address Into Individual Columns (Address, City, State)


-- OPTION 1) SUBSTRING (On PropertyAddress)

SELECT PropertyAddress
FROM PortfolioProject2..NashvilleHousing
--WHERE PropertyAddress is null
--ORDER BY ParcelID


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS Address
FROM PortfolioProject2..NashvilleHousing


ALTER TABLE PortfolioProject2..NashvilleHousing
ADD PropertySplitAddress nvarchar(255); 

UPDATE PortfolioProject2..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE PortfolioProject2..NashvilleHousing
ADD PropertySplitCity nvarchar(255); 

UPDATE PortfolioProject2..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


SELECT *
FROM PortfolioProject2..NashvilleHousing


-- OPTION 2) PARSENAME & REPLACE (On OwnerAddress)

SELECT OwnerAddress
FROM PortfolioProject2..NashvilleHousing


SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
FROM PortfolioProject2..NashvilleHousing


ALTER TABLE PortfolioProject2..NashvilleHousing
ADD OwnerSplitAddress nvarchar(255); 

UPDATE PortfolioProject2..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

ALTER TABLE PortfolioProject2..NashvilleHousing
ADD OwnerSplitCity nvarchar(255); 

UPDATE PortfolioProject2..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE PortfolioProject2..NashvilleHousing
ADD OwnerSplitState nvarchar(255); 

UPDATE PortfolioProject2..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)


SELECT *
FROM PortfolioProject2..NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field (Using CASE and UPDATE statements)


SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject2..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM PortfolioProject2..NashvilleHousing


UPDATE PortfolioProject2..NashvilleHousing
SET SoldAsVacant =
CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END


--------------------------------------------------------------------------------------------------------------------------------------------------------

-- Removing Duplicates (Using CTE and Windows function)


WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM PortfolioProject2..NashvilleHousing
--ORDER BY ParcelID
)
DELETE 
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress

-- (Replaced DELETE with SELECT * and uncommented ORDER BY to check if all were deleted)


--------------------------------------------------------------------------------------------------------------------------------------------------------

-- Deleting Unused Columns


SELECT *
FROM PortfolioProject2..NashvilleHousing


ALTER TABLE PortfolioProject2..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject2..NashvilleHousing
DROP COLUMN SaleDate
