select tc.constraint_name, kcu.constraint_name, c.data_type
from information_schema.table_constraints tc
left join information_schema.key_column_usage kcu on kcu.constraint_name = tc.constraint_name
left join information_schema.columns c on c.column_name = kcu.column_name
where tc.constraint_type = 'PRIMARY KEY'