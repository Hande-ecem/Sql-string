## 📜 SQL Code

```sql
WITH mix_ad AS (
    SELECT 
        'facebook_ads' AS media_source, 
        f.ad_date,
        COALESCE(f.url_parameters, '0') AS url_parameters,
        COALESCE(f.spend, 0) AS spend,
        COALESCE(f.impressions, 0) AS impressions,
        COALESCE(f.reach, 0) AS reach, 
        COALESCE(f.clicks, 0) AS clicks,
        COALESCE(f.leads, 0) AS leads, 
        COALESCE(f.value, 0) AS value 
    FROM facebook_ads_basic_daily f 

    UNION ALL 

    SELECT  
        'google_ads' AS media_source,
        g.ad_date,
        COALESCE(g.url_parameters, '0') AS url_parameters,
        COALESCE(g.spend, 0) AS spend,
        COALESCE(g.impressions, 0) AS impressions,
        COALESCE(g.reach, 0) AS reach, 
        COALESCE(g.clicks, 0) AS clicks,
        COALESCE(g.leads, 0) AS leads, 
        COALESCE(g.value, 0) AS value 
    FROM google_ads_basic_daily g
),

calculated_metrics AS (
    SELECT
        media_source,
        ad_date,
        
        -- utm_campaign ayıklama, küçük harfe çevirme ve 'nan' ise NULL yapma
        CASE 
            WHEN LOWER(SUBSTRING(url_parameters FROM 'utm_campaign=([^&]*)')) = 'nan' THEN NULL 
            ELSE LOWER(SUBSTRING(url_parameters FROM 'utm_campaign=([^&]*)'))
        END AS utm_campaign,
        
        -- Temel Metrikler
        spend,
        impressions,
        clicks,
        value,
        
        -- Sıfıra bölme korumalı KPI hesaplamaları
        CASE 
            WHEN impressions = 0 THEN 0 
            ELSE (clicks::NUMERIC / impressions) * 100 
        END AS ctr,
        
        CASE 
            WHEN clicks = 0 THEN 0 
            ELSE spend::NUMERIC / clicks 
        END AS cpc,
        
        CASE 
            WHEN impressions = 0 THEN 0 
            ELSE (spend::NUMERIC / impressions) * 1000 
        END AS cpm,
        
        CASE 
            WHEN spend = 0 THEN 0 
            ELSE ((value - spend)::NUMERIC / spend) * 100 
        END AS romi

    FROM mix_ad
)

SELECT * 
FROM calculated_metrics;
```
