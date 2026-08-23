import { Button, Card, Input, Space, Tabs, Typography, message } from 'antd';
import { useEffect, useState } from 'react';
import { apiGet, apiPut } from '../api';

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

export default function LegacyActivityPage() {
  const [activeKey, setActiveKey] = useState('data');
  const [jsonByKey, setJsonByKey] = useState<Record<string, string>>({});
  const [loading, setLoading] = useState(false);

  const loadTab = async (tab: DocTab) => {
    setLoading(true);
    try {
      const data = await apiGet<unknown>(tab.path);
      setJsonByKey((prev) => ({
        ...prev,
        [tab.key]: JSON.stringify(data ?? {}, null, 2),
      }));
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    void loadTab(DOC_TABS[0]);
  }, []);

  return (
    <div>
      <Typography.Title level={3}>旧版 WebView 活动</Typography.Title>
      <Typography.Paragraph type="secondary">
        管理 App <code>activity/*</code> 接口的 JSON 文档。新活动请优先使用「主题活动」；
        此处用于维护仍通过 WebView 加载的旧活动页。
      </Typography.Paragraph>
      <Tabs
        activeKey={activeKey}
        onChange={(key) => {
          setActiveKey(key);
          const tab = DOC_TABS.find((t) => t.key === key);
          if (tab && !jsonByKey[key]) void loadTab(tab);
        }}
        items={DOC_TABS.map((tab) => ({
          key: tab.key,
          label: tab.label,
          children: (
            <Card>
              <Typography.Paragraph type="secondary">
                {tab.description}
              </Typography.Paragraph>
              <Space style={{ marginBottom: 12 }}>
                <Button onClick={() => void loadTab(tab)} loading={loading}>
                  重新加载
                </Button>
                <Button
                  type="primary"
                  loading={loading}
                  onClick={async () => {
                    try {
                      const payload = JSON.parse(jsonByKey[tab.key] ?? '{}') as unknown;
                      await apiPut(tab.path, payload);
                      message.success(`${tab.label} 已保存`);
                    } catch (error) {
                      message.error(
                        error instanceof Error ? error.message : 'JSON 格式错误',
                      );
                    }
                  }}
                >
                  保存
                </Button>
              </Space>
              <Input.TextArea
                value={jsonByKey[tab.key] ?? ''}
                onChange={(e) =>
                  setJsonByKey((prev) => ({
                    ...prev,
                    [tab.key]: e.target.value,
                  }))
                }
                rows={24}
                style={{ fontFamily: 'monospace' }}
              />
            </Card>
          ),
        }))}
      />
    </div>
  );
}
