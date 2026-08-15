import { Select, Space, Table, Typography, message } from 'antd';
import { useEffect, useState } from 'react';
import { apiGet, apiPatch } from '../api';

type Order = {
  id: string;
  orderNo: string;
  status: string;
  totalCents: number;
  createdAt: string;
  items: Array<{ title: string; quantity: number }>;
};

const statuses = [
  'pending_payment',
  'paid',
  'shipped',
  'delivered',
  'cancelled',
];

export default function OrdersPage() {
  const [rows, setRows] = useState<Order[]>([]);
  const [total, setTotal] = useState(0);
  const [page, setPage] = useState(1);
  const pageSize = 20;

  const load = async (p = page) => {
    const data = await apiGet<{ items: Order[]; total: number }>(
      '/admin/v1/trade/orders',
      { page: p, pageSize },
    );
    setRows(data.items);
    setTotal(data.total);
  };

  useEffect(() => {
    void load();
  }, [page]);

  return (
    <div>
      <Typography.Title level={3}>Orders</Typography.Title>
      <Table
        rowKey="id"
        dataSource={rows}
        pagination={{
          current: page,
          pageSize,
          total,
          onChange: (p) => setPage(p),
        }}
        columns={[
          { title: 'Order No', dataIndex: 'orderNo' },
          { title: 'Created', dataIndex: 'createdAt', width: 160 },
          {
            title: 'Items',
            render: (_, row) =>
              row.items.map((i) => `${i.title} x${i.quantity}`).join(', '),
          },
          {
            title: 'Total',
            dataIndex: 'totalCents',
            width: 100,
            render: (v: number) => `¥${(v / 100).toFixed(2)}`,
          },
          {
            title: 'Status',
            dataIndex: 'status',
            width: 180,
            render: (status: string, row) => (
              <Select
                value={status}
                style={{ width: 160 }}
                options={statuses.map((s) => ({ value: s, label: s }))}
                onChange={async (value) => {
                  await apiPatch(`/admin/v1/trade/orders/${row.id}/status`, {
                    status: value,
                  });
                  message.success('Updated');
                  await load();
                }}
              />
            ),
          },
        ]}
      />
      <Space />
    </div>
  );
}
