import { Button, Card, Form, Input, Typography, message } from 'antd';
import { useNavigate } from 'react-router-dom';
import { apiPost } from '../api';

export default function LoginPage() {
  const navigate = useNavigate();

  return (
    <div
      style={{
        minHeight: '100vh',
        display: 'grid',
        placeItems: 'center',
        background:
          'radial-gradient(circle at top left, #e8e8e8, transparent 40%), linear-gradient(160deg, #fafafa, #ececec)',
      }}
    >
      <Card style={{ width: 380 }} bordered={false}>
        <Typography.Title level={3}>SHOO Admin</Typography.Title>
        <Typography.Paragraph type="secondary">
          Sign in to manage catalog, banners and orders.
        </Typography.Paragraph>
        <Form
          layout="vertical"
          initialValues={{
            email: 'admin@shoo.local',
            password: 'admin123456',
          }}
          onFinish={async (values) => {
            try {
              const data = await apiPost<{
                token: string;
                admin: { email: string };
              }>('/admin/v1/auth/login', values);
              localStorage.setItem('shoo_admin_token', data.token);
              localStorage.setItem('shoo_admin_email', data.admin.email);
              message.success('Logged in');
              navigate('/');
            } catch (e) {
              message.error(e instanceof Error ? e.message : 'Login failed');
            }
          }}
        >
          <Form.Item
            name="email"
            label="Email"
            rules={[{ required: true, type: 'email' }]}
          >
            <Input />
          </Form.Item>
          <Form.Item
            name="password"
            label="Password"
            rules={[{ required: true }]}
          >
            <Input.Password />
          </Form.Item>
          <Button type="primary" htmlType="submit" block>
            Sign in
          </Button>
        </Form>
      </Card>
    </div>
  );
}
