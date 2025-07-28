// src/auth/auth.controller.ts
import { Controller, Post, Body, UseGuards, Get, Request } from '@nestjs/common';
import { AuthService } from './auth.service';
import { LoginDto } from './dto/login.dto';
import { JwtAuthGuard } from './guards/jwt-auth.guard';

@Controller('auth')
export class AuthController {
  constructor(private authService: AuthService) {}

  @Post('login')
  async login(@Body() loginDto: LoginDto) {
    console.log('🔐 AuthController: Login request for:', loginDto.username);
    const result = await this.authService.login(loginDto);
    console.log('✅ AuthController: Login successful, token generated');
    return result;
  }

  @UseGuards(JwtAuthGuard)
  @Get('profile')
  getProfile(@Request() req) {
    console.log('👤 AuthController: Profile request from user:', req.user?.username);
    return req.user;
  }

  // Test endpoint to verify JWT is working
  @UseGuards(JwtAuthGuard)
  @Get('test')
  testAuth(@Request() req) {
    console.log('🧪 AuthController: Test auth endpoint accessed by:', req.user?.username);
    return { 
      message: 'Authentication successful', 
      user: req.user,
      timestamp: new Date().toISOString()
    };
  }
}