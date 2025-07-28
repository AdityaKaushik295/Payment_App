-- Make sure you're already connected to payment_dashboard when running this file

-- Optional: Insert a test user
INSERT INTO users (id, username, email, password, role, "isactive", "createdat", "updatedat")
SELECT gen_random_uuid(), 'admin', 'admin@paymentdashboard.com', 'admin123', 'admin', true, NOW(), NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM users WHERE username = 'admin'
);


-- Optional: Insert a test payment
INSERT INTO payments (id, amount, method, status, receiver, description, transactionId, createdAt, updatedAt)
VALUES (
    gen_random_uuid(),
    499.99,
    'upi',
    'success',
    'Test Merchant',
    'Test payment for seeding',
    'TXN123456',
    NOW(),
    NOW()
);
