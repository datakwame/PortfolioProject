/*
Cleaning Data in SQL Queries
*/



SELECT *
FROM dbo.NahsvilleHousing


--1. Standardize SaleDate Format

SELECT SaleDate, CONVERT(date, SaleDate)
FROM NahsvilleHousing


ALTER TABLE NahsvilleHousing
Add SalesDateConverted Date;


UPDATE NahsvilleHousing
SET SalesDateConverted = CONVERT(date, SaleDate)

--SELECT SalesDateConverted
--FROM dbo.NahsvilleHousing



--2. Populate Property Address

SELECT *
FROM dbo.NahsvilleHousing
--WHERE PropertyAddress is NULL
ORDER BY ParcelID


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NahsvilleHousing a
JOIN PortfolioProject.dbo.NahsvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NahsvilleHousing a
JOIN PortfolioProject.dbo.NahsvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
--WHERE a.PropertyAddress is null



--3. Breaking Out Address Into Individual Columns (Address, City, State)

--I. Separating Property Address

SELECT PropertyAddress
FROM PortfolioProject.dbo.NahsvilleHousing


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City

FROM PortfolioProject.dbo.NahsvilleHousing


ALTER TABLE NahsvilleHousing
Add PropertySplitAddress Nvarchar(255);


UPDATE NahsvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE NahsvilleHousing
Add PropertySplitCity Nvarchar(255);


UPDATE NahsvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


SELECT *
FROM PortfolioProject.dbo.NahsvilleHousing



--II. Separating Owner Address


SELECT OwnerAddress
FROM PortfolioProject.dbo.NahsvilleHousing


SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject.dbo.NahsvilleHousing
WHERE  OwnerAddress is NOT NULL


ALTER TABLE PortfolioProject.dbo.NahsvilleHousing
ADD OwnerSplitAddress Nvarchar(255)

UPDATE PortfolioProject.dbo.NahsvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER  TABLE PortfolioProject.dbo.NahsvilleHousing
ADD OwnerSplitCity Nvarchar(255)

UPDATE PortfolioProject.dbo.NahsvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE PortfolioProject.dbo.NahsvilleHousing
ADD OwnerSplitState Nvarchar(255)

UPDATE PortfolioProject.dbo.NahsvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


SELECT *
FROM NahsvilleHousing


--4. Change Y nad N to Yes and No in "Sold and Vacant" field

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NahsvilleHousing
Group By SoldAsVacant
Order By 2


SELECT SoldAsVacant,
  CASE When SoldAsVacant = 'Y' THEN 'YES'
	   When SoldAsVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant
	   END
FROM PortfolioProject.dbo.NahsvilleHousing


Update PortfolioProject.dbo.NahsvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'YES'
	   When SoldAsVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant
	   END



--5. Remove Duplicates

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

FROM PortfolioProject.dbo.NahsvilleHousing
--order by ParcleID
)
DELETE 
FROM RowNumCTE
where row_num > 1
--order by PropertyAddress


SELECT *
FROM PortfolioProject.dbo.NahsvilleHousing 




--3. Delete Unused Columns

SELECT *
FROM PortfolioProject.dbo.NahsvilleHousing 

ALTER TABLE PortfolioProject.dbo.NahsvilleHousing 
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NahsvilleHousing
DROP COLUMN SaleDate


