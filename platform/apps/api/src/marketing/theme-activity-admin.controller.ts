import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Post,
  Put,
  UseGuards,
} from '@nestjs/common';
import { AdminAuthGuard } from '../iam/admin-auth.guard';
import { ThemeActivityService } from './theme-activity.service';

@Controller('admin/v1/marketing/theme-activities')
@UseGuards(AdminAuthGuard)
export class ThemeActivityAdminController {
  constructor(private readonly theme: ThemeActivityService) {}

  @Get()
  list() {
    return this.theme.listAdmin();
  }

  @Post('validate')
  validate(@Body() body: { config?: unknown } | Record<string, unknown>) {
    const config =
      body && typeof body === 'object' && 'config' in body && body.config != null
        ? body.config
        : body;
    return this.theme.validate(config);
  }

  @Post('preview')
  preview(
    @Body()
    body: {
      activityId?: string;
      title?: string;
      status?: string;
      startAt?: string | null;
      endAt?: string | null;
      expiredBehavior?: string;
      config?: Record<string, unknown>;
    },
  ) {
    return this.theme.previewAdmin(body);
  }

  @Post()
  create(
    @Body()
    body: {
      activityId?: string;
      title?: string;
      status?: string;
      startAt?: string | null;
      endAt?: string | null;
      expiredBehavior?: string;
      config?: Record<string, unknown>;
    },
  ) {
    return this.theme.createAdmin(body);
  }

  @Get(':activityId')
  get(@Param('activityId') activityId: string) {
    return this.theme.getAdmin(activityId);
  }

  @Put(':activityId')
  update(
    @Param('activityId') activityId: string,
    @Body()
    body: {
      title?: string;
      status?: string;
      startAt?: string | null;
      endAt?: string | null;
      expiredBehavior?: string;
      config?: Record<string, unknown>;
    },
  ) {
    return this.theme.updateAdmin(activityId, body);
  }

  @Delete(':activityId')
  remove(@Param('activityId') activityId: string) {
    return this.theme.deleteAdmin(activityId);
  }
}
