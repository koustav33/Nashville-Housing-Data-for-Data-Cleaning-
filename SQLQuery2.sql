
/* CCleaning Data in SQL Queries */

select *
from Potfolio_Project.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select saleDate, CONVERT(Date,SaleDate)
From Potfolio_Project.dbo.NashvilleHousing


Update Potfolio_Project.dbo.NashvilleHousing
SET saleDate = CONVERT(Date,saleDate)

-- If it doesn't Update properly

ALTER TABLE  Potfolio_Project.dbo.NashvilleHousing
Add SaleDateConverted Date;

Update  Potfolio_Project.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


--------------------------------------------------------------------------------------------------------------------------
-- Populate Property Address data

select *
from Potfolio_Project.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.propertyAddress,b.PropertyAddress)
from Potfolio_Project.dbo.NashvilleHousing a
join  Potfolio_Project.dbo.NashvilleHousing b
	on a.ParcelID=b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress= ISNULL(a.propertyAddress,b.PropertyAddress)
from Potfolio_Project.dbo.NashvilleHousing a
join  Potfolio_Project.dbo.NashvilleHousing b
	on a.ParcelID=b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------

-- Breakingout Address int individual columns(Address,City,State)

select PropertyAddress
from Potfolio_Project.dbo.NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) as Address
,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1 , len(PropertyAddress)) as Address

from Potfolio_Project.dbo.NashvilleHousing

ALTER TABLE  Potfolio_Project.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update  Potfolio_Project.dbo.NashvilleHousing
SET PropertySplitAddress =SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) 

ALTER TABLE  Potfolio_Project.dbo.NashvilleHousing
Add PropertySplitcity Nvarchar(255);

Update  Potfolio_Project.dbo.NashvilleHousing
SET PropertySplitcity  = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1 , len(PropertyAddress))

Select*
from Potfolio_Project.dbo.NashvilleHousing


--owneraddress
Select OwnerAddress
from Potfolio_Project.dbo.NashvilleHousing

Select 
PARSENAME (replace(OwnerAddress, ',' ,'.'),3)
,PARSENAME (replace(OwnerAddress, ',' ,'.'),2)
,PARSENAME (replace(OwnerAddress, ',' ,'.'),1)
from Potfolio_Project.dbo.NashvilleHousing

ALTER TABLE  Potfolio_Project.dbo.NashvilleHousing
Add OwnerSplitAddres Nvarchar(255);

Update  Potfolio_Project.dbo.NashvilleHousing
SET OwnerSplitAddres =PARSENAME(replace(OwnerAddress, ',' ,'.'),3)

ALTER TABLE  Potfolio_Project.dbo.NashvilleHousing
Add OwnerSplitcity Nvarchar(255);

Update  Potfolio_Project.dbo.NashvilleHousing
SET OwnerSplitCity  = PARSENAME (replace(OwnerAddress, ',' ,'.'),2)

ALTER TABLE  Potfolio_Project.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update  Potfolio_Project.dbo.NashvilleHousing
SET OwnerSplitState  = PARSENAME (replace(OwnerAddress, ',' ,'.'),1)

Select*
from Potfolio_Project.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant),count(SoldAsVacant)
from Potfolio_Project.dbo.NashvilleHousing
group by(SoldAsVacant)
order by 2

select SoldAsVacant
,case when SoldAsVacant= 'Y' Then 'Yes'
	when SoldAsVacant= 'N' Then 'No'
	else SoldAsVacant
	end
from Potfolio_Project.dbo.NashvilleHousing

update Potfolio_Project.dbo.NashvilleHousing
set SoldAsVacant= case when SoldAsVacant= 'Y' Then 'Yes'
	when SoldAsVacant= 'N' Then 'No'
	else SoldAsVacant
	end

--------------------------------------------------------------------------------------------------------------------------
--Remove Duplicates

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

From Potfolio_Project.dbo.NashvilleHousing
--order by ParcelID
)
select*
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

/* to delete teh duplicate rows

Delete
From RowNumCTE
Where row_num > 1
*/

--------------------------------------------------------------------------------------------------------------------------
--Unused Columns

Select*
from Potfolio_Project.dbo.NashvilleHousing

Alter Table Potfolio_Project.dbo.NashvilleHousing
drop column PropertyAddress,OwnerAddress,OwnerSplitAddres,TaxDistrict

Alter Table Potfolio_Project.dbo.NashvilleHousing
drop column SaleDate