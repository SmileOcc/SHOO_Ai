import {
  Button,
  Form,
  Input,
  InputNumber,
  Modal,
  Space,
  Switch,
  Table,
  Typography,
  message,
} from 'antd';
import { useEffect, useState } from 'react';
import { apiDelete, apiGet, apiPatch, apiPost } from '../api';

type Product = {
  id: string;
  title: string;
  categoryId: string;
  imageUrl: string;
  price: number;
  originalPrice: number;
  discountLabel: string;
  enabled: boolean;
};

export default function ProductsPage() {
  const [rows, setRows] = useState<Product[]>([]);
  const [total, setTotal] = useState(0);
  const [page, setPage] = useState(1);
  const [q, setQ] = useState('');
  const [open, setOpen] = useState(false);
  const [editing, setEditing] = useState<Product | null>(null);
  const [form] = Form.useForm();
  const pageSize = 20;

  const load = async (p = page, keyword = q) => {
    const data = await apiGet<{ items: Product[]; total: number }>(
      '/admin/v1/catalog/products',
      { page: p, pageSize, q: keyword || undefined },
    );
    setRows(data.items);
    setTotal(data.total);
  };

  useEffect(() => {
    void load();
  }, [page]);

  return (
    <div>
      <Space style={{ width: '100%', justifyContent: 'space-between' }} wrap>
        <Typography.Title level={3} style={{ margin: 0 }}>
          Products
        </Typography.Title>
        <Space>
          <Input.Search
            placeholder="Search title / id"
            allowClear
            onSearch={(value) => {
              setQ(value);
              setPage(1);
              void load(1, value);
            }}
            style={{ width: 240 }}
          />
          <Button
            type="primary"
            onClick={() => {
              setEditing(null);
              form.resetFields();
              form.setFieldsValue({ enabled: true, price: 1000, originalPrice: 1200 });
              setOpen(true);
            }}
          >
            New Product
          </Button>
        </Space>
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
          {
            title: 'Image',
            dataIndex: 'imageUrl',
            width: 72,
            render: (url: string) => (
              <img src={url} alt="" style={{ width: 48, height: 60, objectFit: 'cover' }} />
            ),
          },
          { title: 'ID', dataIndex: 'id', width: 160 },
          { title: 'Title', dataIndex: 'title' },
          { title: 'Category', dataIndex: 'categoryId', width: 120 },
          {
            title: 'Price',
            dataIndex: 'price',
            width: 100,
            render: (v: number) => `¥${(v / 100).toFixed(2)}`,
          },
          {
            title: 'Enabled',
            dataIndex: 'enabled',
            width: 90,
            render: (v: boolean) => (v ? 'Yes' : 'No'),
          },
          {
            title: 'Actions',
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
                  Edit
                </Button>
                <Button
                  size="small"
                  danger
                  onClick={async () => {
                    await apiDelete(`/admin/v1/catalog/products/${row.id}`);
                    message.success('Deleted');
                    await load();
                  }}
                >
                  Delete
                </Button>
              </Space>
            ),
          },
        ]}
      />

      <Modal
        title={editing ? 'Edit Product' : 'New Product'}
        open={open}
        onCancel={() => setOpen(false)}
        onOk={() => form.submit()}
        width={640}
        destroyOnClose
      >
        <Form
          form={form}
          layout="vertical"
          onFinish={async (values) => {
            if (editing) {
              await apiPatch(`/admin/v1/catalog/products/${editing.id}`, values);
            } else {
              await apiPost('/admin/v1/catalog/products', values);
            }
            message.success('Saved');
            setOpen(false);
            await load();
          }}
        >
          {!editing && (
            <Form.Item name="id" label="Product ID" rules={[{ required: true }]}>
              <Input />
            </Form.Item>
          )}
          <Form.Item name="title" label="Title" rules={[{ required: true }]}>
            <Input />
          </Form.Item>
          <Form.Item name="categoryId" label="Category ID">
            <Input />
          </Form.Item>
          <Form.Item name="imageUrl" label="Image URL" rules={[{ required: true }]}>
            <Input />
          </Form.Item>
          <Form.Item name="price" label="Price (cents)" rules={[{ required: true }]}>
            <InputNumber style={{ width: '100%' }} />
          </Form.Item>
          <Form.Item
            name="originalPrice"
            label="Original Price (cents)"
            rules={[{ required: true }]}
          >
            <InputNumber style={{ width: '100%' }} />
          </Form.Item>
          <Form.Item name="discountLabel" label="Discount Label">
            <Input />
          </Form.Item>
          <Form.Item name="enabled" label="Enabled" valuePropName="checked">
            <Switch />
          </Form.Item>
        </Form>
      </Modal>
    </div>
  );
}
