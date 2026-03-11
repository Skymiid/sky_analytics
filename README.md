Resilient SCD Type 2 Architecture: ADP API Ingestion
🎯 The Challenge
Source APIs (like ADP) are often volatile, utilizing "hard deletes" and "in-place updates." A standard sync leads to Data Amnesia, destroying historical audit trails and breaking "as-of" financial reporting.

🏗️ Engineering Solution
I implemented a temporal state-management layer using dbt snapshots on Databricks to ensure 100% data retention.
Logic: Managed record lifecycles via dbt_valid_from and dbt_valid_to timestamps.
Hard-Delete Handling: Enabled invalidate_hard_deletes to logically retire missing source records rather than physically deleting them.
Change Detection: Used a check strategy on high-entropy fields (e.g., lastName) to version records only when meaningful business changes occur.

📈 Business Impact
Audit Compliance: Maintains a permanent record of all former employees for SOX/GDPR.
Reporting Accuracy: Enables point-in-time joins for historical headcount and salary analytics.
System Stability: Decouples downstream BI from upstream API volatility.
Tech Stack: dbt Core | Databricks | SQL | 
