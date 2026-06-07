/**
 * 按三级分类叶子节点生成商品 Mock → assets/mock/
 * T-Shirts (c1-g1-l1) 固定 65 条，其余叶子默认 6 条。
 * Usage: npm run mock:refresh
 */
import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const outDir = path.resolve(__dirname, '../../assets/mock');
const categoriesPath = path.join(outDir, 'categories.json');

const LEAF_PRODUCT_COUNTS = {
  'c1-g1-l1': 65, // T-Shirts
};

const DEFAULT_LEAF_COUNT = 6;

const tshirtAdjectives = [
  'Classic',
  'Soft',
  'Slim',
  'Oversized',
  'Vintage',
  'Essential',
  'Relaxed',
  'Premium',
  'Lightweight',
  'Organic',
];

const tshirtStyles = [
  'Crew Neck',
  'V-Neck',
  'Graphic',
  'Striped',
  'Plain',
  'Pocket',
  'Long Sleeve',
  'Henley',
];

async function loadLeaves() {
  const raw = await fs.readFile(categoriesPath, 'utf8');
  const envelope = JSON.parse(raw);
  const categories = envelope.data ?? [];
  const leaves = [];

  for (const category of categories) {
    for (const group of category.groups ?? []) {
      for (const child of group.children ?? []) {
        leaves.push({
          id: child.id,
          name: child.name,
          rootId: category.id,
          rootName: category.name,
          groupName: group.name,
        });
      }
    }
  }
  return leaves;
}

function productCountForLeaf(leafId) {
  return LEAF_PRODUCT_COUNTS[leafId] ?? DEFAULT_LEAF_COUNT;
}

function buildTitle(leaf, index) {
  if (leaf.id === 'c1-g1-l1') {
    const adj = tshirtAdjectives[index % tshirtAdjectives.length];
    const style = tshirtStyles[Math.floor(index / tshirtAdjectives.length) % tshirtStyles.length];
    return `${adj} ${style} T-Shirt ${index + 1}`;
  }
  return `${leaf.name} Item ${index + 1}`;
}

function buildDescription(leaf, title) {
  if (leaf.id === 'c1-g1-l1') {
    return `${title} — breathable cotton blend, everyday fit for ${leaf.groupName}.`;
  }
  return `${title} — curated pick for ${leaf.rootName} › ${leaf.groupName} › ${leaf.name}.`;
}

function buildProducts(leaves) {
  const items = [];
  for (const leaf of leaves) {
    const count = productCountForLeaf(leaf.id);
    for (let index = 0; index < count; index++) {
      const id = `${leaf.id}-p${index + 1}`;
      const title = buildTitle(leaf, index);
      const basePrice = 799 + (index % 12) * 100 + leaf.id.length * 17;
      const originalPrice = basePrice + 400 + (index % 5) * 120;
      const discountPct = Math.min(60, Math.round((1 - basePrice / originalPrice) * 100));
      const rating = 4.1 + (index % 9) * 0.1;
      const soldCount = 800 + index * 137 + leaf.id.charCodeAt(leaf.id.length - 1) * 11;

      items.push({
        id,
        categoryId: leaf.id,
        title,
        imageUrl: `https://picsum.photos/seed/${id}/400/500`,
        price: basePrice,
        originalPrice,
        discountLabel: discountPct > 0 ? `-${discountPct}%` : '',
        rating: Math.min(5, Number(rating.toFixed(1))),
        soldCount,
        description: buildDescription(leaf, title),
      });
    }
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

const leaves = await loadLeaves();
const listItems = buildProducts(leaves);
const catalogItems = buildCatalog(listItems);
const tshirtCount = listItems.filter((item) => item.categoryId === 'c1-g1-l1').length;

const productsJson = {
  code: 0,
  message: 'ok',
  data: {
    items: listItems.map(({ description, ...rest }) => rest),
    page: 1,
    pageSize: listItems.length,
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

const searchItems = listItems.slice(0, 12).map(({ description, ...rest }) => rest);
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
  `Generated ${listItems.length} products (${leaves.length} leaf categories, T-Shirts=${tshirtCount}) → ${outDir}`,
);
console.log('Run: npm run sync-mock');
