/*

Cleaning Data in SQL Queries

*/



select *
from PortfolioProject..NashvilleHousing



-- Standardize Date Format


select SaleDateConverted, Convert(date,SaleDate)
from PortfolioProject..NashvilleHousing

update NashvilleHousing
set SaleDate = Convert(date,SaleDate)

-- If It doesn't update properly Use Alter Method

Alter table NashvilleHousing
add SaleDateConverted date;

update NashvilleHousing
set SaleDateConverted = Convert(date,SaleDate)


-- Populate Property Address data

select *
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID


select a.ParcelID, a.propertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-- Breaking out Address into Individual columns (Adress, City, State)

select PropertyAddress
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

Select 
substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Adress
, substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , len(PropertyAddress)) as Adress
from PortfolioProject..NashvilleHousing


Alter table NashvilleHousing
add PropertySpiltAdress Nvarchar(255);

update NashvilleHousing
set PropertySpiltAdress = substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


Alter table NashvilleHousing
add PropertySplitCity Nvarchar(255);

update NashvilleHousing
set PropertySplitCity = substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , len(PropertyAddress))




Select OwnerAddress
from PortfolioProject..NashvilleHousing


Select 
PARSENAME(replace(OwnerAddress,',','.') ,3)
, PARSENAME(replace(OwnerAddress,',','.') ,2)
,PARSENAME(replace(OwnerAddress,',','.') ,1)

from PortfolioProject..NashvilleHousing


Alter table NashvilleHousing
add OwnerSpiltAdress Nvarchar(255);

update NashvilleHousing
set OwnerSpiltAdress = PARSENAME(replace(OwnerAddress,',','.') ,3)


Alter table NashvilleHousing
add OwnerSplitCity Nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.') ,2)

Alter table NashvilleHousing
add OwnerSplitState Nvarchar(255);

update NashvilleHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.') ,1)


Select *
from PortfolioProject..NashvilleHousing


-- Change Y and N to Yes and No in "Sold as Vacant" field 

Select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2



Select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end
from PortfolioProject..NashvilleHousing


update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end



-- Remove Duplicates 


with RowNumCTE as(
select *,
	ROW_NUMBER() over (
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by 
					UniqueID
					 ) row_num

from PortfolioProject..NashvilleHousing
--order by ParcelID
)
select *
from RowNumCTE
where row_num >1
order by PropertyAddress

select *
from PortfolioProject..NashvilleHousing



-- Delete Unused Columns

select *
from PortfolioProject..NashvilleHousing


Alter table PortfolioProject..NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

Alter table PortfolioProject..NashvilleHousing
drop column SaleDate