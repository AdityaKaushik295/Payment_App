
import * as dotenv from 'dotenv';
const result = dotenv.config();
if (result.error) {
  console.log('❌ Error loading .env file:', result.error);
} else {
  console.log('✅ .env file loaded successfully');
}
// src/debug-env.ts - Run this to check your environment
console.log('🔍 Environment Debug Information:');
console.log('NODE_ENV:', process.env.NODE_ENV);
console.log('DB_HOST:', process.env.DB_HOST);
console.log('DB_PORT:', process.env.DB_PORT);
console.log('DB_USERNAME:', process.env.DB_USERNAME);
console.log('DB_NAME:', process.env.DB_NAME);
console.log('JWT_SECRET:', process.env.JWT_SECRET ? `${process.env.JWT_SECRET.substring(0, 10)}...` : 'NOT SET');
console.log('PORT:', process.env.PORT);
