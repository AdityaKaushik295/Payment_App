// src/auth/guards/jwt-auth.guard.ts
import {
  Injectable,
  ExecutionContext,
  UnauthorizedException,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {
  canActivate(context: ExecutionContext) {
    console.log('JwtAuthGuard: Checking JWT authentication...');
    
    const request = context.switchToHttp().getRequest();
    const authHeader = request.headers.authorization;
    
    console.log('JwtAuthGuard: Authorization header:', authHeader ? 'Present' : 'Missing');
    
    if (authHeader) {
      console.log('JwtAuthGuard: Auth header value:', authHeader);
    }

    return super.canActivate(context);
  }

  handleRequest(err, user, info) {
    console.log('JwtAuthGuard: handleRequest called');
    console.log('JwtAuthGuard: Error:', err);
    console.log('JwtAuthGuard: User:', user ? `${user.username} (${user.id})` : 'None');
    console.log('JwtAuthGuard: Info:', info);

    if (err || !user) {
      console.log('JwtAuthGuard: Authentication failed');
      if (err) console.error('JwtAuthGuard: Authentication error:', err);
      if (info) console.log('JwtAuthGuard: Authentication info:', info);
      
      throw err || new UnauthorizedException('Invalid token');
    }

    console.log('JwtAuthGuard: Authentication successful for user:', user.username);
    return user;
  }
}