SELECT * FROM [SQL_Project].[dbo].[NashwilleHousing]

--Standardize the date format

ALTER TABLE [SQL_Project].[dbo].[NashwilleHousing] ADD SaleDateConverted Date;

UPDATE [SQL_Project].[dbo].[NashwilleHousing] SET SaleDateConverted = CONVERT(Date, SaleDate)

UPDATE [SQL_Project].[dbo].[NashwilleHousing] SET SaleDate = CONVERT (Date, SaleDate)

SELECT SaleDate, CONVERT(Date, SaleDate)  FROM [SQL_Project].[dbo].[NashwilleHousing]

SELECT SaleDateConverted, CONVERT(Date, SaleDate) FROM [SQL_Project].[dbo].[NashwilleHousing]

--Populate Property address data

SELECT * FROM [SQL_Project].[dbo].[NashwilleHousing]
ORDER BY ParcelID

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress) 
FROM [SQL_Project].[dbo].[NashwilleHousing] A JOIN SQL_Project.dbo.NashwilleHousing B
ON A.ParcelID =B.ParcelID AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

UPDATE A
SET A.PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress) 
FROM [SQL_Project].[dbo].[NashwilleHousing] A JOIN SQL_Project.dbo.NashwilleHousing B
ON A.ParcelID =B.ParcelID AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

--Breaking out the Property Address into individual columns (Address, City, State)

SELECT PropertyAddress
FROM SQL_Project.dbo.NashwilleHousing

SELECT SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS ADDRESS2
FROM SQL_Project.dbo.NashwilleHousing

ALTER TABLE [SQL_Project].[dbo].[NashwilleHousing] ADD PropertySplitAddress Nvarchar(255);
UPDATE [SQL_Project].[dbo].[NashwilleHousing] 
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE [SQL_Project].[dbo].[NashwilleHousing] ADD PropertySplitCity Nvarchar(255);
UPDATE [SQL_Project].[dbo].[NashwilleHousing] 
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


SELECT *
FROM SQL_Project.dbo.NashwilleHousing

--Breaking out the Owner Address into individual columns (Address, City, State)

SELECT OwnerAddress
FROM SQL_Project.dbo.NashwilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM SQL_Project.dbo.NashwilleHousing

ALTER TABLE [SQL_Project].[dbo].[NashwilleHousing] ADD OwnerSplitAddrName Nvarchar(255);
UPDATE [SQL_Project].[dbo].[NashwilleHousing] 
SET OwnerSplitAddrName = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE [SQL_Project].[dbo].[NashwilleHousing] ADD OwnerSplitAddrCity Nvarchar(255);
UPDATE [SQL_Project].[dbo].[NashwilleHousing] 
SET OwnerSplitAddrCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE [SQL_Project].[dbo].[NashwilleHousing] ADD OwnerSplitAddrState Nvarchar(255);
UPDATE [SQL_Project].[dbo].[NashwilleHousing] 
SET OwnerSplitAddrState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT *
FROM SQL_Project.dbo.NashwilleHousing

--Change Y and N and No in "Sold as Vacant" field

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant) AS Count
FROM SQL_Project.dbo.NashwilleHousing
group by SoldAsVacant
ORDER BY COUNT

SELECT SoldAsVacant, 
 CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
      WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END
FROM SQL_Project.dbo.NashwilleHousing

UPDATE SQL_Project.dbo.NashwilleHousing 
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
      WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant) AS Count
FROM SQL_Project.dbo.NashwilleHousing
group by SoldAsVacant
ORDER BY COUNT

--Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num
FROM SQL_Project.dbo.NashwilleHousing)

DELETE FROM RowNumCTE 
WHERE row_num > 1

--Delete unused Column

Select *
FROM SQL_Project.dbo.NashwilleHousing

ALTER TABLE SQL_Project.dbo.NashwilleHousing 
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict

ALTER TABLE SQL_Project.dbo.NashwilleHousing 
DROP COLUMN SaleDate