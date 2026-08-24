import { Button, Card, Input, Space, Tabs, Typography } from 'antd';
import { useState } from 'react';
import { useJsonDocument } from '../hooks/useJsonDocument';

type DocTab = {
  key: string;
  label: string;
  path: string;
  description: string;
};

const DOC_TABS: DocTab[] = [
  {
    key: 'data',
    label: '活动数据',
    path: '/admin/v1/marketing/activity-data',
    description: 'GET /activity/data — WebView 活动主页模块配置',
  },
  {
    key: 'detail',
    label: '活动详情',
    path: '/admin/v1/marketing/activity-detail',
    description: 'GET /activity/detail — 富文本详情页',
  },
  {
    key: 'level3',
    label: '三级详情',
    path: '/admin/v1/marketing/activity-level3-detail',
    description: 'GET /activity/detail/level3 — 日程/议程',
  },
  {
    key: 'user-check',
    label: '用户校验',
    path: '/admin/v1/marketing/activity-user-check',
    description: 'GET /activity/user/check — 活动页用户态 mock',
  },
  {
    key: 'url-rules',
    label: 'URL 规则',
    path: '/admin/v1/marketing/activity-url-rules',
    description: 'GET /activity/config/url-rules — 白名单域名',
  },
];

function LegacyActivityTab({ tab }: { tab: DocTab }) {
  const { jsonText, setJsonText, loading, load, save } = useJsonDocument({
    path: tab.path,
    successMessage: `${tab.label} 已保存`,
  });

  return (
    <Card>
      <Typography.Paragraph type="secondary">
        {tab.description}
      </Typography.Paragraph>
      <Space style={{ marginBottom: 12 }}>
        <Button onClick={() => void load()} loading={loading}>
          重新加载
        </Button>
        <Button type="primary" loading={loading} onClick={() => void save()}>
          保存
        </Button>
      </Space>
      <Input.TextArea
        value={jsonText}
        onChange={(e) => setJsonText(e.target.value)}
        rows={24}
        style={{ fontFamily: 'monospace' }}
      />
    </Card>
  );
}

export default function LegacyActivityPage() {
  const [activeKey, setActiveKey] = useState('data');

  return (
    <div>
      <Typography.Title level={3}>旧版 WebView 活动</Typography.Title>
      <Typography.Paragraph type="secondary">
        管理 App <code>activity/*</code> 接口的 JSON 文档。新活动请优先使用「主题活动」；
        此处用于维护仍通过 WebView 加载的旧活动页。
      </Typography.Paragraph>
      <Tabs
        activeKey={activeKey}
        destroyOnHidden
        onChange={setActiveKey}
        items={DOC_TABS.map((tab) => ({
          key: tab.key,
          label: tab.label,
          children: <LegacyActivityTab tab={tab} />,
        }))}
      />
    </div>
  );
}
