// src/auth/auth.service.ts
import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import * as bcrypt from 'bcryptjs';
import { User, UserRole } from '../users/entities/user.entity';
import { LoginDto } from './dto/login.dto';

@Injectable()
export class AuthService {
  constructor(
    @InjectRepository(User)
    private userRepository: Repository<User>,
    private jwtService: JwtService,
  ) {
    this.createDefaultAdmin();
  }

  async validateUser(username: string, password: string): Promise<any> {
    console.log('AuthService: Validating user:', username);
    
    try {
      const user = await this.userRepository.findOne({
        where: { username },
      });

      if (!user) {
        console.log('AuthService: User not found:', username);
        return null;
      }

      console.log('AuthService: User found, checking password...');
      const isPasswordValid = await bcrypt.compare(password, user.password);
      
      if (isPasswordValid) {
        console.log('AuthService: Password is valid for user:', username);
        const { password, ...result } = user;
        return result;
      } else {
        console.log('AuthService: Invalid password for user:', username);
        return null;
      }
    } catch (error) {
      console.error('AuthService: Error validating user:', error);
      return null;
    }
  }

  async login(loginDto: LoginDto) {
    console.log('AuthService: Login attempt for:', loginDto.username);
    
    const user = await this.validateUser(loginDto.username, loginDto.password);
    if (!user) {
      console.log('AuthService: Login failed - invalid credentials');
      throw new UnauthorizedException('Invalid credentials');
    }

    if (!user.isactive) {
      console.log('AuthService: Login failed - user inactive');
      throw new UnauthorizedException('Account is inactive');
    }

    const payload = { 
      username: user.username, 
      sub: user.id, 
      role: user.role 
    };

    const access_token = this.jwtService.sign(payload);
    console.log('AuthService: JWT token generated successfully');
    console.log('AuthService: Token payload:', payload);

    const response = {
      access_token,
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        role: user.role,
        isActive: user.isactive,
        createdAt: user.createdat,
        updatedAt: user.updatedat,
      },
    };

    console.log('AuthService: Login successful for user:', user.username);
    return response;
  }

  async createDefaultAdmin() {
    try {
      const adminExists = await this.userRepository.findOne({
        where: { username: 'admin' },
      });

      if (!adminExists) {
        console.log('AuthService: Creating default admin user...');
        const hashedPassword = await bcrypt.hash('admin123', 10);
        const admin = this.userRepository.create({
          username: 'admin',
          email: 'admin@paymentdashboard.com',
          password: hashedPassword,
          role: UserRole.ADMIN,
          isactive: true, // Make sure admin is active
        });
        
        await this.userRepository.save(admin);
        console.log('✅ Default admin user created: admin/admin123');
      } else {
        console.log('AuthService: Default admin user already exists');
      }
    } catch (error) {
      console.error('AuthService: Error creating default admin:', error);
    }
  }
}