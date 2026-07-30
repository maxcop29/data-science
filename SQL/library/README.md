# Library Management System — SQL

A relational schema and query set for a library management system: members, branches, employees, books, and book issue/return tracking.

## Files

| File | Purpose |
|---|---|
| `schema.sql` | Table definitions and foreign key constraints |
| `inserts.sql` | Sample data (run after `schema.sql`) |
| `queries.sql` | 12 business-task queries: CRUD operations, joins, aggregation, and CTAS summary tables |

## How to run

```bash
psql -U your_user -d your_db -f schema.sql
psql -U your_user -d your_db -f inserts.sql
psql -U your_user -d your_db -f queries.sql
```

## Schema notes

- `branch.manager_id` and `employees.branch_id` reference each other, so `branch`'s manager FK is added as `DEFERRABLE INITIALLY DEFERRED` — it's only checked at transaction commit, letting the two tables' data be inserted in either order.
- `inserts.sql` wraps all inserts in a single transaction for this reason.

## What the queries cover

- Insert / update / delete records
- Filtering and aggregation (`GROUP BY`, `HAVING`)
- Multi-table joins, including a self-join (employees to their branch manager)
- `CTAS` (Create Table As Select) to materialize summary tables
- Anti-join pattern (`LEFT JOIN ... WHERE ... IS NULL`) to find unreturned books
