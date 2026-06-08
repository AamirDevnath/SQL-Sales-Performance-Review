# SQL-Sales-Performance-Review
Used the "Northwind Dataset" with a multiple-table schema to practice SQL queries (PostgreSQL)

Overview
This project simulates a sales performance review for the Northwind trading company. The goal was to answer a set of business questions around revenue, customer value, and freight costs using SQL on a relational database. The dataset is the classic Northwind database, which models a trading company's orders, customers, products, employees, and suppliers across multiple related tables.

Tools
PostgreSQL 15, DBeaver, Homebrew (macOS)
What I Analysed
I wrote seven SQL queries to answer the following questions: which product categories generated the most revenue, which countries placed the most orders, who the top 10 customers were by lifetime spend, whether those customers were growing or declining year-on-year, which products had falling sales, which shipping routes had the highest freight costs, and which employee handled the highest-value orders.

What I Practised
The project covered core SQL skills including aggregation, multi-table joins, and filtering. For the more advanced questions I used Common Table Expressions (CTEs) to break complex logic into readable steps, and window functions — specifically the LAG() function — to compare each customer's revenue against the prior year and calculate year-on-year change.

