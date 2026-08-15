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

type Banner = {
  id: string;
  title: string;
  imageUrl: string;
  link: string;
  sort: number;
  enabled: boolean;
};

export default function BannersPage() {
  const [rows, setRows] = useState<Banner[]>([]);
  const [open, setOpen] = useState(false);
  const [editing, setEditing] = useState<Banner | null>(null);
  const [form] = Form.useForm();

  const load = async () => {
    const data = await apiGet<Banner[]>('/admin/v1/catalog/banners');
    setRows(data);
  };

  useEffect(() => {
    void load();
  }, []);

  return (
    <div>
      <Space style={{ width: '100%', justifyContent: 'space-between' }}>
        <Typography.Title level={3} style={{ margin: 0 }}>
          Banners
        </Typography.Title>
        <Button
          type="primary"
          onClick={() => {
            setEditing(null);
            form.resetFields();
            form.setFieldsValue({ sort: 0, enabled: true });
            setOpen(true);
          }}
        >
          New Banner
        </Button>
      </Space>
      <Table
        style={{ marginTop: 16 }}
        rowKey="id"
        dataSource={rows}
        columns={[
          { title: 'Title', dataIndex: 'title' },
          {
            title: 'Image',
            dataIndex: 'imageUrl',
            render: (url: string) => (
              <img src={url} alt="" style={{ width: 96, height: 40, objectFit: 'cover' }} />
            ),
          },
          { title: 'Link', dataIndex: 'link' },
          { title: 'Sort', dataIndex: 'sort', width: 80 },
          {
            title: 'Enabled',
            dataIndex: 'enabled',
            render: (v: boolean) => (v ? 'Yes' : 'No'),
          },
          {
            title: 'Actions',
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
                    await apiDelete(`/admin/v1/catalog/banners/${row.id}`);
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
        title={editing ? 'Edit Banner' : 'New Banner'}
        open={open}
        onCancel={() => setOpen(false)}
        onOk={() => form.submit()}
        destroyOnClose
      >
        <Form
          form={form}
          layout="vertical"
          onFinish={async (values) => {
            if (editing) {
              await apiPatch(`/admin/v1/catalog/banners/${editing.id}`, values);
            } else {
              await apiPost('/admin/v1/catalog/banners', values);
            }
            message.success('Saved');
            setOpen(false);
            await load();
          }}
        >
          <Form.Item name="title" label="Title" rules={[{ required: true }]}>
            <Input />
          </Form.Item>
          <Form.Item name="imageUrl" label="Image URL" rules={[{ required: true }]}>
            <Input />
          </Form.Item>
          <Form.Item name="link" label="Link" rules={[{ required: true }]}>
            <Input />
          </Form.Item>
          <Form.Item name="sort" label="Sort">
            <InputNumber style={{ width: '100%' }} />
          </Form.Item>
          <Form.Item name="enabled" label="Enabled" valuePropName="checked">
            <Switch />
          </Form.Item>
        </Form>
      </Modal>
    </div>
  );
}
