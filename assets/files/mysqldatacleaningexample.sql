/**  Motivation:  The reason the Nashville Housing project in the MySQL database using SQL
		was chosen is that it has messy, unstructured data.  The work shows the process
        of manipulating fields in columns of a large file.  Data Cleaning is essential as
        a Data Analyst.  It is common to standardize date formats, missing data, populating
        columns, slicing name and address columns, and case statements.
**/

/**  The first example standardizzed the date format. 

	 The original date data type was in a string format(September 18, 2022) and date format(2022-07-01).
     SOLUTION:
     The CONVERT() function converts the string formats to date data types.alter
     
**/

SELECT SaleDate, CONVERT(SaleDate, DATE) 
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD SaleDateConverted	    DATE;

UPDATE NashvilleHousing
SET SaleDateConverted = SaleDate;

/**  The second example handles missing data by data population.
	 
     The PropertyAddress column may contain nulls.  By definition a housing parcel may or
     may not have a housing unit on it.  I self-joined the ParcelID column.  If the Parcel IDs
     match but the Unique IDs don't along with a where clause PropertyAddress is null, 
     I can populate the PropertyAddress with the matching Parcel ID.
     
**/

SELECT     
     a.ParcelID,
     a.PropertyAddress,
     b.ParcelID,
     b.PropertyAdress
FROM NashvilleHousing a
	 JOIN
		NashvilleHousing b
			ON a.ParcelID = b.ParcelID
            AND a.UniqueID <> b.Unique
WHERE a.PropertyAddress is NULL;


    
/**  The third example uses string manipulation.  It parses the address
	 by using a a subset of a string and the function the counts the delimitors.
	 SOLUTION:
     Parse the string using SUBSTRING_INDEX, THEN USE 2 ALTER tablename
     statements for Address and city followed by the UPDATE statement to change
     the table to reflect the parsing.
     
**/

SELECT PropertyAddress, SUBSTRING_INDEX(PropertyAddress, ',', 1) AS Address,
	   PropertyAddress, SUBSTRING_INDEX(PropertyADDRESS, ',', -1) AS city
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
	 ADD PropertySplitAddress		varchar(255);
     
UPDATE NashvilleHousing
	 SET PropertySplitAddress = SUBSTRING_INDEX(PropertyAddress, ',', 1);
     
ALTER TABLE NashvilleHousing
	 ADD PropertySplitCity 			varchar(255);
     
UPDATE NashvilleHousing
	  SET PropertySplitCity = SUBSTRING_INDEX(PropertyAddress, ',', -1);
      
/** The forth example uses a string manipulation to split the OwnerAddress column into 3 components, Address, City, and State
    
    SOLUTION:
    Using the SUBSTRING_INDEX by counting several delimiters and reading the parsing either from
    the right if integer returned by the deliminter is positive or left if integer is negative.
     5t rood f 
**/

SELECT OwnerAddress, SUBSTRING_INDEX(OwnerAddress, ',', 1) AS Address,
	   OwnerAddress, SUBSTRING_INDEX(OwnerAddress, ',', 2) AS City,
       OwnerAddress, SUBSTRING_INDEX(OwnerAddress, ',', -1) AS State;
       
ALTER TABLE NashvilleHousing
	ADD OwnerSplitAddress		Nvarchar(255);
    
UPDATE NashvilleHousing
	SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1);
    
ALTER TABLE NashvilleHousing
	 ADD OwnerSplitCity		Nvarchar(255);
     
UPDATE NashvilleHousing
	 SET OwnerSplitCity = SUBSTRING_INDEX(PropertyAddress, ',', 2);
       
ALTER TABLE NashvilleHousing
	 ADD OwnerSplitState		Nvarchar(255);
     
UPDATE NashvilleHousing
	 SET OwnerSplitState = SUBSTRING_INDEX(PropertyAddress, ',', -1);
     
/**  The fifth example uses the case statement with several conditions.
	 The Sold As Vacant column is not uniform.
	 SOLUTION:
     The case statement easily creates uniformity by changing a 'Y' to a 'Yes'
     and a 'N' to a 'No'
     
**/
    
SELECT DISTINCT(SoldAsVacant),
	   COUNT(SoldAsVacant),
       TOTAL(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY COUNT;

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
         ELSE SoldAsVacant
         END
FROM NashvilleHousing;

UPDATE NashvilleHousing
	SET SoldAsVacant  = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
         ELSE SoldAsVacant
         END;

/**  The Sixth example removes duplicates.
**/

-- With is temporary view
WITH ROWNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
    PARTITION BY UniqueId,
				 ParcelID,
				 PropertyAddress,
                 SaleDate,
                 LegalReference
                 SoldAsVacant
                 OwnerName
                 OwnerAddress
                 ORDER BY
					UniqueID
                    	) row_num
FROM NashvilleHousing)
SELECT *
FROM RowNumCTE
WHERE  row_num > 1
ORDER BY PropertyAddress;

`NashvilleHousing.sql`


	
     


     
       
	

     
     
