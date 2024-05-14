use project

-- cleaning data in SQL querires

select * from NashvilleHousing
------------------------------------------------------------------------------------------
-- standerdzing the sale date in correct format

select SaleDate,  convert(Date, saledate)
from NashvilleHousing

--update NashvilleHousing
--set SaleDate = CONVERT(date, SaleDate)
--above querey dosnet work  hence we worte new query


alter table NashvilleHousing
add SaleDateConverted date

update NashvilleHousing
set SaleDateConverted = CONVERT(date, SaleDate)

select SaleDateconverted 
from NashvilleHousing

-------------------------------------------------------------------------------------------
--populate property address

select PropertyAddress
from NashvilleHousing
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID,b.PropertyAddress , isnull(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and  a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and  a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-------------------------------------------------------------------------------------------
--Breaking out address in indiviual column address,city,state


select PropertyAddress
from NashvilleHousing

select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1 ) as address ,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as address
from NashvilleHousing

alter table NashvilleHousing
add PropertysplitAddress nvarchar(225);

update NashvilleHousing
set PropertysplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1 ) 



alter table NashvilleHousing
add PropertysplitCity nvarchar(225)

update NashvilleHousing
set PropertysplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) 

select * 
from NashvilleHousing


------------------------------------------------------------------------------------------Breaking out owner address in indiviual column 

select 
PARSENAME(replace(OwnerAddress,',','.'),3),
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),1)
from NashvilleHousing

alter table NashvilleHousing
add ownersplitaddress varchar(225),
 ownersplitcity varchar(225),
 ownersplitstate varchar(225)

 update NashvilleHousing
 set ownersplitaddress = PARSENAME(replace(OwnerAddress,',','.'),3),
 ownersplitcity = PARSENAME(replace(OwnerAddress,',','.'),2),
  ownersplitstate = PARSENAME(replace(OwnerAddress,',','.'),1)


  select * from NashvilleHousing

  ------------------------------------------------------------------------------------------change  Y and  N as a Yes and NO in SoldAsVacant  column

select distinct(SoldAsVacant) ,count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by  2

select SoldAsVacant,
case when SoldAsVacant ='Y'then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end 
from NashvilleHousing
group by SoldAsVacant

update NashvilleHousing
set SoldAsVacant=case when SoldAsVacant ='Y'then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end 

-------------------------------------------------------------------------------------------Remove duplicate
with rownumCTE as(
select *,
	ROW_NUMBER()over( 
		partition by ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference
		order by uniqueid
) rownum

from NashvilleHousing
)
delete 
from rownumCTE
where rownum >1

with rownumCTE as(
select *,
	ROW_NUMBER()over( 
		partition by ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference
		order by uniqueid
) rownum

from NashvilleHousing
)
select *
from rownumCTE
where rownum >1


------------------------------------------------------------------------------------------Delete unused column

alter table NashvilleHousing
drop column OwnerAddress