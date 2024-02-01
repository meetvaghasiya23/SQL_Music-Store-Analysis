-- Question 1: Who is the senior most employee based on the job title?

SELECT title, first_name, last_name, levels
FROM Employee 
ORDER BY levels DESC
limit 1


-- Question 2: Which countries have the most invoices?

SELECT COUNT(*) AS invoice_count, billing_country
FROM invoice
GROUP BY billing_country
ORDER BY invoice_count DESC


-- Question 3: What are the top 3 values of total invoices? 

SELECT total 
FROM invoice
ORDER BY total DESC
LIMIT 3


/* Question 4: Which city has the best customers? We would like to throw a promotional music festival in the city 
where we made the most money. Write a query that returns one city that has the highest sum of invoice totals */

SELECT billing_city, SUM(total) AS invoice_totals
FROM invoice
GROUP BY billing_city
ORDER BY invoice_totals DESC
LIMIT 1


/* Question 5: Who is the best customer? The customer who has spent the most money will be declared as the best customer.
write a query that returns the person who spent the most money. */

SELECT c.customer_id, c.first_name, c.last_name, SUM(i.total) AS total
FROM customer c JOIN invoice i 
ON c.customer_id = i.customer_id
GROUP BY c.customer_id
ORDER BY total DESC
LIMIT 1


/* Question 6: Write a query to return the email, first name, last name, & genre of all Rock music listeners. 
Return your list ordered alphabetically by email starting with A */

SELECT DISTINCT email, first_name, last_name
FROM customer 
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN (
	SELECT track_id
	FROM track JOIN genre ON track.genre_id = genre.genre_id
	WHERE genre.name LIKE 'Rock')
	
ORDER BY email


/*  Question 7: Let's invite the artists who have written the most rock music in our dataset. Write a query that returns 
the Artist name and total track count of the top 10 rock bands. */

SELECT artist.artist_id, artist.name,COUNT(artist.artist_id) AS number_of_songs
FROM album 
JOIN track
ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY number_of_songs DESC
LIMIT 10 


/* Question 8: Return all the track names that have a song length longer than average song length.
Return the name and milliseconds for each track. Order by song length with the longest songs listed first. */

SELECT name, milliseconds AS song_length
FROM track
WHERE milliseconds > (
	SELECT  AVG(milliseconds) AS avg_song_length
	FROM track)
ORDER BY milliseconds DESC


/* Question 9: Find how much amount spent by each customer on artists? Write a query to return the customer name, 
artist name, and total spent   */

WITH artistTracks AS (
SELECT track_id, art.name
FROM track t JOIN album a
ON a.album_id = t.album_id
JOIN artist art
ON art.artist_id = a.artist_id 	
),

artistTotal AS (
SELECT art.name, SUM(invl.unit_price * invl.quantity) AS total, customer_id
FROM invoice inv
JOIN invoice_line invl ON invl.invoice_id = inv.invoice_id
JOIN artistTracks art ON art.track_id = invl.track_id
GROUP BY art.name, customer_id
)

SELECT first_name, last_name, art.name AS artist_name, art.total AS amount_spent
FROM customer c JOIN artistTotal art ON art.customer_id = c.customer_id
ORDER BY amount_spent DESC;


/* Question 10: We want to find out the most popular music Genre for each country. We determine the most 
popular genre as the genre with the highest amount of purchases. Write a query that returns each country
along with the top Genre. For countries where the maximum number of purchases is shared return all Genres. */

WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1


/* Question 11: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

WITH Customer_with_country AS (
		SELECT c.customer_id,c.first_name,c.last_name,inv.billing_country,SUM(inv.total) AS total_spending,
	    RANK() OVER(PARTITION BY inv.billing_country ORDER BY SUM(inv.total) DESC) AS Rank 
		FROM customer c
		JOIN invoice inv ON inv.customer_id = c.customer_id
		GROUP BY 1,4
		ORDER BY inv.billing_country)
SELECT * FROM Customer_with_country WHERE Rank<=1 ORDER BY billing_country