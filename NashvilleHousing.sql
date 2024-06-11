/* 

Cleaning Data in SQL Queries

*/

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

-----------------------------------------------------------------------------------------------------------

--Standardize Date Format

SELECT CONVERT(Date, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing 
/*This doesn't change the table but we can see what it should look like. Before altering the table, we see that SaleDate is still a DateTime*/

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)
/*UPDATE will not change data types, so this is effectively useless*/



ALTER TABLE NashvilleHousing
ADD saleDateConverted Date
/*We add a new column with data type Date*/

UPDATE NashvilleHousing
SET saleDateConverted = CONVERT(Date, SaleDate)


SELECT saleDateConverted, SaleDate
FROM PortfolioProject.dbo.NashvilleHousing 
/*Now we have saleDateConverted and the origina SaleDate in the table*/

------------------------------------------------------------------------------------------------------------

--Populate Property Address data

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL
ORDER BY ParcelId DESC
/*Some PropertyAddress fields are null. We're going to join duplicates to get rid of some null values.*/


SELECT a.ParcelID
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is NULL
/*UniqueID will always be unique, but the ParcelID can repeat. 
If there is a repeat ParcelID and one of those has a NULL value for the property address and the other doesn't, 
then the NULL valeus will be updated with an address.
This joins but doesn't update.*/

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) /*Updates null values if there are 2 UniqueIDs and one is null*/
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is NULL 




-----------------------------------------------------------------------------------------------------------
--Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing
/*The addresses have a commma separating the address and the city. It would be better to have them in two columns.*/
SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address, 
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1,	LEN(PropertyAddress)) AS City
FROM PortfolioProject.dbo.NashvilleHousing
/*This is a test to make sure I am splitting the addresses correctly.*/

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET	PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1,	LEN(PropertyAddress)) 



SELECT 
	PARSENAME(REPLACE(OwnerAddress,',','.') , 3),
	PARSENAME(REPLACE(OwnerAddress,',','.') , 2),
	PARSENAME(REPLACE(OwnerAddress,',','.') , 1)
FROM PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress =PARSENAME(REPLACE(OwnerAddress,',','.') , 3)

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.') , 2)

UPDATE PortfolioProject.dbo.NashvilleHousing
SET	OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.') , 1)

SELECT * 
FROM PortfolioProject.dbo.NashvilleHousing




-----------------------------------------------------------------------------------------------------------

--Changing Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT 
	SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant =	
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END


-----------------------------------------------------------------------------------------------------------
--Remove duplicates
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

	FROM PortfolioProject.dbo.NashvilleHousing
	--ORDER BY ParcelID
	)
	--DELETE  
	--FROM RowNumCTE
	--WHERE row_num > 1
	--ORDER BY PropertyAddress
	
	SELECT *  
	FROM RowNumCTE
	WHERE row_num > 1

	




-----------------------------------------------------------------------------------------------------------

--Delete Unused Columns

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


