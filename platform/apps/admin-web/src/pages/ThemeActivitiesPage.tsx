import {
  CopyOutlined,
  DeleteOutlined,
  EyeOutlined,
  PlusOutlined,
  ReloadOutlined,
  SaveOutlined,
  CheckCircleOutlined,
} from '@ant-design/icons';
import {
  Alert,
  Button,
  Card,
  Col,
  Form,
  Input,
  Modal,
  Row,
  Select,
  Space,
  Table,
  Tag,
  Tabs,
  Typography,
  message,
} from 'antd';
import { useCallback, useEffect, useMemo, useState } from 'react';
import { apiDelete, apiGet, apiPost, apiPut } from '../api';
import ThemeActivityVisualPreview from '../components/ThemeActivityVisualPreview';

type ThemeListItem = {
  activityId: string;
  title: string;
  status: string;
  startAt: string | null;
  endAt: string | null;
  expiredBehavior: string;
  updatedAt: string;
  moduleCount: number;
  hasFooter: boolean;
};

type ThemeDetail = {
  activityId: string;
  title: string;
  status: string;
  startAt: string | null;
  endAt: string | null;
  expiredBehavior: string;
  config: Record<string, unknown>;
  deepLink: string;
  appPreviewPath: string;
  validation?: {
    ok: boolean;
    errors: Array<{ level: string; path: string; message: string }>;
    warnings: Array<{ level: string; path: string; message: string }>;
  };
};

type ValidationResult = {
  ok: boolean;
  errors: Array<{ level: string; path: string; message: string }>;
  warnings: Array<{ level: string; path: string; message: string }>;
};

type PreviewResponse = {
  preview: Record<string, unknown>;
  validation: ValidationResult;
  appApiAvailable: boolean;
  deepLink: string;
  appPreviewPath: string;
  note: string | null;
};

const TEMPLATES: Array<{ label: string; activityId: string }> = [
  { label: '长图大促 (bannerStack + marquee)', activityId: 'demo_long_banner' },
  {
    label: '券+倒计时 (coupon + countdown + grid)',
    activityId: 'demo_coupon_rush',
  },
  {
    label: '九宫格+瀑布流 (grid + uneven + scroll)',
    activityId: 'demo_nine_waterfall',
  },
  {
    label: '全模块展示 (10 模块 + 分色背景)',
    activityId: 'demo_all_modules',
  },
];

const blankConfig = (): Record<string, unknown> => ({
  activityId: '',
  title: '',
  status: 'draft',
  expiredBehavior: 'browse',
  navBar: {
    style: 'solid',
    backgroundColor: '#FFFFFF',
    titleColor: '#222222',
    iconColor: '#222222',
    showShare: false,
    immersive: false,
  },
  pageBackground: { color: '#FFFFFF' },
  defaultStyle: {
    borderRadius: 12,
    titleColor: '#222222',
    priceColor: '#E53935',
  },
  modules: [],
  footer: null,
});

const statusColor: Record<string, string> = {
  draft: 'default',
  online: 'success',
  offline: 'warning',
};

function toLocalInput(iso: string | null | undefined): string {
  if (!iso) return '';
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return '';
  const pad = (n: number) => String(n).padStart(2, '0');
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}T${pad(d.getHours())}:${pad(d.getMinutes())}`;
}

function fromLocalInput(value: string | undefined | null): string | null {
  if (!value) return null;
  const d = new Date(value);
  return Number.isNaN(d.getTime()) ? null : d.toISOString();
}

function formatTime(iso: string): string {
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return iso;
  const pad = (n: number) => String(n).padStart(2, '0');
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}`;
}

export default function ThemeActivitiesPage() {
  const [rows, setRows] = useState<ThemeListItem[]>([]);
  const [loading, setLoading] = useState(false);
  const [open, setOpen] = useState(false);
  const [creating, setCreating] = useState(false);
  const [saving, setSaving] = useState(false);
  const [jsonText, setJsonText] = useState('');
  const [jsonError, setJsonError] = useState<string | null>(null);
  const [validation, setValidation] = useState<ValidationResult | null>(null);
  const [previewResult, setPreviewResult] = useState<PreviewResponse | null>(null);
  const [previewLoading, setPreviewLoading] = useState(false);
  const [visualConfig, setVisualConfig] = useState<Record<string, unknown> | null>(
    null,
  );
  const [rightTab, setRightTab] = useState('visual');
  const [form] = Form.useForm();

  const watchedId = Form.useWatch('activityId', form);
  const watchedStatus = Form.useWatch('status', form);
  const watchedTitle = Form.useWatch('title', form);

  const previewLink = useMemo(() => {
    const id = String(watchedId ?? '').trim();
    return id ? `https://shoo.app/theme-activity/${id}` : '';
  }, [watchedId]);

  const parseConfig = (): Record<string, unknown> | null => {
    try {
      const parsed = JSON.parse(jsonText) as unknown;
      if (!parsed || typeof parsed !== 'object' || Array.isArray(parsed)) {
        setJsonError('配置必须是 JSON 对象');
        return null;
      }
      setJsonError(null);
      return parsed as Record<string, unknown>;
    } catch (e) {
      setJsonError(e instanceof Error ? e.message : 'JSON 解析失败');
      return null;
    }
  };

  const syncMetaIntoJson = (config: Record<string, unknown>) => {
    const values = form.getFieldsValue();
    const next = { ...config };
    if (values.activityId) next.activityId = values.activityId;
    if (values.title != null) next.title = values.title;
    if (values.status) next.status = values.status;
    if (values.expiredBehavior) next.expiredBehavior = values.expiredBehavior;
    next.startAt = fromLocalInput(values.startAt);
    next.endAt = fromLocalInput(values.endAt);
    return next;
  };

  const refreshLocalVisual = useCallback(() => {
    const parsed = parseConfig();
    if (!parsed) {
      setVisualConfig(null);
      return null;
    }
    const config = syncMetaIntoJson(parsed);
    setVisualConfig(config);
    return config;
  }, [jsonText, watchedId, watchedStatus, watchedTitle, form]);

  useEffect(() => {
    if (!open) return;
    const timer = window.setTimeout(() => {
      refreshLocalVisual();
    }, 280);
    return () => window.clearTimeout(timer);
  }, [open, jsonText, refreshLocalVisual]);

  const load = async () => {
    setLoading(true);
    try {
      const data = await apiGet<ThemeListItem[]>(
        '/admin/v1/marketing/theme-activities',
      );
      setRows(data);
    } catch (e) {
      message.error(e instanceof Error ? e.message : '加载失败');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    void load();
  }, []);

  const openCreate = () => {
    setCreating(true);
    setValidation(null);
    setPreviewResult(null);
    setVisualConfig(null);
    setJsonError(null);
    setRightTab('visual');
    const cfg = blankConfig();
    form.setFieldsValue({
      activityId: '',
      title: '',
      status: 'draft',
      expiredBehavior: 'browse',
      startAt: '',
      endAt: '',
    });
    setJsonText(JSON.stringify(cfg, null, 2));
    setOpen(true);
  };

  const openEdit = async (activityId: string) => {
    setCreating(false);
    setValidation(null);
    setPreviewResult(null);
    setJsonError(null);
    setRightTab('visual');
    try {
      const detail = await apiGet<ThemeDetail>(
        `/admin/v1/marketing/theme-activities/${activityId}`,
      );
      form.setFieldsValue({
        activityId: detail.activityId,
        title: detail.title,
        status: detail.status,
        expiredBehavior: detail.expiredBehavior,
        startAt: toLocalInput(detail.startAt),
        endAt: toLocalInput(detail.endAt),
      });
      setJsonText(JSON.stringify(detail.config, null, 2));
      setOpen(true);
      void loadAppPreview();
    } catch (e) {
      message.error(e instanceof Error ? e.message : '加载详情失败');
    }
  };

  const runValidate = async () => {
    const parsed = parseConfig();
    if (!parsed) return;
    const config = syncMetaIntoJson(parsed);
    try {
      const result = await apiPost<ValidationResult>(
        '/admin/v1/marketing/theme-activities/validate',
        { config },
      );
      setValidation(result);
      if (result.ok) {
        message.success(
          result.warnings.length
            ? `校验通过（${result.warnings.length} 条警告）`
            : '校验通过',
        );
      } else {
        message.error(`校验失败：${result.errors.length} 个错误`);
      }
      setJsonText(JSON.stringify(config, null, 2));
    } catch (e) {
      message.error(e instanceof Error ? e.message : '校验失败');
    }
  };

  const loadAppPreview = async () => {
    const parsed = parseConfig();
    if (!parsed) return;
    const config = syncMetaIntoJson(parsed);
    const values = form.getFieldsValue();
    setPreviewLoading(true);
    try {
      const result = await apiPost<PreviewResponse>(
        '/admin/v1/marketing/theme-activities/preview',
        {
          activityId: values.activityId,
          title: values.title,
          status: values.status,
          expiredBehavior: values.expiredBehavior,
          startAt: fromLocalInput(values.startAt),
          endAt: fromLocalInput(values.endAt),
          config,
        },
      );
      setPreviewResult(result);
      setValidation(result.validation);
      setVisualConfig(result.preview);
      setRightTab('visual');
      if (result.note) {
        message.info(result.note);
      }
    } catch (e) {
      message.error(e instanceof Error ? e.message : '预览失败');
    } finally {
      setPreviewLoading(false);
    }
  };

  const loadTemplate = async (activityId: string) => {
    try {
      const detail = await apiGet<ThemeDetail>(
        `/admin/v1/marketing/theme-activities/${activityId}`,
      );
      const cloneId = creating
        ? `${activityId}_copy_${Date.now().toString(36).slice(-4)}`
        : form.getFieldValue('activityId') || activityId;
      const config = {
        ...detail.config,
        activityId: cloneId,
        title: creating ? `${detail.title}（副本）` : detail.title,
        status: creating ? 'draft' : detail.status,
      };
      form.setFieldsValue({
        activityId: cloneId,
        title: config.title,
        status: config.status,
        expiredBehavior: detail.expiredBehavior,
        startAt: toLocalInput(detail.startAt),
        endAt: toLocalInput(detail.endAt),
      });
      setJsonText(JSON.stringify(config, null, 2));
      message.success(`已载入模板 ${activityId}`);
    } catch (e) {
      message.error(
        e instanceof Error
          ? e.message
          : '载入模板失败（请先 seed 演示数据）',
      );
    }
  };

  const save = async () => {
    const values = await form.validateFields();
    const parsed = parseConfig();
    if (!parsed) return;
    const config = syncMetaIntoJson(parsed);
    setSaving(true);
    try {
      const body = {
        activityId: values.activityId,
        title: values.title,
        status: values.status,
        expiredBehavior: values.expiredBehavior,
        startAt: fromLocalInput(values.startAt),
        endAt: fromLocalInput(values.endAt),
        config,
      };
      let saved: ThemeDetail;
      if (creating) {
        saved = await apiPost<ThemeDetail>(
          '/admin/v1/marketing/theme-activities',
          body,
        );
        message.success('已创建');
      } else {
        saved = await apiPut<ThemeDetail>(
          `/admin/v1/marketing/theme-activities/${values.activityId}`,
          body,
        );
        message.success('已保存');
      }
      if (saved.validation) setValidation(saved.validation);
      setCreating(false);
      setJsonText(JSON.stringify(saved.config, null, 2));
      await load();
      await loadAppPreview();
    } catch (e) {
      message.error(e instanceof Error ? e.message : '保存失败');
    } finally {
      setSaving(false);
    }
  };

  return (
    <div>
      <Space style={{ width: '100%', justifyContent: 'space-between' }}>
        <div>
          <Typography.Title level={3} style={{ margin: 0 }}>
            主题活动 ThemeActivity
          </Typography.Title>
          <Typography.Text type="secondary">
            配置驱动 Native 活动页 · Deep Link 统一跳转 · footer 最多 1 个商品区
          </Typography.Text>
        </div>
        <Space>
          <Button icon={<ReloadOutlined />} onClick={() => void load()}>
            刷新
          </Button>
          <Button type="primary" icon={<PlusOutlined />} onClick={openCreate}>
            新建活动
          </Button>
        </Space>
      </Space>

      <Alert
        style={{ marginTop: 16 }}
        type="info"
        showIcon
        message="跳转约定"
        description="所有打开新页面的配置只写 link（App Link / Deep Link / in-app path），禁止 action.type=product|route|…。App 入口：GET /api/v1/theme-activities/{activityId}"
      />

      <Table
        style={{ marginTop: 16 }}
        rowKey="activityId"
        loading={loading}
        dataSource={rows}
        columns={[
          { title: 'activityId', dataIndex: 'activityId', width: 200 },
          { title: '标题', dataIndex: 'title' },
          {
            title: '状态',
            dataIndex: 'status',
            width: 100,
            render: (s: string) => (
              <Tag color={statusColor[s] ?? 'default'}>{s}</Tag>
            ),
          },
          { title: '模块', dataIndex: 'moduleCount', width: 80 },
          {
            title: 'Footer',
            dataIndex: 'hasFooter',
            width: 80,
            render: (v: boolean) => (v ? '有' : '—'),
          },
          {
            title: '更新时间',
            dataIndex: 'updatedAt',
            width: 180,
            render: (v: string) => formatTime(v),
          },
          {
            title: '操作',
            width: 200,
            render: (_, row) => (
              <Space>
                <Button
                  size="small"
                  onClick={() => void openEdit(row.activityId)}
                >
                  编辑
                </Button>
                <Button
                  size="small"
                  danger
                  icon={<DeleteOutlined />}
                  onClick={() => {
                    Modal.confirm({
                      title: `删除 ${row.activityId}？`,
                      onOk: async () => {
                        await apiDelete(
                          `/admin/v1/marketing/theme-activities/${row.activityId}`,
                        );
                        message.success('已删除');
                        await load();
                      },
                    });
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
        title={creating ? '新建主题活动' : '编辑主题活动'}
        open={open}
        onCancel={() => setOpen(false)}
        width={1200}
        destroyOnClose
        footer={
          <Space>
            <Button onClick={() => setOpen(false)}>取消</Button>
            <Button
              icon={<CheckCircleOutlined />}
              onClick={() => void runValidate()}
            >
              校验配置
            </Button>
            <Button
              icon={<EyeOutlined />}
              loading={previewLoading}
              onClick={() => void loadAppPreview()}
            >
              刷新预览
            </Button>
            <Button
              type="primary"
              icon={<SaveOutlined />}
              loading={saving}
              onClick={() => void save()}
            >
              保存
            </Button>
          </Space>
        }
      >
        <Row gutter={16}>
          <Col span={10}>
            <Form form={form} layout="vertical">
              <Form.Item
                name="activityId"
                label="activityId"
                rules={[{ required: true, message: '必填' }]}
                extra={
                  previewLink ? (
                    <Typography.Text
                      copyable={{ text: previewLink }}
                      type="secondary"
                    >
                      {previewLink}
                    </Typography.Text>
                  ) : null
                }
              >
                <Input disabled={!creating} placeholder="theme_spring_2026" />
              </Form.Item>
              <Form.Item
                name="title"
                label="标题"
                rules={[{ required: true, message: '必填' }]}
              >
                <Input />
              </Form.Item>
              <Form.Item name="status" label="状态" initialValue="draft">
                <Select
                  options={[
                    { value: 'draft', label: 'draft 草稿' },
                    { value: 'online', label: 'online 上线' },
                    { value: 'offline', label: 'offline 下线' },
                  ]}
                />
              </Form.Item>
              <Form.Item
                name="expiredBehavior"
                label="过期行为"
                initialValue="browse"
              >
                <Select
                  options={[
                    { value: 'browse', label: 'browse 仍可浏览' },
                    { value: 'block', label: 'block 拦截' },
                  ]}
                />
              </Form.Item>
              <Form.Item name="startAt" label="开始时间">
                <Input type="datetime-local" />
              </Form.Item>
              <Form.Item name="endAt" label="结束时间">
                <Input type="datetime-local" />
              </Form.Item>
              <Form.Item label="从演示模板载入">
                <Select
                  placeholder="选择模板…"
                  options={TEMPLATES.map((t) => ({
                    value: t.activityId,
                    label: t.label,
                  }))}
                  onChange={(id) => void loadTemplate(id)}
                  allowClear
                />
              </Form.Item>
            </Form>

            {previewResult?.note ? (
              <Alert
                type="warning"
                showIcon
                message={previewResult.note}
                style={{ marginBottom: 12 }}
              />
            ) : null}

            {validation && (
              <Card size="small" title="校验结果" style={{ marginBottom: 12 }}>
                <Tag color={validation.ok ? 'success' : 'error'}>
                  {validation.ok ? '通过' : '失败'}
                </Tag>
                {validation.errors.map((e, i) => (
                  <div key={`e-${i}`}>
                    <Typography.Text type="danger">
                      [{e.path}] {e.message}
                    </Typography.Text>
                  </div>
                ))}
                {validation.warnings.map((w, i) => (
                  <div key={`w-${i}`}>
                    <Typography.Text type="warning">
                      [{w.path}] {w.message}
                    </Typography.Text>
                  </div>
                ))}
              </Card>
            )}
          </Col>

          <Col span={14}>
            <Tabs
              activeKey={rightTab}
              onChange={setRightTab}
              items={[
                {
                  key: 'visual',
                  label: '可视化预览',
                  children: (
                    <div>
                      <Typography.Paragraph
                        type="secondary"
                        style={{ marginBottom: 12 }}
                      >
                        左侧编辑 JSON 后自动更新；点击「刷新预览」可拉取带 _access
                        的服务端预览（草稿也可看）。
                      </Typography.Paragraph>
                      <ThemeActivityVisualPreview
                        config={previewResult?.preview ?? visualConfig}
                      />
                      {previewResult ? (
                        <div style={{ marginTop: 12 }}>
                          <Space wrap>
                            <Tag color={previewResult.appApiAvailable ? 'success' : 'default'}>
                              App 接口
                              {previewResult.appApiAvailable ? ' 可用' : ' 不可用'}
                            </Tag>
                            <Typography.Text
                              copyable={{ text: previewResult.deepLink }}
                              type="secondary"
                              style={{ fontSize: 12 }}
                            >
                              {previewResult.deepLink}
                            </Typography.Text>
                          </Space>
                        </div>
                      ) : null}
                    </div>
                  ),
                },
                {
                  key: 'json',
                  label: 'JSON 编辑',
                  children: (
                    <div>
                      <Typography.Paragraph
                        type="secondary"
                        style={{ marginBottom: 8 }}
                      >
                        modules[] + footer；点击项一律使用 link 字段
                      </Typography.Paragraph>
                      {jsonError && (
                        <Alert
                          type="error"
                          message={jsonError}
                          style={{ marginBottom: 8 }}
                        />
                      )}
                      <Input.TextArea
                        value={jsonText}
                        onChange={(e) => setJsonText(e.target.value)}
                        autoSize={{ minRows: 24, maxRows: 32 }}
                        style={{
                          fontFamily:
                            'ui-monospace, SFMono-Regular, Menlo, monospace',
                          fontSize: 12,
                        }}
                      />
                    </div>
                  ),
                },
                {
                  key: 'api',
                  label: 'App 接口 JSON',
                  children: previewResult ? (
                    <Card
                      size="small"
                      extra={
                        <Button
                          size="small"
                          icon={<CopyOutlined />}
                          onClick={() => {
                            void navigator.clipboard.writeText(
                              JSON.stringify(previewResult.preview, null, 2),
                            );
                            message.success('已复制');
                          }}
                        >
                          复制
                        </Button>
                      }
                    >
                      <pre
                        className="category-json"
                        style={{
                          maxHeight: 520,
                          overflow: 'auto',
                          fontSize: 11,
                          margin: 0,
                        }}
                      >
                        {JSON.stringify(previewResult.preview, null, 2)}
                      </pre>
                    </Card>
                  ) : (
                    <Typography.Text type="secondary">
                      点击「刷新预览」生成 App 将收到的配置 JSON
                    </Typography.Text>
                  ),
                },
              ]}
            />
          </Col>
        </Row>
      </Modal>
    </div>
  );
}
