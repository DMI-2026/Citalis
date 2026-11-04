import { Module } from '@nestjs/common';
import { HealthController } from './health.controller';
import { TestController } from './test.controller';

@Module({ controllers: [HealthController, TestController] })
export class HealthModule {}
