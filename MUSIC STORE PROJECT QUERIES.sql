
--Q1: Who is the senior most employee based on job title?
SELECT TOP 1 *
FROM employee
ORDER BY levels DESC


--Q2: Which countries have the most Invoices?
SELECT COUNT(*) as invoice_count, billing_country
FROM invoice
GROUP BY billing_country
ORDER BY invoice_count desc


--Q3: What are top 3 values of total invoice?
SELECT TOP 3 total
FROM invoice
ORDER BY total DESC


--Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
--Write a query that returns one city that has the highest sum of invoice totals. 
--Return both the city name & sum of all invoice totals

SELECT TOP 3 SUM(total) AS total_sales, billing_city
FROM invoice
GROUP BY billing_city
ORDER BY total_sales desc


--Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
--Write a query that returns the person who has spent the most money.

SELECT TOP 1 c.first_name, c.last_name, SUM(I.total) AS total_sales
FROM customer C
JOIN invoice I ON C.customer_id = I.invoice_id
GROUP BY c.first_name, c.last_name
ORDER BY total_sales desc

-- Q6: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
--Return your list ordered alphabetically by email starting with A.

SELECT C.email, C.first_name, C.last_name
FROM customer C
INNER JOIN invoice I ON I.customer_id = C.customer_id
INNER JOIN invoice_line IL ON IL.invoice_id = I.invoice_id
WHERE track_id IN 
(SELECT track_id
	FROM track$ T
	INNER JOIN genre G ON G.genre_id = T.genre_id
	WHERE G.name LIKE 'Rock')
ORDER BY C.email


-- Q7: Let's invite the artists who have written the most rock music in our dataset. 
--Write a query that returns the Artist name and total track count of the top 10 rock bands.
	
SELECT TOP 10 COUNT(A.artist_id) AS numberofsongs, A.name
FROM artist A
INNER JOIN album AL ON AL.artist_id = A.artist_id
INNER JOIN track$ T ON T.album_id = AL.album_id
INNER JOIN genre G ON G.genre_id = T.genre_id
WHERE g.name like 'Rock'
GROUP BY A.name
ORDER BY numberofsongs DESC


--Q8: Return all the track names that have a song length longer than the average song length. 
--Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first.

SELECT name, milliseconds
FROM track$
where milliseconds > (select avg(milliseconds) from track$)
order by milliseconds desc



--Q9: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */

----/* Steps to Solve: First, find which artist has earned the most according to the InvoiceLines. Now use this artist to find 
----which customer spent the most on this artist. For this query, you will need to use the Invoice, InvoiceLine, Track, Customer, 
----Album, and Artist tables. Note, this one is tricky because the Total spent in the Invoice table might not be on a single product, 
----so you need to use the InvoiceLine table to find out how many of each product was purchased, and then multiply this by the price
----for each artist.


WITH best_selling_artist 
as (
SELECT TOP 1 A.name as artist_name, A.artist_id as artist_id, SUM(IL.unit_price * IL.quantity) AS total_sales
FROM invoice_line IL
INNER JOIN track$ T ON T.track_id =  IL.track_id
INNER JOIN album AL ON AL.album_id = T.album_id
INNER JOIN artist A ON A.artist_id = AL.artist_id
GROUP BY A.name, a.artist_id
ORDER BY total_sales DESC)


SELECT C.customer_id, C.first_name, C.last_name, BSA.artist_name, SUM (IL.quantity*IL.unit_price) AS TOTAL_SPENT
FROM invoice I
INNER JOIN customer C ON C.customer_id = I.customer_id
INNER JOIN invoice_line IL ON IL.invoice_id = I.invoice_id
INNER JOIN track$ T ON T.track_id = IL.track_id
INNER JOIN album AL ON AL.album_id = T.album_id
INNER JOIN best_selling_artist BSA ON BSA.artist_id = AL.artist_id
GROUP BY C.customer_id, C.first_name, C.last_name, BSA.artist_name
ORDER BY TOTAL_SPENT DESC;




-- Q10: Write a query that determines the customer that has spent the most on music for each country. 
--Write a query that returns the country along with the top customer and how much they spent. 
--For countries where the top amount spent is shared, provide all customers who spent this amount. */

--/* Steps to Solve:  Similar to the above question. There are two parts in question- 
--first find the most spent on music for each country and second filter the data for respective customers.




CREATE VIEW customer_by_country
as
SELECT C.first_name, C.last_name, i.billing_country, sum(I.total) AS total_spending
FROM customer C
INNER JOIN invoice I ON I.customer_id = C.customer_id
GROUP BY C.first_name, C.last_name, i.billing_country
	

select CC.billing_country, CC.total_spending, CC.first_name, CC.last_name 
from [dbo].[customer_by_country] CC
INNER JOIN (select billing_country as billing_country, max(total_spending) as max_spending
from [dbo].[customer_by_country]
group by billing_country) S1 ON S1.billing_country = CC.billing_country
WHERE S1.max_spending = CC.total_spending
ORDER BY CC.billing_country
