// src/auth/strategies/jwt.strategy.ts
import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from '../../users/entities/user.entity';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy, 'jwt') {
  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
  ) {
    const jwtSecret = process.env.JWT_SECRET || 'your-secret-key';
    console.log('🔐 JwtStrategy: Initializing with secret:', jwtSecret.substring(0, 10) + '...');
    
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: jwtSecret,
    });
  }

  async validate(payload: any): Promise<any> {
    console.log('🔍 JwtStrategy: Starting token validation');
    console.log('🔍 JwtStrategy: Payload received:', JSON.stringify(payload, null, 2));

    if (!payload || !payload.sub) {
      console.log('❌ JwtStrategy: Invalid payload - missing sub');
      throw new UnauthorizedException('Invalid token payload');
    }

    try {
      console.log('🔍 JwtStrategy: Looking up user with ID:', payload.sub);
      
      const user = await this.userRepository.findOne({
        where: { id: payload.sub },
      });

      if (!user) {
        console.log('❌ JwtStrategy: User not found for ID:', payload.sub);
        
        // Let's also try to list all users to debug
        const allUsers = await this.userRepository.find();
        console.log('🔍 JwtStrategy: All users in database:', 
          allUsers.map(u => ({ id: u.id, username: u.username }))
        );
        
        throw new UnauthorizedException('User not found');
      }

      console.log('✅ JwtStrategy: User found:', {
        id: user.id,
        username: user.username,
        email: user.email,
        role: user.role,
        isActive: user.isactive
      });

      if (!user.isactive) {
        console.log('❌ JwtStrategy: User account is inactive');
        throw new UnauthorizedException('Account is inactive');
      }

      // Create the user object that will be attached to req.user
      const validatedUser = {
        id: user.id,
        username: user.username,
        email: user.email,
        role: user.role,
        isActive: user.isactive,
        createdAt: user.createdat,
        updatedAt: user.updatedat,
      };

      console.log('✅ JwtStrategy: Validation successful for user:', user.username);
      return validatedUser;

    } catch (error) {
      console.error('❌ JwtStrategy: Validation error:', error.message);
      if (error instanceof UnauthorizedException) {
        throw error;
      }
      throw new UnauthorizedException('Token validation failed');
    }
  }
}