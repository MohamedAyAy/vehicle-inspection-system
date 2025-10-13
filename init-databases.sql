CREATE DATABASE auth_db;
CREATE DATABASE appointments_db;
CREATE DATABASE payments_db;
CREATE DATABASE inspections_db;
CREATE DATABASE logs_db;

\connect auth_db;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\connect appointments_db;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\connect payments_db;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\connect inspections_db;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\connect logs_db;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";