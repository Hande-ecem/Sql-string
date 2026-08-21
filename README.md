#  Çok Kanallı Dijital Pazarlama Veri Analizi (SQL)

## Proje Hakkında
Bu proje, **Facebook Ads** ve **Google Ads** platformlarından alınan günlük reklam performans verilerinin SQL kullanılarak temizlenmesi, birleştirilmesi ve analize hazır hale getirilmesini kapsamaktadır. 

Çalışmanın temel amacı; ham URL metinlerinden kampanya parametrelerini ayıklamak ve hata almadan temel pazarlama metriklerini (CTR, CPC, CPM, ROMI) hesaplamaktır.

---

##  Ne Öğrendim? (Teknik Kazanımlar)

* **Veri Birleştirme (`UNION ALL`):** Farklı kaynaklardan gelen günlük reklam tablolarını tek bir yapıda birleştirdim. Kaynak takibi için `media_source` sütununu ekledim.
* **Eksik Veri Yönetimi (`COALESCE`):** `NULL` değerleri analizlerde hataya yol açmaması için sayısal metriklerde `0`, metin alanlarında `'0'` ile değiştirdim.
* **Regex ile Metin Ayıklama (`SUBSTRING` / `LOWER`):** Karmaşık URL yapıları içinden `utm_campaign` parametresini düzenli ifadelerle çekip küçük harfe dönüştürdüm. `'nan'` string değerlerini mantıksal `NULL` haline getirdim.
* **Sıfıra Bölme Koruması (`CASE WHEN`):** Pazarlama KPI'larını (CTR, CPC, CPM, ROMI) hesaplarken paydanın 0 olduğu durumlarda çalışmanın durmasını engellemek için `CASE WHEN` mantığını uyguladım.

---

##  Hesaplanan Pazarlama Metrikleri

| Metrik | Açıklama | Formül |
| :--- | :--- | :--- |
| **CTR** | Tıklama Oranı (%) | `(Clicks / Impressions) * 100` |
| **CPC** | Tıklama Başına Maliyet | `Spend / Clicks` |
| **CPM** | Bin Gösterim Başına Maliyet | `(Spend / Impressions) * 1000` |
| **ROMI** | Pazarlama Yatırımı Getirisi (%) | `((Value - Spend) / Spend) * 100` |

---

##  SQL Sorgusu

<details>
<summary><b> SQL Kodunu İncelemek İçin Tıklayın</b></summary>

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
        
        -- utm_campaign ayıklama ve temizleme
        CASE 
            WHEN LOWER(SUBSTRING(url_parameters FROM 'utm_campaign=([^&]*)')) = 'nan' THEN NULL 
            ELSE LOWER(SUBSTRING(url_parameters FROM 'utm_campaign=([^&]*)'))
        END AS utm_campaign,
        
        spend,
        impressions,
        clicks,
        value,
        
        -- KPI Hesaplamaları
        CASE WHEN impressions = 0 THEN 0 ELSE (clicks::NUMERIC / impressions) * 100 END AS ctr,
        CASE WHEN clicks = 0 THEN 0 ELSE spend::NUMERIC / clicks END AS cpc,
        CASE WHEN impressions = 0 THEN 0 ELSE (spend::NUMERIC / impressions) * 1000 END AS cpm,
        CASE WHEN spend = 0 THEN 0 ELSE ((value - spend)::NUMERIC / spend) * 100 END AS romi

    FROM mix_ad
)

SELECT * 
FROM calculated_metrics;
