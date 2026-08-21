with mix_ad as(
select 'facebook_ads' as media_source, f.ad_date,
coalesce(f.url_parameters,'0') as url_parameters,
coalesce(f.spend, 0) as spend ,
coalesce(f.impressions ,0)as impressions,
coalesce(f.reach,0) as  reach, coalesce(f.clicks,0) as clicks,
coalesce( f. leads, 0) as leads , 
coalesce (f.value, 0) as value 
from facebook_ads_basic_daily f 

union all 
select  'google_ads' as media_source,g.ad_date,
coalesce(g.url_parameters,'0') as url_parameters,
coalesce(g.spend, 0) as spend ,
coalesce(g.impressions , 0 )as impressions,
coalesce(g.reach,0) as  reach, coalesce(g.clicks,0) as clicks,
coalesce(g. leads, 0) as leads , 
coalesce (g.value, 0) as value 
from google_ads_basic_daily g ),

calculated_metrics AS (
    SELECT
        media_source,
        ad_date,
        
        CASE 
            WHEN LOWER(SUBSTRING(url_parameters FROM 'utm_campaign=([^&]*)')) = 'nan' THEN NULL 
            ELSE LOWER(SUBSTRING(url_parameters FROM 'utm_campaign=([^&]*)'))
        END AS utm_campaign,
        
        spend,
        impressions,
        clicks,
        value,
        
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
) SELECT * 
FROM calculated_metrics;
