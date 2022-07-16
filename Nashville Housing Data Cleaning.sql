
--Cleaning Data in SQL Queries

Select * 
from PortfolioProject.dbo.NashvilleHousing


-- Standardize Date format

Select SaleDate, cast(SaleDate as date)
from PortfolioProject.dbo.NashvilleHousing;


alter table NashvilleHousing     -- Adding new Column SaleDateConverted
add SaleDateConverted Date;

update PortfolioProject.dbo.NashvilleHousing
set SaleDateConverted = cast(SaleDate as date)    -- Converting SaleDate to date format and inserting into the new column

Select SaleDateConverted
from PortfolioProject.dbo.NashvilleHousing;


-- Populate Property Address data

Select *
from PortfolioProject.dbo.NashvilleHousing    -- Same property address for same Parcel ID
--where PropertyAddress is null;
order by ParcelID



Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]!=b.[UniqueID ]
where a.PropertyAddress is null



update a
set PropertyAddress=isnull(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID=b.ParcelID and a.[UniqueID ]!=b.[UniqueID ]
where a.PropertyAddress is null




-- Breaking out address into individual columns (Address, city, state)

select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing



select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as Address
from PortfolioProject.dbo.NashvilleHousing


alter table PortfolioProject.dbo.NashvilleHousing
add PropertySplitAddress nvarchar(255)

update PortfolioProject.dbo.NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

alter table PortfolioProject.dbo.NashvilleHousing
add PropertySplitCity nvarchar(255)

update PortfolioProject.dbo.NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))

select *
from PortfolioProject.dbo.NashvilleHousing





select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing;


select PARSENAME(REPLACE(OwnerAddress,',','.'),3)
, PARSENAME(REPLACE(OwnerAddress,',','.'),2)
, PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from PortfolioProject.dbo.NashvilleHousing
where OwnerAddress is not null



alter table PortfolioProject.dbo.NashvilleHousing
add OwnerSplitAddress nvarchar(255)


update PortfolioProject.dbo.NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)


alter table PortfolioProject.dbo.NashvilleHousing
add OwnerSplitCity nvarchar(255)


update PortfolioProject.dbo.NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)


alter table PortfolioProject.dbo.NashvilleHousing
add OwnerSplitState nvarchar(255)


update PortfolioProject.dbo.NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)



select *
from PortfolioProject.dbo.NashvilleHousing




-- Change Y and N to Yes and No in 'Sold as vacant' field


select Distinct(SoldAsVacant),count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant
, case when SoldAsVacant='Y' then 'Yes'
       when SoldAsVacant='N' then 'No'
	   else SoldAsVacant
	   end
from PortfolioProject.dbo.NashvilleHousing


update PortfolioProject.dbo.NashvilleHousing
set SoldAsVacant=case when SoldAsVacant='Y' then 'Yes'
       when SoldAsVacant='N' then 'No'
	   else SoldAsVacant
	   end



-- Remove Duplicates

with RowNumCTE as (
select *, ROW_NUMBER() over(partition by ParcelID,PropertyAddress,SalePrice, SaleDate, LegalReference order by UniqueID) row_num
from PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)

DELETE from RowNumCTE
where row_num>1



-- Delete Unused Columns


Select *
from PortfolioProject.dbo.NashvilleHousing


alter table PortfolioProject.dbo.NashvilleHousing
drop column OwnerAddress,TaxDistrict,PropertyAddress

alter table PortfolioProject.dbo.NashvilleHousing
drop column SaleDate