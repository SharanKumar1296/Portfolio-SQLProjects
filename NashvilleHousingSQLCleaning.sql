/*
Cleaning Data using SQL Queries
*/

select * 
from [Portfolio Project]..NashvilleHousing

---------------------------------------------------------------------------------------------
--Standardize the SaleDate

select SaleDate,CONVERT(Date,SaleDate) -- The time in the SaleDate serves no purpose
from [Portfolio Project]..NashvilleHousing

Update [Portfolio Project]..NashvilleHousing -- Usually works with this method but not changing the data type despite updating the table
Set SaleDate = Convert(Date,SaleDate)

alter table [Portfolio Project]..NashvilleHousing -- Created a new column called SaleDateConverted with datatype as Date which can now accept the new converted format. 
add SaleDateConverted date

update [Portfolio Project]..NashvilleHousing -- Updated the newly created column SaleDateConverted with the required date format
set SaleDateConverted = convert(date,SaleDate)

select SaleDateConverted,convert(date,SaleDate)
from [Portfolio Project]..NashvilleHousing

---------------------------------------------------------------------------------------------
--Populate the Property Address Data

select * 
from [Portfolio Project]..NashvilleHousing
--On examining the data we can determine that a particular PropertyAddress has the same ParcelID.
--Going forward we intend to populate the NULLs in PropertyAddress by comparing the ParcelID with other identical ParcelID in the given dataset

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from [Portfolio Project]..NashvilleHousing a
join [Portfolio Project]..NashvilleHousing b --Creating a self join to compare the NULLs with the identical parcelID in the dataset
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is NULL

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from [Portfolio Project]..NashvilleHousing a
join [Portfolio Project]..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is NULL

---------------------------------------------------------------------------------------------
--Breaking down the PropertyAddress and OwnerAddress (Address,City,State)

select PropertyAddress
from [Portfolio Project]..NashvilleHousing

select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1)-- Splitting using substring and charindex to get the position
, SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress))
from [Portfolio Project]..NashvilleHousing

alter table [Portfolio Project]..NashvilleHousing--Creating new columns for the split
add PropertySplitAddress nvarchar(255)
, PropertySplitCity nvarchar(255)

update [Portfolio Project]..NashvilleHousing--Updating the columns with data
set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1)
, PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress))


select OwnerAddress
from [Portfolio Project]..NashvilleHousing

select PARSENAME(replace(OwnerAddress,',','.'),3)--Using ParseName instead of substring so as to make it brief
, PARSENAME(replace(OwnerAddress,',','.'),2)--NOTICE we have to replace the ',' with a '.' as parsename works only with '.'
, PARSENAME(replace(OwnerAddress,',','.'),1)--Lower number displays the rightmost part first in contradiction to the usual split
from [Portfolio Project]..NashvilleHousing

alter table [Portfolio Project]..NashvilleHousing--Creating new columns for the split
add OwnerSplitAddress nvarchar(255)
, OwnerSplitCity nvarchar(255)
, OwnerSplitState nvarchar(255)

update [Portfolio Project]..NashvilleHousing--Updating the columns with data
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3)
, OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'),2)
, OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'),1) 

select *
from [Portfolio Project]..NashvilleHousing

---------------------------------------------------------------------------------------------
--Change Y and N to Yes and No in SoldAsVacant 

select Distinct(SoldAsVacant),COUNT(SoldAsVacant)--Checking the count of Y and N and if any other values in SoldAsVacant 
from [Portfolio Project]..NashvilleHousing
group by SoldAsVacant
order by 2 --Order by the second column 

select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'-- Using case statements to replace the Y and N
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end
from [Portfolio Project]..NashvilleHousing

update [Portfolio Project]..NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
						when SoldAsVacant = 'N' then 'No'
						else SoldAsVacant
						end

---------------------------------------------------------------------------------------------
-- Removing Duplicates

select *
, ROW_NUMBER() over( --Here we are assigning a sequential rank number to a new record in the dataset
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference 
				 order by UniqueID
				 ) row_num
from [Portfolio Project]..NashvilleHousing

With RowNumCTE As ( --This creates a CTE which allows us to view the duplicates of the dataset
select *
, ROW_NUMBER() over( --Here we are assigning a sequential rank number to a new record in the dataset
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference 
				 order by UniqueID
				 ) row_num
from [Portfolio Project]..NashvilleHousing
)
select *
from RowNumCTE 
where row_num>1
order by PropertyAddress

With RowNumCTE As ( --This deletes all the duplicates of the dataset
select *
, ROW_NUMBER() over( --Here we are assigning a sequential rank number to a new record in the dataset
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference 
				 order by UniqueID
				 ) row_num
from [Portfolio Project]..NashvilleHousing
)
delete
from RowNumCTE 
where row_num>1

---------------------------------------------------------------------------------------------
--Delete Unused Columns

select *
from [Portfolio Project]..NashvilleHousing

alter table [Portfolio Project]..NashvilleHousing
drop column SaleDate,PropertyAddress,OwnerAddress,TaxDistrict

---------------------------------------------------------------------------------------------