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



/*so let's go back up to the top we're going to recap what we did really quick so using this convert we tried to
50:39
standardize the date format or change the date format may or may not have worked for you didn't work for me we populated this property address
50:47
which we did that before we broke this out because if we reversed
50:53
it if we broke these addresses out into individual columns and then we populated this thing um
51:00
we would have because then we went and deleted uh we went and deleted this column oops
51:06
sorry we went and deleted this property address so we wouldn't have actually gotten any of
51:11
that data so there was a reason it was in that order don't mess that up that's happened so we
51:16
broke it out we did that to using substring chart index as well as parse name and replace
51:25
then we went through and we changed yes to node or y and ends to yes's and no's using case statements then we use we
51:33
removed duplicates using a row number a cte and windows function of partition by
51:40
and in the end we deleted a few useless columns that we no longer want to see because they are horrible and terrible
51:47
and you know we don't want to see them anymore that is the entire project that was
51:54
everything and you did it and i'm honestly super proud of you for sticking around this long
52:00
this this was not necessarily an easy project we used quite a few new things that i may have not talked
52:05
about or showed you before um this to me is just the beginning right this is just a a glimpse into all
52:13
the things that you need to do you need to look for in order to clean data so you know i
52:19
really do think this is a good portfolio project because it will show that you understand and know how to clean the
52:25
data although this is not an end-to-end project right that could that would take a long time and a lot more
52:32
exploratory analysis looking into the data to figure out what we need to change
52:37
but for all intents and purposes i mean this is a pretty good project for cleaning data and i hope
52:43
that you learned something i also hope that you worked on this hard if you want to make any improvements
52:48
please do that this is not perfect by any means there's other things that you could change
52:54
you could you know i don't even know i'm not even going to try to guess you could do other things to this data though
53:00
um and and create your own queries create your own um data cleaning uh a part of this and
53:06
so um you know do that if you were able to get this the etl part of it done do that i think
53:13
it'd be really really cool again i was able to get it to work but i don't think
53:18
90 of people out there would be able to get it to work um it's just every computer is different
53:24
every server is configured differently um and so it would just be a huge pain
53:29
so i decided to cut that on and i'm sorry but hopefully this will suffice um with
53:35
that being said this is it you made it all the way to the end again i'm super proud you guys are doing fantastic
53:41
you guys are the ones putting in the hard work to build the portfolio for your future job i mean
53:47
it's not easy but you're putting in the work and so and so kudos to you um in our next video we're
53:53
gonna be going into python for the very first time really excited about that one because i
53:59
think the only python video that i have up right now is on one where i was scraping data from twitter so um you know this will be a nice
54:07
change of pace or a little bit different content that i normally put out and so i'm really excited about it and i
54:12
hope you are as well with that being said i am done with the video i'm gonna be stopping it soon thank you
54:19
for joining me if you liked this video be sure to subscribe be sure to like this video leave a
54:25
comment below telling me how it changed your life and i will see you in the next video bye
54:38
[Music]
54:43
you*/