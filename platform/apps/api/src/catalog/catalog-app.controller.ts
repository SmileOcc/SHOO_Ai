import { Controller, Get, Param, Query } from '@nestjs/common';
import { CatalogService } from './catalog.service';

@Controller('v1')
export class CatalogAppController {
  constructor(private readonly catalog: CatalogService) {}

  @Get('banners')
  listBanners() {
    return this.catalog.listBanners();
  }

  @Get('categories')
  getCategories() {
    return this.catalog.getCategories();
  }

  @Get('products')
  listProducts(
    @Query('page') page?: string,
    @Query('pageSize') pageSize?: string,
    @Query('categoryId') categoryId?: string,
  ) {
    return this.catalog.listProducts({
      page: page ? Number(page) : undefined,
      pageSize: pageSize ? Number(pageSize) : undefined,
      categoryId,
    });
  }

  @Get('products/batch')
  batchProducts(@Query('ids') ids?: string) {
    const list = (ids ?? '')
      .split(',')
      .map((s) => s.trim())
      .filter(Boolean);
    return this.catalog.batchProducts(list);
  }

  @Get('products/:id/reviews')
  productReviews(@Param('id') id: string) {
    return this.catalog.getProductReviews(id);
  }

  @Get('products/:id')
  getProduct(@Param('id') id: string, @Query() query: Record<string, string>) {
    return this.catalog.getProduct(id, query);
  }

  @Get('search/hot')
  searchHot() {
    return this.catalog.searchHot();
  }

  @Get('search')
  search(
    @Query('q') q?: string,
    @Query('page') page?: string,
    @Query('pageSize') pageSize?: string,
  ) {
    return this.catalog.search({
      q,
      page: page ? Number(page) : undefined,
      pageSize: pageSize ? Number(pageSize) : undefined,
    });
  }
}
