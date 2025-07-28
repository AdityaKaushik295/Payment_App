// src/auth/auth.controller.ts
import { Controller, Post, Body, UseGuards, Get, Request, Res } from '@nestjs/common';
import { AuthService } from './auth.service';
import { LoginDto } from './dto/login.dto';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { Response } from 'express';  // 👈

@Controller('auth')
export class AuthController {
  constructor(private authService: AuthService) {}

  @Post('login')
  async login(@Body() loginDto: LoginDto, @Res() res: Response) {
    console.log('🔐 AuthController: Login request for:', loginDto.username);
    const result = await this.authService.login(loginDto);
    console.log('✅ AuthController: Login successful, token generated');
    return res.status(200).json(result);  // 👈 force JSON return
  }

  @UseGuards(JwtAuthGuard)
  @Get('profile')
  getProfile(@Request() req) {
    console.log('👤 AuthController: Profile request from user:', req.user?.username);
    return req.user;
  }

  @UseGuards(JwtAuthGuard)
  @Get('test')
  testAuth(@Request() req) {
    return {
      message: 'Authentication successful',
      user: req.user,
      timestamp: new Date().toISOString()
    };
  }
}
