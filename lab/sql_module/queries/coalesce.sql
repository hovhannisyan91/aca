-- STEP 1: updating dicount seting null in case of zero
UPDATE public.sales_analysis
SET discount = NULL
WHERE discount = 0;

-- STEP 2: checking
SELECT
	*, 
	CASE WHEN discount IS NULL THEN avg_number ELSE discount  END discount_imputed
	COALESCE(discount,avg_number)
FROM public.sales_analysis
WHERE discount IS NULL;

-- STEP 3: Summary Statistics

SELECT 
	ROUND(MIN(discount),2) as min_discount,
	ROUND(MAX(discount),2) as max_discount,
	ROUND(avg(discount),2) as avg_discount,
	COUNT(transaction_id) as transactions
FROM sales_analysis;

SELECT 
	ROUND(avg(discount),2) as avg_discount,
	AVG(COALESCE(discount,(SELECT avg(discount) FROM sales_analysis) )) as test1,
	AVG(COALESCE(discount,0.5)) as test2,
	AVG(COALESCE(discount,0.25)) as test3,

	
	
FROM sales_analysis;








