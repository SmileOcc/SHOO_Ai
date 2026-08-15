import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Put,
  Query,
  UseGuards,
} from '@nestjs/common';
import { AdminAuthGuard } from '../iam/admin-auth.guard';
import { CatalogService } from './catalog.service';

@Controller('admin/v1/catalog')
@UseGuards(AdminAuthGuard)
export class CatalogAdminController {
  constructor(private readonly catalog: CatalogService) {}

  @Get('banners')
  listBanners() {
    return this.catalog.adminListBanners();
  }

  @Post('banners')
  createBanner(
    @Body()
    body: {
      imageUrl: string;
      link: string;
      title: string;
      sort?: number;
      enabled?: boolean;
    },
  ) {
    return this.catalog.createBanner(body);
  }

  @Patch('banners/:id')
  updateBanner(
    @Param('id') id: string,
    @Body()
    body: Partial<{
      imageUrl: string;
      link: string;
      title: string;
      sort: number;
      enabled: boolean;
    }>,
  ) {
    return this.catalog.updateBanner(id, body);
  }

  @Delete('banners/:id')
  deleteBanner(@Param('id') id: string) {
    return this.catalog.deleteBanner(id);
  }

  @Get('categories')
  getCategories() {
    return this.catalog.adminGetCategories();
  }

  @Put('categories')
  saveCategories(@Body() body: { payload: unknown }) {
    return this.catalog.adminSaveCategories(body.payload);
  }

  @Get('products')
  listProducts(
    @Query('page') page?: string,
    @Query('pageSize') pageSize?: string,
    @Query('q') q?: string,
  ) {
    return this.catalog.adminListProducts({
      page: page ? Number(page) : undefined,
      pageSize: pageSize ? Number(pageSize) : undefined,
      q,
    });
  }

  @Post('products')
  createProduct(
    @Body()
    body: {
      id: string;
      categoryId?: string;
      title: string;
      imageUrl: string;
      price: number;
      originalPrice: number;
      discountLabel?: string;
      rating?: number;
      soldCount?: number;
      description?: string;
      images?: string[];
      reviewCount?: number;
      enabled?: boolean;
    },
  ) {
    return this.catalog.createProduct(body);
  }

  @Patch('products/:id')
  updateProduct(
    @Param('id') id: string,
    @Body()
    body: Partial<{
      categoryId: string;
      title: string;
      imageUrl: string;
      price: number;
      originalPrice: number;
      discountLabel: string;
      rating: number;
      soldCount: number;
      description: string;
      images: string[];
      reviewCount: number;
      enabled: boolean;
    }>,
  ) {
    return this.catalog.updateProduct(id, body);
  }

  @Delete('products/:id')
  deleteProduct(@Param('id') id: string) {
    return this.catalog.deleteProduct(id);
  }
}
