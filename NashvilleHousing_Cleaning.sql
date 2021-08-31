-- Review Table
SELECT TOP(10) *
FROM PortfolioProject.dbo.NashvilleHousing;


-- For column 'SaleDate'
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate);

SELECT SaleDateConverted
FROM PortfolioProject.dbo.NashvilleHousing;


-- For column 'PropertyAddress'
SELECT a.UniqueID, a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
    ON a.ParcelID = b.ParcelID
       AND a.UniqueID != b.UniqueID
WHERE a.PropertyAddress IS NULL;


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
    ON a.ParcelID = b.ParcelID
       AND a.UniqueID != b.UniqueID
WHERE a.PropertyAddress IS NULL;


SELECT
    PropertyAddress,
    SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1),
    TRIM(SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)))
FROM PortfolioProject.dbo.NashvilleHousing;


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = TRIM(SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)));


-- For column 'OwnerAddress'
SELECT 
    TRIM(OwnerAddress),
    PARSENAME(REPLACE(TRIM(OwnerAddress), ',', '.'), 3),
    PARSENAME(REPLACE(TRIM(OwnerAddress), ',', '.'), 2),
    PARSENAME(REPLACE(TRIM(OwnerAddress), ',', '.'), 1)
FROM PortfolioProject.dbo.NashvilleHousing;


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(TRIM(OwnerAddress), ',', '.'), 3);


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(TRIM(OwnerAddress), ',', '.'), 2);


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitState NVARCHAR(50);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(TRIM(OwnerAddress), ',', '.'), 1);


-- For column 'SoldAsVacant'
SELECT DISTINCT SoldAsVacant
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
                        WHEN SoldAsVacant = 'N' THEN 'NO'
                        ELSE SoldAsVacant
                   END


-- Remove duplicates
WITH RowNumCTE AS(
    SELECT *, 
           ROW_NUMBER() OVER ( 
                PARTITION BY ParcelID, 
                             PropertyAddress,
                             SalePrice,
                             SaleDate,
                             LegalReference
                ORDER BY UniqueID) AS RowNum
    FROM PortfolioProject.dbo.NashvilleHousing)

DELETE FROM RowNumCTE
WHERE RowNum > 1;


-- Delete unused columns
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress, TaxDistrict