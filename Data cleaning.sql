/* 

Cleaning Data in SQL queries

*/

Select *
From PortfolioProject..Nashville_Housing

-- Standardize Date format

Select SaleDate,Convert(Date,SaleDate) As SaleDateConverted
From PortfolioProject..Nashville_Housing

Alter Table Nashville_Housing
Add SaleDateCOnverted Date;

Update Nashville_Housing
Set SaleDate = Convert(Date,SaleDate)

--Populate Property Address Data

-- To see the address that are null and available
Select *
From PortfolioProject..Nashville_Housing
--Where PropertyAddress is Null
Order by ParcelID


--To Populate Property address 

Select a.Parcelid,a.PropertyAddress,b.parcelId, b.propertyaddress, ISNULL(a.propertyaddress,b.propertyaddress)
From PortfolioProject..Nashville_Housing a
Join PortfolioProject..Nashville_housing b
ON a.Parcelid = B.parcelId
And a.uniqueID <> b.UniqueID
Where A.PropertyAddress is Null 

Update a --Use alias in Update
Set PropertyAddress = ISNULL(a.propertyaddress,b.propertyaddress)
From PortfolioProject..Nashville_Housing a
Join PortfolioProject..Nashville_housing b
ON a.Parcelid = B.parcelId
And a.uniqueID <> b.UniqueID
Where A.PropertyAddress is Null 



--Breaking Address into Address,City,State

Select PropertyAddress
From PortfolioProject..Nashville_Housing
--Where PropertyAddress is Null
--Order by ParcelID;

Select
Substring(PropertyAddress,1,CharIndex(',',PropertyAddress)-1)As Address,
Substring(PropertyAddress,CharIndex(',',PropertyAddress)+1,Len(PropertyAddress))As City

From PortfolioProject..Nashville_Housing;


Alter Table Nashville_Housing
Add PropertySplitAddress nvarchar(255);

Update dbo.Nashville_Housing
Set PropertySplitAddress = Substring(PropertyAddress,1,CharIndex(',',PropertyAddress)-1);

Alter Table Nashville_Housing
Add PropertySplitCity nvarchar(255);

Update Nashville_Housing
Set PropertySplitCity = Substring(PropertyAddress,CharIndex(',',PropertyAddress)+1,Len(PropertyAddress));


Select OwnerAddress, ParseName(Replace(OwnerAddress,',','.'),1) As State ,
 ParseName(Replace(OwnerAddress,',','.'),2)As City,
  ParseName(Replace(OwnerAddress,',','.'),3) As Address
From PortfolioProject..Nashville_Housing
Where OwnerAddress is not nuLl  --Too many null entries in the dataset

Alter Table Nashville_Housing
Add OwnerSplitAddress nvarchar(255);

Update dbo.Nashville_Housing
Set OwnerSplitAddress = ParseName(Replace(OwnerAddress,',','.'),3)

Alter Table Nashville_Housing
Add OwnerSplitState nvarchar(255);

Update dbo.Nashville_Housing
Set OwnerSplitState = ParseName(Replace(OwnerAddress,',','.'),1)

Alter Table Nashville_Housing
Add OwnerSplitCity nvarchar(255);

Update dbo.Nashville_Housing
Set OwnerSplitCity = ParseName(Replace(OwnerAddress,',','.'),2)


Select *
From PortfolioProject..Nashville_Housing
Where OwnerAddress is not nuLl



--Changing Y and N to Yes and No in "Sold As Vacant' Field

Select Distinct SoldAsVacant, Count(SoldAsVacant)
From PortfolioProject..Nashville_Housing
Group By SoldasVacant
Order By 2


Select SoldAsVacant
, Case
		when SoldAsVacant = 'Y' Then 'Yes'
		when SoldAsVacant = 'N' Then 'NO'
		Else SoldAsvacant
		End
From PortfolioProject..Nashville_Housing


Update Nashville_Housing
Set SoldAsVacant = Case
		when SoldAsVacant = 'Y' Then 'Yes'
		when SoldAsVacant = 'N' Then 'NO'
		Else SoldAsvacant
		End 


--Remove Duplicates
With RowNumCTE AS (
Select *, Row_Number() Over (
Partition By ParcelID,
			 PropertyAddress,
			 SaleDate,
			 SalePrice,
			 LegalReference
			 Order BY 
			 PropertyAddress,ParcelID) Row_num
From PortfolioProject..Nashville_Housing)


Delete
From RowNumCTE
Where row_num > 1


--Delete Unused columns

Select *
From PortfolioProject.dbo.Nashville_Housing

ALter Table Nashville_Housing
Drop COlumn SaleDate, TaxDistrict, OwnerAddress, PropertyAddress


