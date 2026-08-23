import { Button, Card, Input, Space, Tabs, Typography, message } from 'antd';
import { useEffect, useState } from 'react';
import { apiGet, apiPut } from '../api';

type ReviewItem = {
  id: string;
  userName: string;
  userAvatarUrl?: string;
  rating: number;
  content: string;
  createdAt: string;
  imageUrls?: string[];
  variantLabel?: string;
};

type ProductReviews = {
  averageRating: number;
  totalCount: number;
  items: ReviewItem[];
  hasMore?: boolean;
};

export default function ReviewsPage() {
  const [productId, setProductId] = useState('c1-g1-l1-p1');
  const [productJson, setProductJson] = useState('{}');
  const [catalogJson, setCatalogJson] = useState('{}');
  const [loading, setLoading] = useState(false);

  const loadCatalog = async () => {
    setLoading(true);
    try {
      const data = await apiGet<Record<string, unknown>>(
        '/admin/v1/catalog/reviews-catalog',
      );
      setCatalogJson(JSON.stringify(data ?? {}, null, 2));
    } finally {
      setLoading(false);
    }
  };

  const loadProduct = async (id: string) => {
    setLoading(true);
    try {
      const data = await apiGet<ProductReviews | null>(
        `/admin/v1/catalog/products/${id}/reviews`,
      );
      setProductJson(JSON.stringify(data ?? {}, null, 2));
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    void loadCatalog();
    void loadProduct(productId);
  }, []);

  return (
    <div>
      <Typography.Title level={3}>商品评价</Typography.Title>
      <Tabs
        items={[
          {
            key: 'product',
            label: '按商品编辑',
            children: (
              <Card>
                <Typography.Paragraph type="secondary">
                  编辑单个商品的评价数据，对应 App{' '}
                  <code>GET /products/:id/reviews</code>
                </Typography.Paragraph>
                <Space style={{ marginBottom: 12 }}>
                  <Input
                    placeholder="商品 ID"
                    value={productId}
                    onChange={(e) => setProductId(e.target.value)}
                    style={{ width: 280 }}
                  />
                  <Button onClick={() => void loadProduct(productId)} loading={loading}>
                    加载
                  </Button>
                  <Button
                    type="primary"
                    loading={loading}
                    onClick={async () => {
                      try {
                        const payload = JSON.parse(productJson) as ProductReviews;
                        await apiPut(
                          `/admin/v1/catalog/products/${productId}/reviews`,
                          payload,
                        );
                        message.success('商品评价已保存');
                      } catch (error) {
                        message.error(
                          error instanceof Error ? error.message : 'JSON 格式错误',
                        );
                      }
                    }}
                  >
                    保存
                  </Button>
                </Space>
                <Input.TextArea
                  value={productJson}
                  onChange={(e) => setProductJson(e.target.value)}
                  rows={22}
                  style={{ fontFamily: 'monospace' }}
                />
              </Card>
            ),
          },
          {
            key: 'catalog',
            label: '全量目录 JSON',
            children: (
              <Card>
                <Space style={{ marginBottom: 12 }}>
                  <Button onClick={() => void loadCatalog()} loading={loading}>
                    重新加载
                  </Button>
                  <Button
                    type="primary"
                    loading={loading}
                    onClick={async () => {
                      try {
                        const payload = JSON.parse(catalogJson) as unknown;
                        await apiPut('/admin/v1/catalog/reviews-catalog', payload);
                        message.success('评价目录已保存');
                      } catch (error) {
                        message.error(
                          error instanceof Error ? error.message : 'JSON 格式错误',
                        );
                      }
                    }}
                  >
                    保存全量
                  </Button>
                </Space>
                <Input.TextArea
                  value={catalogJson}
                  onChange={(e) => setCatalogJson(e.target.value)}
                  rows={24}
                  style={{ fontFamily: 'monospace' }}
                />
              </Card>
            ),
          },
        ]}
      />
    </div>
  );
}
