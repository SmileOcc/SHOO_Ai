import { Button, Card, Input, Space, Tag, Typography, message } from 'antd';
import { PlusOutlined } from '@ant-design/icons';
import { useEffect, useState } from 'react';
import { apiGet, apiPut } from '../api';

export default function SearchHotPage() {
  const [keywords, setKeywords] = useState<string[]>([]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);

  const load = async () => {
    setLoading(true);
    try {
      const data = await apiGet<{ keywords?: string[] }>(
        '/admin/v1/catalog/search-hot',
      );
      setKeywords(Array.isArray(data?.keywords) ? data.keywords : []);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    void load();
  }, []);

  const save = async (next: string[]) => {
    await apiPut('/admin/v1/catalog/search-hot', { keywords: next });
    setKeywords(next);
    message.success('搜索热词已保存');
  };

  return (
    <div>
      <Space style={{ width: '100%', justifyContent: 'space-between' }}>
        <Typography.Title level={3} style={{ margin: 0 }}>
          搜索热词
        </Typography.Title>
        <Button onClick={() => void load()} loading={loading}>
          重新加载
        </Button>
      </Space>
      <Card style={{ marginTop: 16 }}>
        <Typography.Paragraph type="secondary">
          App 端 <code>GET /search/hot</code> 读取此配置，展示在搜索页热门关键词区域。
        </Typography.Paragraph>
        <Space wrap style={{ marginBottom: 16 }}>
          {keywords.map((word) => (
            <Tag
              key={word}
              closable
              onClose={() => {
                void save(keywords.filter((k) => k !== word));
              }}
            >
              {word}
            </Tag>
          ))}
        </Space>
        <Space.Compact style={{ width: '100%' }}>
          <Input
            placeholder="输入热词后回车或点击添加"
            value={input}
            onChange={(e) => setInput(e.target.value)}
            onPressEnter={() => {
              const word = input.trim();
              if (!word || keywords.includes(word)) return;
              void save([...keywords, word]);
              setInput('');
            }}
          />
          <Button
            type="primary"
            icon={<PlusOutlined />}
            onClick={() => {
              const word = input.trim();
              if (!word || keywords.includes(word)) return;
              void save([...keywords, word]);
              setInput('');
            }}
          >
            添加
          </Button>
        </Space.Compact>
      </Card>
    </div>
  );
}
