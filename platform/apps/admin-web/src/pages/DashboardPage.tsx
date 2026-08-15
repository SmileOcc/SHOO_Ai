import { Card, Col, Row, Statistic, Typography } from 'antd';
import { useEffect, useState } from 'react';
import { apiGet } from '../api';

export default function DashboardPage() {
  const [stats, setStats] = useState({
    products: 0,
    banners: 0,
    orders: 0,
  });

  useEffect(() => {
    void (async () => {
      const [products, banners, orders] = await Promise.all([
        apiGet<{ total: number }>('/admin/v1/catalog/products', {
          page: 1,
          pageSize: 1,
        }),
        apiGet<unknown[]>('/admin/v1/catalog/banners'),
        apiGet<{ total: number }>('/admin/v1/trade/orders', {
          page: 1,
          pageSize: 1,
        }),
      ]);
      setStats({
        products: products.total,
        banners: banners.length,
        orders: orders.total,
      });
    })();
  }, []);

  return (
    <div>
      <Typography.Title level={3}>Dashboard</Typography.Title>
      <Row gutter={16}>
        <Col span={8}>
          <Card>
            <Statistic title="Products" value={stats.products} />
          </Card>
        </Col>
        <Col span={8}>
          <Card>
            <Statistic title="Banners" value={stats.banners} />
          </Card>
        </Col>
        <Col span={8}>
          <Card>
            <Statistic title="Orders" value={stats.orders} />
          </Card>
        </Col>
      </Row>
    </div>
  );
}
