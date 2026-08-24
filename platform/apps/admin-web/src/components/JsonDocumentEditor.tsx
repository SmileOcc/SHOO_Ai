import type { ReactNode } from 'react';
import { Button, Card, Input, Space, Typography } from 'antd';

type JsonDocumentEditorProps = {
  title: string;
  description?: ReactNode;
  jsonText: string;
  loading?: boolean;
  rows?: number;
  onChange: (value: string) => void;
  onReload: () => void;
  onSave: () => void;
};

export default function JsonDocumentEditor({
  title,
  description,
  jsonText,
  loading = false,
  rows = 28,
  onChange,
  onReload,
  onSave,
}: JsonDocumentEditorProps) {
  return (
    <div>
      <Space style={{ width: '100%', justifyContent: 'space-between' }}>
        <Typography.Title level={3} style={{ margin: 0 }}>
          {title}
        </Typography.Title>
        <Space>
          <Button onClick={onReload} loading={loading}>
            重新加载
          </Button>
          <Button type="primary" loading={loading} onClick={onSave}>
            保存
          </Button>
        </Space>
      </Space>
      <Card style={{ marginTop: 16 }}>
        {description ? (
          <Typography.Paragraph type="secondary">
            {description}
          </Typography.Paragraph>
        ) : null}
        <Input.TextArea
          value={jsonText}
          onChange={(e) => onChange(e.target.value)}
          rows={rows}
          style={{ fontFamily: 'monospace' }}
        />
      </Card>
    </div>
  );
}
