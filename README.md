# Root Cause Analysis of a Global Retail Business
### Why did profit lag behind 18–27% YoY revenue growth?
An end-to-end diagnostic analysis of a global retail dataset (51,290 orders, 4 years, 13 regions) 
built to answer one question from leadership: *"We're growing — so why isn't profit keeping pace?"*

**Tools:** Python (Pandas) · PostgreSQL · Power BI (DAX, Power Query)

---
## The Problem
Leadership suspected underperforming regions, loss-making products, and excessive discounting — 
but had no clear diagnosis of which factor mattered most, or where.
## The Approach
1. Cleaned and loaded 51,290 rows into PostgreSQL
2. Answered 7 structured stakeholder questions through layered SQL analysis (~50 queries)
3. Built a 3-page Power BI dashboard to visualize findings for a non-technical audience

## Key Findings

- **Revenue grew 18–27% YoY**, but margin stayed flat at 11–12% — growth wasn't converting to profit.
- **Southeast Asia (2% margin)** — driven by excessive discounting, some products discounted up to 57%.
- **EMEA (5.45% margin)** — a different root cause: Same Day and First Class shipping modes 
  turned 606 orders into losses, while Standard Class stayed profitable.
- **Discounts above 30%** turn margin negative (-51%) with **zero increase in order volume** — 
  proof that aggressive discounting isn't buying growth, only destroying profit.
- **Tables (Furniture)** alone accounts for a **$64K net loss** — fully explained by high discount + shipping cost.
- **181 products (18%) lose money company-wide**, totaling **$234K** — some causes identified, 
  some flagged honestly as needing cost-price data not available in this dataset.

## Recommendations

- Cap discounts at 20% company-wide
- Mandate Standard Class shipping in EMEA
- Emergency review of Furniture/Tables SKUs in Southeast Asia
- Study Canada's model (26.6% margin, highest in business) for replication

## Dashboard Preview

<img width="1327" height="746" alt="{B90C2C10-D365-4AC4-96D5-20B081D6D656}" src="https://github.com/user-attachments/assets/92e73782-f0f0-4c8a-af43-990b83103fce" />

<img width="1319" height="739" alt="{BE117C3D-0019-452D-AD9A-8BB233479A87}" src="https://github.com/user-attachments/assets/a248db19-e0cb-470f-a3d5-da5ef8ab73fd" />

<img width="1323" height="742" alt="{F14F3358-08BE-4551-AA32-C2880866C0D6}" src="https://github.com/user-attachments/assets/a4b98ad1-af76-46bb-ae84-08f47fb21053" />


