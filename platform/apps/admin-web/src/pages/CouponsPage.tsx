import {
  Button,
  Form,
  Input,
  InputNumber,
  Modal,
  Select,
  Space,
  Switch,
  Table,
  Tag,
  Typography,
  message,
} from 'antd';
import { useEffect, useState } from 'react';
import { apiDelete, apiGet, apiPatch, apiPost } from '../api';

type CouponTemplate = {
  id: string;
  title: string;
  description: string;
  type: string;
  discountCents: number;
  discountPercent: number;
  minOrderCents: number;
  validDays: number;
  stock: number | null;
  claimedCount: number;
  enabled: boolean;
  source: string;
};

export default function CouponsPage() {
  const [rows, setRows] = useState<CouponTemplate[]>([]);
  const [open, setOpen] = useState(false);
  const [editing, setEditing] = useState<CouponTemplate | null>(null);
  const [form] = Form.useForm();

  const load = async () => {
    const data = await apiGet<CouponTemplate[]>('/admin/v1/coupons/templates');
    setRows(data);
  };

  useEffect(() => {
    void load();
  }, []);

  const sourceColor = (source: string) => {
    if (source === 'theme') return 'purple';
    if (source === 'flash') return 'volcano';
    return 'blue';
  };

  return (
    <div>
      <Space style={{ width: '100%', justifyContent: 'space-between' }}>
        <Typography.Title level={3} style={{ margin: 0 }}>
          优惠券管理
        </Typography.Title>
        <Space>
          <Button
            onClick={async () => {
              await apiPost('/admin/v1/coupons/templates/seed', {});
              message.success('已从 Mock 数据同步模板');
              await load();
            }}
          >
            同步 Mock 模板
          </Button>
          <Button
            type="primary"
            onClick={() => {
              setEditing(null);
              form.resetFields();
              form.setFieldsValue({
                type: 'fixed',
                validDays: 30,
                enabled: true,
                source: 'wallet',
              });
              setOpen(true);
            }}
          >
            新建优惠券
          </Button>
        </Space>
      </Space>
      <Table
        style={{ marginTop: 16 }}
        rowKey="id"
        dataSource={rows}
        columns={[
          { title: 'ID', dataIndex: 'id', width: 120 },
          { title: '标题', dataIndex: 'title' },
          {
            title: '来源',
            dataIndex: 'source',
            width: 90,
            render: (v: string) => <Tag color={sourceColor(v)}>{v}</Tag>,
          },
          {
            title: '类型',
            dataIndex: 'type',
            width: 80,
            render: (v: string) => (v === 'percent' ? '折扣' : '满减'),
          },
          {
            title: '面额',
            render: (_, row) =>
              row.type === 'percent'
                ? `${row.discountPercent}%`
                : `¥${(row.discountCents / 100).toFixed(2)}`,
          },
          {
            title: '门槛',
            dataIndex: 'minOrderCents',
            render: (v: number) => `¥${(v / 100).toFixed(2)}`,
          },
          {
            title: '已领/库存',
            render: (_, row) =>
              row.stock == null
                ? `${row.claimedCount} / ∞`
                : `${row.claimedCount} / ${row.stock}`,
          },
          {
            title: '启用',
            dataIndex: 'enabled',
            width: 70,
            render: (v: boolean) => (v ? '是' : '否'),
          },
          {
            title: '操作',
            width: 160,
            render: (_, row) => (
              <Space>
                <Button
                  size="small"
                  onClick={() => {
                    setEditing(row);
                    form.setFieldsValue(row);
                    setOpen(true);
                  }}
                >
                  编辑
                </Button>
                <Button
                  size="small"
                  danger
                  onClick={async () => {
                    await apiDelete(`/admin/v1/coupons/templates/${row.id}`);
                    message.success('已删除');
                    await load();
                  }}
                >
                  删除
                </Button>
              </Space>
            ),
          },
        ]}
      />
      <Modal
        title={editing ? `编辑 ${editing.id}` : '新建优惠券'}
        open={open}
        onCancel={() => setOpen(false)}
        onOk={async () => {
          const values = await form.validateFields();
          if (editing) {
            await apiPatch(`/admin/v1/coupons/templates/${editing.id}`, values);
            message.success('已更新');
          } else {
            await apiPost('/admin/v1/coupons/templates', values);
            message.success('已创建');
          }
          setOpen(false);
          await load();
        }}
        width={640}
      >
        <Form form={form} layout="vertical">
          {!editing && (
            <Form.Item name="id" label="优惠券 ID" rules={[{ required: true }]}>
              <Input placeholder="如 c_all_10 / fc-10-1" />
            </Form.Item>
          )}
          <Form.Item name="title" label="标题" rules={[{ required: true }]}>
            <Input />
          </Form.Item>
          <Form.Item name="description" label="描述">
            <Input.TextArea rows={2} />
          </Form.Item>
          <Form.Item name="type" label="类型" rules={[{ required: true }]}>
            <Select
              options={[
                { value: 'fixed', label: '满减 (fixed)' },
                { value: 'percent', label: '折扣 (percent)' },
              ]}
            />
          </Form.Item>
          <Form.Item name="discountCents" label="减免金额（分）">
            <InputNumber min={0} style={{ width: '100%' }} />
          </Form.Item>
          <Form.Item name="discountPercent" label="折扣百分比">
            <InputNumber min={0} max={100} style={{ width: '100%' }} />
          </Form.Item>
          <Form.Item name="minOrderCents" label="最低订单金额（分）">
            <InputNumber min={0} style={{ width: '100%' }} />
          </Form.Item>
          <Form.Item name="validDays" label="领取后有效天数">
            <InputNumber min={1} style={{ width: '100%' }} />
          </Form.Item>
          <Form.Item name="stock" label="库存（留空=不限）">
            <InputNumber min={0} style={{ width: '100%' }} />
          </Form.Item>
          <Form.Item name="source" label="来源">
            <Select
              options={[
                { value: 'wallet', label: 'wallet' },
                { value: 'theme', label: 'theme' },
                { value: 'flash', label: 'flash' },
              ]}
            />
          </Form.Item>
          <Form.Item name="enabled" label="启用" valuePropName="checked">
            <Switch />
          </Form.Item>
        </Form>
      </Modal>
    </div>
  );
}
