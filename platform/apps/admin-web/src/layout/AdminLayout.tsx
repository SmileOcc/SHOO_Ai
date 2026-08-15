import { Layout, Menu, Typography, Button, Space } from 'antd';
import {
  AppstoreOutlined,
  PictureOutlined,
  ShoppingOutlined,
  UnorderedListOutlined,
  DashboardOutlined,
  HomeOutlined,
} from '@ant-design/icons';
import { Outlet, useLocation, useNavigate } from 'react-router-dom';

const { Header, Sider, Content } = Layout;

export default function AdminLayout() {
  const navigate = useNavigate();
  const location = useLocation();
  const selected = location.pathname === '/' ? '/' : location.pathname;

  return (
    <Layout style={{ minHeight: '100vh' }}>
      <Sider theme="light" width={220} style={{ borderRight: '1px solid #eee' }}>
        <div style={{ padding: '20px 16px' }}>
          <Typography.Title level={4} style={{ margin: 0 }}>
            SHOO Admin
          </Typography.Title>
          <Typography.Text type="secondary">Platform Console</Typography.Text>
        </div>
        <Menu
          mode="inline"
          selectedKeys={[selected]}
          onClick={({ key }) => navigate(key)}
          items={[
            { key: '/', icon: <DashboardOutlined />, label: 'Dashboard' },
            {
              key: '/home',
              icon: <HomeOutlined />,
              label: '首页配置',
            },
            { key: '/banners', icon: <PictureOutlined />, label: 'Banners' },
            { key: '/products', icon: <ShoppingOutlined />, label: 'Products' },
            {
              key: '/categories',
              icon: <AppstoreOutlined />,
              label: '分类 Categories',
            },
            {
              key: '/orders',
              icon: <UnorderedListOutlined />,
              label: 'Orders',
            },
          ]}
        />
      </Sider>
      <Layout>
        <Header
          style={{
            background: '#fff',
            borderBottom: '1px solid #eee',
            display: 'flex',
            justifyContent: 'flex-end',
            alignItems: 'center',
            paddingInline: 24,
          }}
        >
          <Space>
            <Typography.Text type="secondary">
              {localStorage.getItem('shoo_admin_email') || 'admin'}
            </Typography.Text>
            <Button
              onClick={() => {
                localStorage.removeItem('shoo_admin_token');
                localStorage.removeItem('shoo_admin_email');
                navigate('/login');
              }}
            >
              Logout
            </Button>
          </Space>
        </Header>
        <Content style={{ padding: 24 }}>
          <Outlet />
        </Content>
      </Layout>
    </Layout>
  );
}
