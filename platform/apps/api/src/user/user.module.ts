import { Module } from '@nestjs/common';
import { UserAppController } from './user-app.controller';
import { UserService } from './user.service';

@Module({
  controllers: [UserAppController],
  providers: [UserService],
})
export class UserModule {}
