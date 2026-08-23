import {
  Button,
  Descriptions,
  Drawer,
  Form,
  Input,
  Modal,
  Select,
  Space,
  Switch,
  Table,
  Typography,
  message,
} from 'antd';
import { useEffect, useState } from 'react';
import { apiGet, apiPatch, apiPut } from '../api';

type OrderItem = {
  productId: string;
  title: string;
  imageUrl: string;
  price: number;
  quantity: number;
  variantLabel: string;
};

type Order = {
  id: string;
  orderNo: string;
  status: string;
  totalCents: number;
  createdAt: string;
  shippingAddress: string;
  hasLogistics: boolean;
  items: OrderItem[];
};

type LogisticsEvent = {
  time: string;
  status: string;
  description: string;
  isActive?: boolean;
};

type Logistics = {
  orderId: string;
  carrier: string;
  trackingNumber: string;
  events: LogisticsEvent[];
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
  const [statusFilter, setStatusFilter] = useState<string | undefined>();
  const [detail, setDetail] = useState<Order | null>(null);
  const [logisticsOpen, setLogisticsOpen] = useState(false);
  const [logisticsOrderId, setLogisticsOrderId] = useState('');
  const [logisticsForm] = Form.useForm<Logistics>();
  const pageSize = 20;

  const load = async (p = page, status = statusFilter) => {
    const params: Record<string, string | number> = { page: p, pageSize };
    if (status) params.status = status;
    const data = await apiGet<{ items: Order[]; total: number }>(
      '/admin/v1/trade/orders',
      params,
    );
    setRows(data.items);
    setTotal(data.total);
  };

  useEffect(() => {
    void load();
  }, [page, statusFilter]);

  const openLogistics = async (orderId: string) => {
    setLogisticsOrderId(orderId);
    const data = await apiGet<Logistics>(
      `/admin/v1/trade/orders/${orderId}/logistics`,
    );
    logisticsForm.setFieldsValue({
      carrier: data.carrier,
      trackingNumber: data.trackingNumber,
      events: data.events ?? [],
    });
    setLogisticsOpen(true);
  };

  return (
    <div>
      <Space style={{ width: '100%', justifyContent: 'space-between' }}>
        <Typography.Title level={3} style={{ margin: 0 }}>
          订单管理
        </Typography.Title>
        <Select
          allowClear
          placeholder="按状态筛选"
          style={{ width: 200 }}
          value={statusFilter}
          options={statuses.map((s) => ({ value: s, label: s }))}
          onChange={(value) => {
            setPage(1);
            setStatusFilter(value);
          }}
        />
      </Space>
      <Table
        style={{ marginTop: 16 }}
        rowKey="id"
        dataSource={rows}
        pagination={{
          current: page,
          pageSize,
          total,
          onChange: (p) => setPage(p),
        }}
        columns={[
          { title: '订单号', dataIndex: 'orderNo', width: 160 },
          { title: '下单时间', dataIndex: 'createdAt', width: 160 },
          {
            title: '商品',
            render: (_, row) =>
              row.items.map((i) => `${i.title} x${i.quantity}`).join(', '),
          },
          {
            title: '金额',
            dataIndex: 'totalCents',
            width: 100,
            render: (v: number) => `¥${(v / 100).toFixed(2)}`,
          },
          {
            title: '物流',
            width: 80,
            render: (_, row) => (row.hasLogistics ? '有' : '无'),
          },
          {
            title: '状态',
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
                  message.success('状态已更新');
                  await load();
                }}
              />
            ),
          },
          {
            title: '操作',
            width: 200,
            render: (_, row) => (
              <Space>
                <Button
                  size="small"
                  onClick={async () => {
                    const data = await apiGet<Order>(
                      `/admin/v1/trade/orders/${row.id}`,
                    );
                    setDetail(data);
                  }}
                >
                  详情
                </Button>
                <Button size="small" onClick={() => void openLogistics(row.id)}>
                  物流
                </Button>
              </Space>
            ),
          },
        ]}
      />

      <Drawer
        title={detail ? `订单 ${detail.orderNo}` : '订单详情'}
        open={!!detail}
        width={640}
        onClose={() => setDetail(null)}
      >
        {detail && (
          <>
            <Descriptions column={1} bordered size="small">
              <Descriptions.Item label="订单 ID">{detail.id}</Descriptions.Item>
              <Descriptions.Item label="状态">{detail.status}</Descriptions.Item>
              <Descriptions.Item label="金额">
                ¥{(detail.totalCents / 100).toFixed(2)}
              </Descriptions.Item>
              <Descriptions.Item label="下单时间">
                {detail.createdAt}
              </Descriptions.Item>
              <Descriptions.Item label="收货地址">
                <Input.TextArea
                  rows={2}
                  defaultValue={detail.shippingAddress}
                  onBlur={async (e) => {
                    await apiPatch(`/admin/v1/trade/orders/${detail.id}`, {
                      shippingAddress: e.target.value,
                    });
                    message.success('地址已保存');
                    const next = await apiGet<Order>(
                      `/admin/v1/trade/orders/${detail.id}`,
                    );
                    setDetail(next);
                    await load();
                  }}
                />
              </Descriptions.Item>
              <Descriptions.Item label="有物流">
                <Switch
                  checked={detail.hasLogistics}
                  onChange={async (checked) => {
                    await apiPatch(`/admin/v1/trade/orders/${detail.id}`, {
                      hasLogistics: checked,
                    });
                    message.success('已更新');
                    const next = await apiGet<Order>(
                      `/admin/v1/trade/orders/${detail.id}`,
                    );
                    setDetail(next);
                    await load();
                  }}
                />
              </Descriptions.Item>
            </Descriptions>
            <Typography.Title level={5} style={{ marginTop: 16 }}>
              商品明细
            </Typography.Title>
            <Table
              size="small"
              rowKey="productId"
              pagination={false}
              dataSource={detail.items}
              columns={[
                {
                  title: '图片',
                  dataIndex: 'imageUrl',
                  width: 72,
                  render: (url: string) => (
                    <img
                      src={url}
                      alt=""
                      style={{ width: 48, height: 48, objectFit: 'cover' }}
                    />
                  ),
                },
                { title: '商品', dataIndex: 'title' },
                { title: '规格', dataIndex: 'variantLabel' },
                {
                  title: '单价',
                  dataIndex: 'price',
                  render: (v: number) => `¥${(v / 100).toFixed(2)}`,
                },
                { title: '数量', dataIndex: 'quantity', width: 60 },
              ]}
            />
          </>
        )}
      </Drawer>

      <Modal
        title={`物流信息 — ${logisticsOrderId}`}
        open={logisticsOpen}
        width={720}
        onCancel={() => setLogisticsOpen(false)}
        onOk={async () => {
          const values = await logisticsForm.validateFields();
          await apiPut(
            `/admin/v1/trade/orders/${logisticsOrderId}/logistics`,
            values,
          );
          message.success('物流已保存');
          setLogisticsOpen(false);
          await load();
        }}
      >
        <Form form={logisticsForm} layout="vertical">
          <Form.Item name="carrier" label="承运商" rules={[{ required: true }]}>
            <Input />
          </Form.Item>
          <Form.Item
            name="trackingNumber"
            label="运单号"
            rules={[{ required: true }]}
          >
            <Input />
          </Form.Item>
          <Form.List name="events">
            {(fields, { add, remove }) => (
              <>
                <Typography.Text strong>物流轨迹</Typography.Text>
                {fields.map((field) => (
                  <Space
                    key={field.key}
                    style={{ display: 'flex', marginTop: 8 }}
                    align="start"
                  >
                    <Form.Item
                      {...field}
                      name={[field.name, 'time']}
                      rules={[{ required: true }]}
                    >
                      <Input placeholder="时间" style={{ width: 140 }} />
                    </Form.Item>
                    <Form.Item
                      {...field}
                      name={[field.name, 'status']}
                      rules={[{ required: true }]}
                    >
                      <Input placeholder="状态" style={{ width: 120 }} />
                    </Form.Item>
                    <Form.Item
                      {...field}
                      name={[field.name, 'description']}
                      rules={[{ required: true }]}
                    >
                      <Input placeholder="描述" style={{ width: 240 }} />
                    </Form.Item>
                    <Form.Item {...field} name={[field.name, 'isActive']}>
                      <Switch checkedChildren="当前" unCheckedChildren="历史" />
                    </Form.Item>
                    <Button danger onClick={() => remove(field.name)}>
                      删
                    </Button>
                  </Space>
                ))}
                <Button type="dashed" onClick={() => add()} block>
                  添加轨迹节点
                </Button>
              </>
            )}
          </Form.List>
        </Form>
      </Modal>
    </div>
  );
}
