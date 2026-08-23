import { Button, Card, Input, Space, Typography, message } from 'antd';
import { useEffect, useState } from 'react';
import { apiGet, apiPut } from '../api';

export default function FlashSalePage() {
  const [jsonText, setJsonText] = useState('{}');
  const [loading, setLoading] = useState(false);

  const load = async () => {
    setLoading(true);
    try {
      const data = await apiGet<Record<string, unknown>>(
        '/admin/v1/marketing/flash-sale-catalog',
      );
      setJsonText(JSON.stringify(data ?? {}, null, 2));
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    void load();
  }, []);

  return (
    <div>
      <Space style={{ width: '100%', justifyContent: 'space-between' }}>
        <Typography.Title level={3} style={{ margin: 0 }}>
          闪购配置
        </Typography.Title>
        <Space>
          <Button onClick={() => void load()} loading={loading}>
            重新加载
          </Button>
          <Button
            type="primary"
            loading={loading}
            onClick={async () => {
              try {
                const payload = JSON.parse(jsonText) as unknown;
                await apiPut('/admin/v1/marketing/flash-sale-catalog', payload);
                message.success('闪购配置已保存');
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
      </Space>
      <Card style={{ marginTop: 16 }}>
        <Typography.Paragraph type="secondary">
          编辑 <code>flash_sale_catalog</code> 文档，包含场次模板、优惠券、商品等。
          App 端 <code>GET /flash-sale/*</code> 接口读取此配置。
        </Typography.Paragraph>
        <Input.TextArea
          value={jsonText}
          onChange={(e) => setJsonText(e.target.value)}
          rows={28}
          style={{ fontFamily: 'monospace' }}
        />
      </Card>
    </div>
  );
}
