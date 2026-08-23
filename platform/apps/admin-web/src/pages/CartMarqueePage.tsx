import {
  Button,
  Form,
  Input,
  Modal,
  Space,
  Table,
  Typography,
  message,
} from 'antd';
import { useEffect, useState } from 'react';
import { apiGet, apiPut } from '../api';

type MarqueeItem = {
  id: string;
  text: string;
  link: string;
};

export default function CartMarqueePage() {
  const [rows, setRows] = useState<MarqueeItem[]>([]);
  const [open, setOpen] = useState(false);
  const [editing, setEditing] = useState<MarqueeItem | null>(null);
  const [form] = Form.useForm();

  const load = async () => {
    const data = await apiGet<MarqueeItem[]>('/admin/v1/marketing/cart-marquee');
    setRows(Array.isArray(data) ? data : []);
  };

  const save = async (items: MarqueeItem[]) => {
    await apiPut('/admin/v1/marketing/cart-marquee', items);
    setRows(items);
    message.success('购物车跑马灯已保存');
  };

  useEffect(() => {
    void load();
  }, []);

  return (
    <div>
      <Space style={{ width: '100%', justifyContent: 'space-between' }}>
        <Typography.Title level={3} style={{ margin: 0 }}>
          购物车跑马灯
        </Typography.Title>
        <Button
          type="primary"
          onClick={() => {
            setEditing(null);
            form.resetFields();
            setOpen(true);
          }}
        >
          新增条目
        </Button>
      </Space>
      <Table
        style={{ marginTop: 16 }}
        rowKey="id"
        dataSource={rows}
        columns={[
          { title: 'ID', dataIndex: 'id', width: 100 },
          { title: '文案', dataIndex: 'text' },
          { title: '链接', dataIndex: 'link' },
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
                    await save(rows.filter((item) => item.id !== row.id));
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
        title={editing ? '编辑跑马灯' : '新增跑马灯'}
        open={open}
        onCancel={() => setOpen(false)}
        onOk={async () => {
          const values = await form.validateFields();
          const next = editing
            ? rows.map((item) => (item.id === editing.id ? values : item))
            : [...rows, values];
          await save(next);
          setOpen(false);
        }}
      >
        <Form form={form} layout="vertical">
          <Form.Item name="id" label="ID" rules={[{ required: true }]}>
            <Input disabled={!!editing} />
          </Form.Item>
          <Form.Item name="text" label="文案" rules={[{ required: true }]}>
            <Input.TextArea rows={2} />
          </Form.Item>
          <Form.Item name="link" label="链接" rules={[{ required: true }]}>
            <Input placeholder="/coupons" />
          </Form.Item>
        </Form>
      </Modal>
    </div>
  );
}
