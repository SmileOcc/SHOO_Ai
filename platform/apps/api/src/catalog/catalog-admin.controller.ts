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
import { JsonObjectPipe } from '../common/json-object.pipe';
import { unwrapPayload } from '../common/unwrap-payload';
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
  saveCategories(@Body(JsonObjectPipe) body: Record<string, unknown>) {
    return this.catalog.adminSaveCategories(unwrapPayload(body));
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

  @Get('search-hot')
  getSearchHot() {
    return this.catalog.adminSearchHot();
  }

  @Put('search-hot')
  saveSearchHot(@Body(JsonObjectPipe) body: Record<string, unknown>) {
    return this.catalog.saveSearchHot(unwrapPayload(body));
  }

  @Get('reviews-catalog')
  getReviewsCatalog() {
    return this.catalog.adminReviewsCatalog();
  }

  @Put('reviews-catalog')
  saveReviewsCatalog(@Body(JsonObjectPipe) body: Record<string, unknown>) {
    return this.catalog.saveReviewsCatalog(unwrapPayload(body));
  }

  @Get('products/:productId/reviews')
  getProductReviews(@Param('productId') productId: string) {
    return this.catalog.adminProductReviews(productId);
  }

  @Put('products/:productId/reviews')
  saveProductReviews(
    @Param('productId') productId: string,
    @Body(JsonObjectPipe) body: Record<string, unknown>,
  ) {
    return this.catalog.saveProductReviews(productId, body);
  }
}
