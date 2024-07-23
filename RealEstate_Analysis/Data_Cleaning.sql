SELECT * 
FROM Housing

-- Standardize Date Format:
Select SaleDate, CONVERT(date, SaleDate)
From Housing

Update Housing
Set SaleDate = CONVERT(date,SaleDate)

Alter Table Housing
ADD SaleDateConverted Date

Update Housing
Set SaleDateConverted = CONVERT(date, SaleDate)

Select SaleDate, SaleDateConverted 
FROM Housing


-- Populate Property address
SELECT PropertyAddress
FROM Housing
Where PropertyAddress is NULL

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL( a.propertyAddress, b.PropertyAddress)
FROM Housing as a
JOIN Housing as b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is NULL

UPDATE a 
SET PropertyAddress = ISNULL(a.propertyAddress, b.propertyAddress)
FROM Housing as a
JOIN Housing as b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is NULL

-- Breaking out Address to individual columns (Address, City, State)

SELECT
SUBSTRING( PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING ( PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress) ) as City
FROM Housing

ALTER TABLE Housing
ADD PropertySplitAddress nvarchar(100)

ALTER TABLE HOUSING
ADD PropertySplitCity nvarchar(100)



UPDATE Housing
SET PropertySplitAddress = SUBSTRING( PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

UPDATE Housing
SET PropertySplitCity = SUBSTRING ( PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress) )


-- Owner Address
SELECT OwnerAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM Housing

ALTER TABLE Housing
ADD OwnerSplitAddress nvarchar(100)

ALTER TABLE HOUSING
ADD OwnerSplitCity nvarchar(100)

ALTER TABLE HOUSING
ADD OwnerSplitState nvarchar(100)

-- HAVE NOT EXECUTED THESE YET, TAKING A LOT OF TIME
UPDATE Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

UPDATE Housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

UPDATE Housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


-- Upadte Y or N to Yes or No in Sold as vacant Field:

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Housing
group by SoldAsVacant
Order by COUNT(SoldAsVacant)

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant='Y' THEN 'Yes'
	WHEN SoldAsVacant ='N' THEN 'No'
	ELSE SoldAsVacant
END
FROM Housing

UPDATE Housing
SET SoldAsVacant = CASE WHEN SoldAsVacant='Y' THEN 'Yes'
						WHEN SoldAsVacant ='N' THEN 'No'
						ELSE SoldAsVacant
					END

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From PortfolioProject.dbo.NashvilleHousing




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate