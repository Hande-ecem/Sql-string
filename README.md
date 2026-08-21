#  Multi-Channel Ad Performance & Marketing Metrics Analysis (SQL)

##  Project Overview
This project consolidates, cleans, and analyzes daily performance data from **Facebook Ads** and **Google Ads** using Advanced SQL techniques. The goal is to unify multi-source marketing data, parse UTM parameters, and safely compute crucial KPI metrics without encountering runtime errors.

##  Key Technical Highlights
- **Data Integration:** Combined disparate sources (`facebook_ads_basic_daily` & `google_ads_basic_daily`) using `UNION ALL`.
- **Handling Missing Values:** Applied `COALESCE` to standardize null metrics to numerical `0` and text attributes to `'0'`.
- **Regex & Text Extraction:** Extracted `utm_campaign` from complex URL string parameters using `REGEXP_SUBSTR` / `SUBSTRING`.
- **Data Normalization:** Cleaned text string levels using `LOWER()` and handled non-standard `'nan'` strings with conditional logic/`NULLIF`.
- **Zero-Division Protection:** Calculated high-level marketing KPIs (**CTR, CPC, CPM, ROMI**) using `CASE WHEN` logic to prevent division-by-zero errors without relying on `WHERE` clauses.

##  Formulas & Metrics Calculated
| Metric | Formula | Zero-Division Handling |
| :--- | :--- | :--- |
| **CTR** | `(Clicks / Impressions) * 100` | Checked if `Impressions = 0` |
| **CPC** | `Spend / Clicks` | Checked if `Clicks = 0` |
| **CPM** | `(Spend / Impressions) * 1000` | Checked if `Impressions = 0` |
| **ROMI** | `((Value - Spend) / Spend) * 100` | Checked if `Spend = 0` |

## 🚀 How to Run
Run the provided `ad_performance_analysis.sql` script on any PostgreSQL or compatible relational database environment containing the daily ad performance tables.
