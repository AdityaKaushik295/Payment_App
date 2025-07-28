// src/auth/strategies/local.strategy.ts
import { Strategy } from 'passport-local';
import { PassportStrategy } from '@nestjs/passport';
import { Injectable, UnauthorizedException } from '@nestjs/common';
import { AuthService } from '../auth.service';

@Injectable()
export class LocalStrategy extends PassportStrategy(Strategy) {
  constructor(private authService: AuthService) {
    super();
  }

  async validate(username: string, password: string): Promise<any> {
    console.log('Local Strategy - Validating user:', username);
    
    const user = await this.authService.validateUser(username, password);
    if (!user) {
      console.log('Local Strategy - Validation failed for user:', username);
      throw new UnauthorizedException();
    }
    
    console.log('Local Strategy - User validated successfully:', user.username);
    return user;
  }
}