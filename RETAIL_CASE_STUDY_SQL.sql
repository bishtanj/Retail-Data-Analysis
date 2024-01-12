-----------------------------------DATA PREPERATION AND UNDERSTANDING---------------------------------------
--ANS1: 
 SELECT COUNT (*)  AS TOTAL_ROWS_CUST FROM CUSTOMER  
 SELECT COUNT (*) AS TOTAL_ROWS_PROD_CAT FROM prod_cat_info 
 SELECT COUNT (*) AS TOTAL_ROWS_TRANS FROM Transactions 

 --ANS 2: 
 SELECT COUNT(TOTAL_AMT) FROM Transactions
 WHERE total_amt <0 

 --ANS3: 
 SELECT CONVERT(DATE, DOB, 105) FROM Customer
 SELECT CONVERT(DATE, tran_date, 105) FROM Transactions

 --ANS4: 
 SELECT DATEDIFF(DAY, MIN(CONVERT(DATE, TRAN_DATE, 105)), MAX(CONVERT(DATE, TRAN_DATE, 105))) AS DIFF_DAYS, 
 DATEDIFF(MONTH, MIN(CONVERT(DATE, TRAN_DATE, 105)), MAX(CONVERT(DATE, TRAN_DATE, 105))) AS DIFF_MONTHS,  
 DATEDIFF(YEAR, MIN(CONVERT(DATE, TRAN_DATE, 105)), MAX(CONVERT(DATE, TRAN_DATE, 105))) AS DIFF_YEARS 
 FROM Transactions

 --ANS 5:
 SELECT PROD_CAT
 FROM prod_cat_info
 WHERE PROD_SUBCAT = 'DIY'

 ------------------------------------------DATA ANALYSIS-----------------------------------------------



--ANS 1:
SELECT TOP 1 Store_type, COUNT(TRANSACTION_ID) AS TRAN_COUNT
FROM Transactions
GROUP BY Store_type
ORDER BY TRAN_COUNT DESC

--ANS 2:
SELECT GENDER, COUNT(customer_Id) AS GENDER_COUNT
FROM Customer
WHERE Gender IN ('M', 'F')
GROUP BY Gender



--ANS 3:
SELECT top 1
CITY_CODE, COUNT(CUSTOMER_ID) CUST_CNT
FROM CUSTOMER
GROUP BY CITY_CODE
ORDER BY CUST_CNT DESC



--ANS 4:
SELECT COUNT(PROD_SUBCAT) AS SUBCAT_CONT
FROM prod_cat_info
WHERE PROD_CAT = 'BOOKS'
GROUP BY PROD_CAT



--ANS 5:
SELECT TOP 1 QTY AS MAX_QTY FROM Transactions
ORDER BY QTY DESC



--ANS 6:
SELECT SUM(TOTAL_AMT) AS TOTAL_REVENUE
FROM Transactions AS A
INNER JOIN prod_cat_info AS B ON B.prod_sub_cat_code = A.prod_subcat_code AND 
A.prod_cat_code=B.prod_cat_code
WHERE PROD_CAT IN ('BOOKS' , 'ELECTRONICS')



--ANS 7:

SELECT COUNT (*) AS CUST_TRAN_COUNT
FROM (
      SELECT a.customer_id, COUNT(b.transaction_id) AS num_transactions
      FROM customer a
      LEFT JOIN transactions b ON a.customer_id = b.cust_id
      WHERE b.total_amt not like '-%'
      GROUP BY a.customer_id
      HAVING COUNT(b.transaction_id) > 10
 ) AS X


--ANS 8:
SELECT SUM(TOTAL_AMT) AS REVENUE
FROM Transactions AS A
INNER JOIN prod_cat_info AS B 
ON A.prod_subcat_code= B.prod_sub_cat_code AND A.prod_cat_code=B.prod_cat_code
WHERE prod_cat IN ('ELECTRONICS', 'CLOTHING')
AND Store_type = 'FLAGSHIP STORE'



--ANS 9:

SELECT C.prod_subcat, SUM(A.total_amt) AS REVENUE FROM Transactions AS A
INNER JOIN Customer AS B ON A.cust_id=B.customer_Id
INNER JOIN prod_cat_info AS C ON A.prod_cat_code= C.prod_cat_code 
AND A.prod_subcat_code=C.prod_sub_cat_code
WHERE  B.Gender = 'M' AND C.prod_cat= 'Electronics'
GROUP BY C.prod_subcat


--ANS 10:
SELECT TOP 5 PROD_SUBCAT, (SUM(TOTAL_AMT)/(SELECT SUM(TOTAL_AMT) FROM Transactions))*100 AS PERCANTAGE_OF_SALES, 
(COUNT(CASE WHEN QTY< 0 THEN QTY ELSE NULL END)/SUM(QTY))*100 AS PERCENTAGE_OF_RETURN
FROM TRANSACTIONS A
INNER JOIN prod_cat_info AS B ON A.prod_cat_code = B.prod_cat_code AND A.prod_subcat_code= B.prod_sub_cat_code
GROUP BY PROD_SUBCAT
ORDER BY SUM(TOTAL_AMT) DESC



--ANS 11:
SELECT AGE , REVENUE
FROM (
        SELECT  DOB , DATEDIFF(YEAR,DOB,GETDATE()) AS AGE , MAX(tran_date) AS LAST_TRAN_DATE,
        ROUND(SUM(total_amt),2) AS REVENUE
        FROM Customer AS A 
        LEFT JOIN Transactions AS B
        ON A.customer_Id = B.cust_id
        WHERE DATEDIFF(YEAR,DOB,GETDATE()) BETWEEN 25 AND 35
                AND
                tran_date >= DATEADD(DAY,-30,(SELECT MAX(tran_date)FROM Transactions))
                AND
                total_amt>0
        GROUP BY DOB , DATEDIFF(YEAR,DOB,GETDATE()) 
) AS X 
ORDER BY REVENUE DESC



--ANS 12:
SELECT TOP 1 *
FROM (
      SELECT P.PROD_CAT, MAX(TOTAL_AMT) AS TOTAL_RETURN
      FROM prod_cat_info AS P
      INNER JOIN Transactions AS T ON P.prod_cat_code=T.prod_cat_code
	  AND P.prod_sub_cat_code=T.prod_subcat_code
      WHERE total_amt < 0 
	  AND 
      tran_date >= DATEADD(MONTH, -3,(SELECT MAX(TRAN_DATE)FROM TRANSACTIONS))
      GROUP BY P.prod_cat
  )AS X
  ORDER BY TOTAL_RETURN ASC



--ANS 13:
SELECT STORE_TYPE, SUM(TOTAL_AMT) AS TOTAL_SALES, SUM(Qty) AS QTY_SOLD
FROM Transactions
GROUP BY Store_type
HAVING SUM(TOTAL_AMT) >=ALL (SELECT SUM(TOTAL_AMT) FROM Transactions GROUP BY STORE_TYPE)
AND SUM(Qty) >=ALL(SELECT SUM(Qty) FROM Transactions GROUP BY STORE_TYPE)


--ANS 14:
SELECT PROD_CAT, AVG(TOTAL_AMT) AS AVERAGE
FROM Transactions AS A
INNER JOIN prod_cat_info AS B ON A.prod_cat_code=B.prod_cat_code AND A.prod_subcat_code=B.prod_sub_cat_code
GROUP BY PROD_CAT
HAVING AVG(TOTAL_AMT)> (SELECT AVG(TOTAL_AMT) FROM TRANSACTIONS)



--ANS 15:

SELECT prod_subcat , AVG_REVENUE , TOTAL_REVENUE 
FROM(
        SELECT TOP 5  prod_cat ,prod_subcat ,SUM(QTY) AS QTY_SOLD , ROUND(AVG(total_amt),2) AS AVG_REVENUE ,
        ROUND( SUM(total_amt) ,2 )AS TOTAL_REVENUE
        FROM prod_cat_info AS P 
        INNER JOIN Transactions AS T 
        ON P.prod_cat_code = T.prod_cat_code 
            AND 
        P.prod_sub_cat_code =T.prod_subcat_code 
        WHERE Qty > 0 AND total_amt > 0
        GROUP BY P.prod_cat , P.prod_subcat
        ORDER BY QTY_SOLD DESC
) AS X
ORDER BY  AVG_REVENUE DESC , TOTAL_REVENUE DESC