-- cek null table customer_detail
select 
	count(*) as total_rows,
    sum(case when id is null then 1 else 0 end) as id_nulls,
    sum(case when registered_date is null then 1 else 0 end) as registered_date_nulls
from customer_detail

-- cek duplicate table customer_detail
select 
	id, 
    registered_date, 
    count(*) 
from customer_detail
group by id, registered_date
having count(*) > 1

-- Selama transaksi yang terjadi selama 2021, pada bulan apa total nilai transaksi (after_discount) paling besar?
SELECT
	EXTRACT(MONTH FROM TO_DATE(order_date, 'YYYY-MM-DD')) AS transaction_Month,
	SUM(after_discount) AS total_Transaction
FROM order_detail
WHERE
	EXTRACT(YEAR FROM TO_DATE(order_date, 'YYYY-MM-DD')) = 2021
	AND is_valid = 1
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1

-- Selama transaksi pada tahun 2022, kategori apa yang menghasilkan nilai transaksi paling besar?
SELECT
	sd.category AS Category_Product,
	SUM(od.after_discount) AS Total_Transaction
FROM
	order_detail AS od
	LEFT JOIN sku_detail AS sd ON od.sku_id = sd.id
WHERE
	EXTRACT(YEAR FROM TO_DATE(order_date, 'YYYY-MM-DD')) = 2022
	AND is_valid = 1
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5

-- Membandingkan nilai transaksi masing2 tahun 2021 dan 2022, sebutkan kategori yang mengalami peningkatan dan penurunan nilai transaksi
with transaksi as (
  SELECT
  	sd.category,
  	sum(case when EXTRACT(YEAR FROM TO_DATE(order_date, 'YYYY-MM-DD')) = 2021 then after_discount else 0 end) as transaksi_2021,
  	sum(case when EXTRACT(YEAR FROM TO_DATE(order_date, 'YYYY-MM-DD')) = 2022 then after_discount else 0 end) as transaksi_2022
  from 
  	order_detail od
  join sku_detail sd on od.sku_id = sd.id
  where od.is_valid = 1
  group by 1
)
SELECT
	category,
    transaksi_2021,
    transaksi_2022,
    transaksi_2022 - transaksi_2021 as pertumbuhan,
    CASE
    	when transaksi_2022 > transaksi_2021 then 'Meningkat'
        else 'Menurun'
    end as keterangan
from transaksi
order by pertumbuhan desc

-- Tampilkan top 5 metode pembayaran yang paling populer digunakan selama 2022 (berdasarkan total unique order)
SELECT
	pd.payment_method as metode_pembayaran,
    count(DISTINCT od.id) as total_transaksi
from order_detail od
left join payment_detail pd on od.payment_id = pd.id
where 
	EXTRACT(YEAR FROM TO_DATE(order_date, 'YYYY-MM-DD')) = 2022
    and od.is_valid = 1
group by 1
order by 2 DESC
limit 5

-- Urutkan dari ke-5 produk ini berdasarkan nilai transaksinya (Samsung, Apple, Sony, Huawei, Lenovo)
with top_product as (
  SELECT
	case
    	when lower(sd.sku_name) like '%samsung%' then 'Samsung'
     	when lower(sd.sku_name) like '%sony%' then 'Sony'
        when lower(sd.sku_name) like '%huawei%' then 'Huawei'
        when lower(sd.sku_name) like '%lenovo%' then 'Lenovo'
        when lower(sd.sku_name) like '%apple%' then 'Apple'
        else 'Lainnya'
     end as nama_product,
     sum(od.after_discount) as total_transaksi
from order_detail od
join sku_detail sd on od.sku_id = sd.id
where od.is_valid = 1
group by nama_product
)
SELECT
	*
FROM top_product
WHERE nama_product <> 'Lainnya'
ORDER BY total_transaksi DESC;

