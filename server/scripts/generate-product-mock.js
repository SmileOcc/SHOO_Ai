/**
 * 按分类生成商品列表与详情 Mock 数据 → assets/mock/
 * Usage: npm run generate-products && npm run sync-mock
 */
import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const outDir = path.resolve(__dirname, '../../assets/mock');

const categories = [
  { id: 'c1', name: 'Women', icon: '👗' },
  { id: 'c2', name: 'Men', icon: '👔' },
  { id: 'c3', name: 'Kids', icon: '🧒' },
  { id: 'c4', name: 'Shoes', icon: '👟' },
  { id: 'c5', name: 'Bags', icon: '👜' },
  { id: 'c6', name: 'Beauty', icon: '💄' },
  { id: 'c7', name: 'Home', icon: '🏠' },
  { id: 'c8', name: 'Sale', icon: '🔥' },
];

const templates = {
  c1: [
    ['Ribbed Knit Crop Top', 'Soft ribbed knit with a flattering crop fit.', 1299, 2599, '-50%'],
    ['Floral Midi Dress', 'Lightweight floral print, perfect for summer.', 1599, 2799, '-43%'],
    ['Satin Slip Skirt', 'Silky satin fabric with a bias cut.', 1199, 2199, '-45%'],
    ['Oversized Blazer Jacket', 'Structured shoulders with relaxed silhouette.', 2499, 4999, '-50%'],
  ],
  c2: [
    ['Classic Cotton Tee', 'Breathable cotton, everyday essential.', 899, 1499, '-40%'],
    ['Slim Fit Chinos', 'Stretch twill with tapered leg.', 1699, 2899, '-41%'],
    ['Bomber Jacket', 'Lightweight nylon with ribbed trims.', 2199, 3999, '-45%'],
    ['Oxford Button Shirt', 'Crisp weave, office or weekend ready.', 1399, 2299, '-39%'],
  ],
  c3: [
    ['Cartoon Print Hoodie', 'Cozy fleece with fun graphic print.', 999, 1799, '-44%'],
    ['Denim Overalls', 'Adjustable straps, durable denim.', 1299, 2199, '-41%'],
    ['Striped Cotton Tee', 'Soft jersey, easy mix-and-match.', 599, 999, '-40%'],
    ['Lightweight Puffer Vest', 'Warm without bulk, zip front.', 1499, 2599, '-42%'],
  ],
  c4: [
    ['Chunky Platform Sandals', 'Cushioned sole, statement look.', 999, 1999, '-50%'],
    ['Mesh Running Sneakers', 'Breathable upper, flexible outsole.', 1899, 3299, '-42%'],
    ['Ankle Chelsea Boots', 'Elastic side panels, everyday boot.', 2299, 3999, '-43%'],
    ['Leather Loafers', 'Polished finish, slip-on comfort.', 1799, 2999, '-40%'],
  ],
  c5: [
    ['Mini Crossbody Bag', 'Compact size, adjustable strap.', 1299, 2199, '-41%'],
    ['Canvas Tote Bag', 'Roomy interior, reinforced handles.', 899, 1599, '-44%'],
    ['City Mini Backpack', 'Lightweight nylon, multiple pockets.', 1599, 2799, '-43%'],
    ['Evening Clutch', 'Sleek metallic finish for nights out.', 799, 1399, '-43%'],
  ],
  c6: [
    ['Velvet Lip Tint Set', 'Long-wear colors in a 3-piece set.', 699, 1199, '-42%'],
    ['Hydrating Face Serum', 'Niacinamide blend for daily glow.', 999, 1699, '-41%'],
    ['Eyeshadow Palette', '12 matte and shimmer shades.', 1299, 2199, '-41%'],
    ['Floral Body Mist', 'Light fragrance, travel-friendly.', 499, 899, '-44%'],
  ],
  c7: [
    ['Woven Throw Pillow', 'Textured cover, plush insert.', 899, 1599, '-44%'],
    ['Matte Ceramic Vase', 'Minimal shape for fresh or dried blooms.', 1299, 2199, '-41%'],
    ['USB Bedside Lamp', 'Warm dimmable light, touch control.', 1899, 3299, '-42%'],
    ['Rattan Storage Basket', 'Natural weave, handles for carrying.', 1099, 1899, '-42%'],
  ],
  c8: [
    ['Clearance Basic Tee', 'Last-chance colors at outlet price.', 399, 999, '-60%'],
    ['Outlet Wrap Dress', 'Limited stock, easy wrap style.', 799, 1999, '-60%'],
    ['Flash Deal Midi Skirt', 'Today only — high waist A-line.', 599, 1499, '-60%'],
    ['Final Sale Puffer', 'End-of-season insulated jacket.', 1499, 3999, '-63%'],
  ],
};

function productId(categoryId, index) {
  return `${categoryId}-p${index + 1}`;
}

function buildProducts() {
  const items = [];
  for (const category of categories) {
    const rows = templates[category.id];
    rows.forEach(([title, description, price, originalPrice, discountLabel], index) => {
      const id = productId(category.id, index);
      const rating = 4.3 + (index * 0.15);
      const soldCount = 3000 + index * 1700 + category.id.charCodeAt(1) * 100;
      items.push({
        id,
        categoryId: category.id,
        title,
        imageUrl: `https://picsum.photos/seed/${id}/400/500`,
        price,
        originalPrice,
        discountLabel,
        rating: Math.min(5, Number(rating.toFixed(1))),
        soldCount,
        description,
      });
    });
  }
  return items;
}

function buildCatalog(listItems) {
  return listItems.map((item) => ({
    ...item,
    images: [
      `https://picsum.photos/seed/${item.id}a/750/900`,
      `https://picsum.photos/seed/${item.id}b/750/900`,
      `https://picsum.photos/seed/${item.id}c/750/900`,
    ],
    reviewCount: Math.max(120, Math.floor(item.soldCount / 10)),
  }));
}

function buildReviewsCatalog(listItems) {
  const reviewTemplates = [
    {
      userName: 'Emma L.',
      rating: 5.0,
      content: 'Exactly as pictured. Great quality for the price.',
      variantLabel: 'Size M',
    },
    {
      userName: 'Sophie K.',
      rating: 4.5,
      content: 'Fast delivery and true to size. Would buy again.',
      variantLabel: 'Size S',
    },
    {
      userName: 'Mia R.',
      rating: 4.0,
      content: 'Nice material, comfortable for daily wear.',
      variantLabel: 'Size L',
    },
  ];

  const byProduct = {};
  for (const product of listItems) {
    const items = reviewTemplates.map((tpl, index) => ({
      id: `${product.id}-r${index + 1}`,
      userName: tpl.userName,
      userAvatarUrl:
        index % 2 === 0 ? `https://picsum.photos/seed/${product.id}u${index}/80/80` : '',
      rating: tpl.rating,
      content: `${tpl.content} (${product.title})`,
      createdAt: `2026-05-${String(28 - index * 3).padStart(2, '0')}`,
      imageUrls:
        index === 0 ? [`https://picsum.photos/seed/${product.id}rv/200/200`] : [],
      variantLabel: `${tpl.variantLabel} · ${product.title.split(' ')[0]}`,
    }));
    const averageRating =
      items.reduce((sum, r) => sum + r.rating, 0) / items.length;
    byProduct[product.id] = {
      averageRating: Number(averageRating.toFixed(1)),
      totalCount: items.length,
      items,
      hasMore: false,
    };
  }
  return byProduct;
}

const listItems = buildProducts();
const catalogItems = buildCatalog(listItems);

const productsJson = {
  code: 0,
  message: 'ok',
  data: {
    items: listItems.map(({ description, ...rest }) => rest),
    page: 1,
    pageSize: 50,
    total: listItems.length,
    hasMore: false,
  },
};

const catalogJson = {
  code: 0,
  message: 'ok',
  data: { items: catalogItems },
};

const reviewsJson = {
  code: 0,
  message: 'ok',
  data: { byProduct: buildReviewsCatalog(listItems) },
};

await fs.mkdir(outDir, { recursive: true });
await fs.writeFile(path.join(outDir, 'products.json'), `${JSON.stringify(productsJson, null, 2)}\n`);
await fs.writeFile(
  path.join(outDir, 'product_catalog.json'),
  `${JSON.stringify(catalogJson, null, 2)}\n`,
);
await fs.writeFile(
  path.join(outDir, 'product_reviews_catalog.json'),
  `${JSON.stringify(reviewsJson, null, 2)}\n`,
);

const searchItems = listItems.slice(0, 8).map(({ description, ...rest }) => rest);
const searchJson = {
  code: 0,
  message: 'ok',
  data: {
    items: searchItems,
    page: 1,
    pageSize: 20,
    total: searchItems.length,
    hasMore: false,
  },
};
await fs.writeFile(path.join(outDir, 'search.json'), `${JSON.stringify(searchJson, null, 2)}\n`);

console.log(
  `Generated ${listItems.length} products (${categories.length} categories) → ${outDir}`,
);
console.log('Run: npm run sync-mock');
