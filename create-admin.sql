-- Create default admin account
-- Run this after services have started and created tables
-- Email: admin@test.com
-- Password: Test1234

\connect auth_db;

INSERT INTO accounts (
    id, 
    email, 
    password_hash, 
    role, 
    is_verified,
    first_name, 
    last_name, 
    birthdate, 
    country, 
    session_timeout_minutes,
    created_at,
    updated_at
) VALUES (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid,
    'admin@test.com',
    '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYIl.YNlvuW',
    'admin',
    true,
    'System',
    'Administrator',
    '1980-01-01',
    'System',
    '60',
    NOW(),
    NOW()
) ON CONFLICT (email) DO NOTHING;

SELECT 'Admin account created successfully!' as status;
SELECT email, role, first_name, last_name FROM accounts WHERE email = 'admin@test.com';
