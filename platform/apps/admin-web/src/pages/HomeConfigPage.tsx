import {
  ArrowDownOutlined,
  ArrowUpOutlined,
  DeleteOutlined,
  EditOutlined,
  EyeOutlined,
  PlusOutlined,
  ReloadOutlined,
  SaveOutlined,
} from '@ant-design/icons';
import {
  Button,
  Card,
  Col,
  Form,
  Input,
  InputNumber,
  Modal,
  Row,
  Select,
  Space,
  Switch,
  Table,
  Tabs,
  Tag,
  Typography,
  message,
} from 'antd';
import { useEffect, useMemo, useState } from 'react';
import { Link } from 'react-router-dom';
import { apiGet, apiPatch, apiPut } from '../api';

type Banner = {
  id: string;
  title: string;
  imageUrl: string;
  link: string;
  sort: number;
  enabled: boolean;
};

type QuickEntry = {
  id: string;
  title: string;
  icon: string;
  link: string;
  sort: number;
  enabled: boolean;
};

type FeedConfig = {
  title: string;
  mode: 'latest' | 'category' | 'productIds';
  categoryId: string;
  productIds: string[];
  pageSize: number;
};

type ActivityPopup = {
  id: string;
  title: string;
  description: string;
  imageUrl: string;
  delaySeconds: number;
  maxDailyShows: number;
  link: string;
  buttonText: string;
  startAt?: string;
  endAt?: string;
  prefetchEnabled?: boolean;
};

const defaultFeed: FeedConfig = {
  title: 'Recommended',
  mode: 'latest',
  categoryId: '',
  productIds: [],
  pageSize: 50,
};

const defaultPopup: ActivityPopup = {
  id: 'act_home',
  title: '',
  description: '',
  imageUrl: '',
  delaySeconds: 2,
  maxDailyShows: 3,
  link: '/flash-sale',
  buttonText: 'Shop Now',
};

function moveItem<T>(list: T[], from: number, to: number): T[] {
  if (to < 0 || to >= list.length || from === to) return list;
  const next = [...list];
  const [item] = next.splice(from, 1);
  next.splice(to, 0, item);
  return next.map((row, index) =>
    typeof row === 'object' && row && 'sort' in row
      ? ({ ...row, sort: index } as T)
      : row,
  );
}

export default function HomeConfigPage() {
  const [banners, setBanners] = useState<Banner[]>([]);
  const [entries, setEntries] = useState<QuickEntry[]>([]);
  const [feed, setFeed] = useState<FeedConfig>(defaultFeed);
  const [popup, setPopup] = useState<ActivityPopup>(defaultPopup);
  const [loading, setLoading] = useState(false);
  const [savingKey, setSavingKey] = useState<string | null>(null);
  const [entryModalOpen, setEntryModalOpen] = useState(false);
  const [editingEntry, setEditingEntry] = useState<QuickEntry | null>(null);
  const [preview, setPreview] = useState<Record<string, unknown>>({});
  const [entryForm] = Form.useForm();
  const [feedForm] = Form.useForm();
  const [popupForm] = Form.useForm();

  const load = async () => {
    setLoading(true);
    try {
      const [bannerRows, quick, feedCfg, popupCfg] = await Promise.all([
        apiGet<Banner[]>('/admin/v1/catalog/banners'),
        apiGet<{ items: QuickEntry[] }>('/admin/v1/marketing/home-quick-entries'),
        apiGet<FeedConfig>('/admin/v1/marketing/home-feed-config'),
        apiGet<ActivityPopup>('/admin/v1/marketing/activity-popup'),
      ]);
      setBanners(bannerRows);
      setEntries(
        (quick.items ?? []).slice().sort((a, b) => a.sort - b.sort),
      );
      setFeed({ ...defaultFeed, ...feedCfg });
      feedForm.setFieldsValue({
        ...defaultFeed,
        ...feedCfg,
        productIdsText: (feedCfg.productIds ?? []).join(', '),
      });
      setPopup({ ...defaultPopup, ...popupCfg });
      popupForm.setFieldsValue({ ...defaultPopup, ...popupCfg });
    } catch (e) {
      message.error(e instanceof Error ? e.message : '加载失败');
    } finally {
      setLoading(false);
    }
  };

  const loadPreview = async () => {
    try {
      const [b, q, p, f] = await Promise.all([
        apiGet<unknown>('/v1/banners'),
        apiGet<unknown>('/v1/marketing/home-quick-entries'),
        apiGet<unknown>('/v1/marketing/activity-popup'),
        apiGet<unknown>('/v1/marketing/home-feed-config'),
      ]);
      let products: unknown = null;
      const feedLive = f as FeedConfig;
      if (feedLive?.mode === 'productIds' && feedLive.productIds?.length) {
        products = await apiGet<unknown>(
          `/v1/products/batch?ids=${feedLive.productIds.join(',')}`,
        );
      } else if (feedLive?.mode === 'category' && feedLive.categoryId) {
        products = await apiGet<unknown>('/v1/products', {
          page: 1,
          pageSize: feedLive.pageSize || 50,
          categoryId: feedLive.categoryId,
        });
      } else {
        products = await apiGet<unknown>('/v1/products', {
          page: 1,
          pageSize: feedLive?.pageSize || 50,
        });
      }
      setPreview({
        banners: b,
        homeQuickEntries: q,
        activityPopup: p,
        homeFeedConfig: f,
        products,
      });
      message.success('已刷新 App 接口预览');
    } catch (e) {
      message.error(e instanceof Error ? e.message : '预览拉取失败');
    }
  };

  useEffect(() => {
    void load();
    void loadPreview();
  }, []);

  const saveEntries = async (next = entries) => {
    setSavingKey('entries');
    try {
      const payload = {
        items: next.map((item, index) => ({ ...item, sort: index })),
      };
      await apiPut('/admin/v1/marketing/home-quick-entries', payload);
      setEntries(payload.items);
      message.success('快捷入口已保存');
      await loadPreview();
    } catch (e) {
      message.error(e instanceof Error ? e.message : '保存失败');
    } finally {
      setSavingKey(null);
    }
  };

  const saveFeed = async () => {
    const values = await feedForm.validateFields();
    setSavingKey('feed');
    try {
      const productIds = String(values.productIdsText ?? '')
        .split(/[,\s]+/)
        .map((s: string) => s.trim())
        .filter(Boolean);
      const payload: FeedConfig = {
        title: values.title,
        mode: values.mode,
        categoryId: values.categoryId ?? '',
        productIds,
        pageSize: values.pageSize ?? 50,
      };
      const saved = await apiPut<FeedConfig>(
        '/admin/v1/marketing/home-feed-config',
        { payload },
      );
      setFeed(saved);
      message.success('推荐商品配置已保存');
      await loadPreview();
    } catch (e) {
      message.error(e instanceof Error ? e.message : '保存失败');
    } finally {
      setSavingKey(null);
    }
  };

  const savePopup = async () => {
    const values = await popupForm.validateFields();
    setSavingKey('popup');
    try {
      const payload: ActivityPopup = {
        ...popup,
        ...values,
      };
      const saved = await apiPut<ActivityPopup>(
        '/admin/v1/marketing/activity-popup',
        { payload },
      );
      setPopup(saved);
      message.success('活动弹窗已保存');
      await loadPreview();
    } catch (e) {
      message.error(e instanceof Error ? e.message : '保存失败');
    } finally {
      setSavingKey(null);
    }
  };

  const previewJson = useMemo(
    () => JSON.stringify(preview, null, 2),
    [preview],
  );

  return (
    <div>
      <Space style={{ width: '100%', justifyContent: 'space-between' }} wrap>
        <div>
          <Typography.Title level={3} style={{ margin: 0 }}>
            首页配置
          </Typography.Title>
          <Typography.Paragraph type="secondary" style={{ marginBottom: 0 }}>
            统一配置 Banner、快捷入口、活动弹窗与推荐商品规则；右侧可查看 App
            实际接口返回。
          </Typography.Paragraph>
        </div>
        <Space>
          <Button icon={<ReloadOutlined />} loading={loading} onClick={() => void load()}>
            重新加载
          </Button>
          <Button icon={<EyeOutlined />} onClick={() => void loadPreview()}>
            刷新 App 预览
          </Button>
        </Space>
      </Space>

      <Row gutter={16} style={{ marginTop: 16 }}>
        <Col xs={24} xl={14}>
          <Tabs
            items={[
              {
                key: 'banners',
                label: 'Banner 轮播',
                children: (
                  <Card
                    size="small"
                    title="首页 Banner"
                    extra={<Link to="/banners">完整编辑</Link>}
                  >
                    <Table
                      rowKey="id"
                      size="small"
                      pagination={false}
                      dataSource={banners}
                      columns={[
                        {
                          title: '预览',
                          dataIndex: 'imageUrl',
                          width: 100,
                          render: (url: string) => (
                            <img
                              src={url}
                              alt=""
                              style={{
                                width: 84,
                                height: 36,
                                objectFit: 'cover',
                                borderRadius: 6,
                              }}
                            />
                          ),
                        },
                        { title: '标题', dataIndex: 'title' },
                        { title: '链接', dataIndex: 'link' },
                        { title: '排序', dataIndex: 'sort', width: 70 },
                        {
                          title: '启用',
                          dataIndex: 'enabled',
                          width: 90,
                          render: (enabled: boolean, row) => (
                            <Switch
                              checked={enabled}
                              onChange={async (checked) => {
                                await apiPatch(
                                  `/admin/v1/catalog/banners/${row.id}`,
                                  { enabled: checked },
                                );
                                message.success('已更新');
                                await load();
                                await loadPreview();
                              }}
                            />
                          ),
                        },
                      ]}
                    />
                  </Card>
                ),
              },
              {
                key: 'entries',
                label: '快捷入口',
                children: (
                  <Card
                    size="small"
                    title="快捷入口"
                    extra={
                      <Space>
                        <Button
                          icon={<PlusOutlined />}
                          onClick={() => {
                            setEditingEntry(null);
                            entryForm.resetFields();
                            entryForm.setFieldsValue({
                              id: `home-${Date.now()}`,
                              icon: '🏷️',
                              link: '/',
                              enabled: true,
                            });
                            setEntryModalOpen(true);
                          }}
                        >
                          新增
                        </Button>
                        <Button
                          type="primary"
                          icon={<SaveOutlined />}
                          loading={savingKey === 'entries'}
                          onClick={() => void saveEntries()}
                        >
                          保存入口
                        </Button>
                      </Space>
                    }
                  >
                    <div className="home-quick-preview">
                      {entries
                        .filter((e) => e.enabled)
                        .map((item) => (
                          <div key={item.id} className="home-quick-preview__item">
                            <div className="home-quick-preview__icon">{item.icon}</div>
                            <div>{item.title}</div>
                          </div>
                        ))}
                    </div>
                    <Table
                      style={{ marginTop: 12 }}
                      rowKey="id"
                      size="small"
                      pagination={false}
                      dataSource={entries}
                      columns={[
                        {
                          title: '图标',
                          dataIndex: 'icon',
                          width: 60,
                          render: (v: string) => <span style={{ fontSize: 18 }}>{v}</span>,
                        },
                        { title: '标题', dataIndex: 'title' },
                        { title: 'ID', dataIndex: 'id', width: 140 },
                        { title: '链接', dataIndex: 'link' },
                        {
                          title: '启用',
                          dataIndex: 'enabled',
                          width: 70,
                          render: (v: boolean) =>
                            v ? <Tag color="green">开</Tag> : <Tag>关</Tag>,
                        },
                        {
                          title: '操作',
                          width: 180,
                          render: (_, row, index) => (
                            <Space size={0}>
                              <Button
                                type="text"
                                size="small"
                                icon={<ArrowUpOutlined />}
                                disabled={index === 0}
                                onClick={() =>
                                  setEntries((prev) =>
                                    moveItem(prev, index, index - 1),
                                  )
                                }
                              />
                              <Button
                                type="text"
                                size="small"
                                icon={<ArrowDownOutlined />}
                                disabled={index === entries.length - 1}
                                onClick={() =>
                                  setEntries((prev) =>
                                    moveItem(prev, index, index + 1),
                                  )
                                }
                              />
                              <Button
                                type="text"
                                size="small"
                                icon={<EditOutlined />}
                                onClick={() => {
                                  setEditingEntry(row);
                                  entryForm.setFieldsValue(row);
                                  setEntryModalOpen(true);
                                }}
                              />
                              <Button
                                type="text"
                                size="small"
                                danger
                                icon={<DeleteOutlined />}
                                onClick={() =>
                                  setEntries((prev) =>
                                    prev.filter((item) => item.id !== row.id),
                                  )
                                }
                              />
                            </Space>
                          ),
                        },
                      ]}
                    />
                  </Card>
                ),
              },
              {
                key: 'popup',
                label: '活动弹窗',
                children: (
                  <Card
                    size="small"
                    title="首页活动弹窗"
                    extra={
                      <Button
                        type="primary"
                        icon={<SaveOutlined />}
                        loading={savingKey === 'popup'}
                        onClick={() => void savePopup()}
                      >
                        保存弹窗
                      </Button>
                    }
                  >
                    <Form form={popupForm} layout="vertical">
                      <Row gutter={12}>
                        <Col span={12}>
                          <Form.Item name="id" label="活动 ID" rules={[{ required: true }]}>
                            <Input />
                          </Form.Item>
                        </Col>
                        <Col span={12}>
                          <Form.Item name="title" label="标题" rules={[{ required: true }]}>
                            <Input />
                          </Form.Item>
                        </Col>
                        <Col span={24}>
                          <Form.Item name="description" label="描述">
                            <Input.TextArea rows={3} />
                          </Form.Item>
                        </Col>
                        <Col span={24}>
                          <Form.Item
                            name="imageUrl"
                            label="图片 URL"
                            rules={[{ required: true }]}
                          >
                            <Input />
                          </Form.Item>
                        </Col>
                        <Col span={12}>
                          <Form.Item name="link" label="跳转链接" rules={[{ required: true }]}>
                            <Input placeholder="/flash-sale" />
                          </Form.Item>
                        </Col>
                        <Col span={12}>
                          <Form.Item
                            name="buttonText"
                            label="按钮文案"
                            rules={[{ required: true }]}
                          >
                            <Input />
                          </Form.Item>
                        </Col>
                        <Col span={8}>
                          <Form.Item name="delaySeconds" label="延迟秒数">
                            <InputNumber style={{ width: '100%' }} min={0} />
                          </Form.Item>
                        </Col>
                        <Col span={8}>
                          <Form.Item name="maxDailyShows" label="每日最多展示">
                            <InputNumber style={{ width: '100%' }} min={1} />
                          </Form.Item>
                        </Col>
                        <Col span={8}>
                          <Form.Item
                            name="prefetchEnabled"
                            label="预取图片"
                            valuePropName="checked"
                          >
                            <Switch />
                          </Form.Item>
                        </Col>
                        <Col span={12}>
                          <Form.Item name="startAt" label="开始时间 ISO">
                            <Input placeholder="2026-07-01T00:00:00Z" />
                          </Form.Item>
                        </Col>
                        <Col span={12}>
                          <Form.Item name="endAt" label="结束时间 ISO">
                            <Input placeholder="2026-08-01T00:00:00Z" />
                          </Form.Item>
                        </Col>
                      </Row>
                    </Form>
                    {popup.imageUrl ? (
                      <img
                        src={popupForm.getFieldValue('imageUrl') || popup.imageUrl}
                        alt=""
                        style={{
                          width: 180,
                          borderRadius: 12,
                          marginTop: 8,
                          objectFit: 'cover',
                        }}
                      />
                    ) : null}
                  </Card>
                ),
              },
              {
                key: 'feed',
                label: '推荐商品',
                children: (
                  <Card
                    size="small"
                    title="推荐商品规则"
                    extra={
                      <Button
                        type="primary"
                        icon={<SaveOutlined />}
                        loading={savingKey === 'feed'}
                        onClick={() => void saveFeed()}
                      >
                        保存规则
                      </Button>
                    }
                  >
                    <Form form={feedForm} layout="vertical" initialValues={feed}>
                      <Form.Item
                        name="title"
                        label="推荐区标题"
                        rules={[{ required: true }]}
                      >
                        <Input placeholder="Recommended" />
                      </Form.Item>
                      <Form.Item name="mode" label="取数方式" rules={[{ required: true }]}>
                        <Select
                          options={[
                            { value: 'latest', label: '默认最新商品' },
                            { value: 'category', label: '指定分类 categoryId' },
                            { value: 'productIds', label: '手动商品 ID 列表' },
                          ]}
                        />
                      </Form.Item>
                      <Form.Item name="categoryId" label="分类 ID（mode=category）">
                        <Input placeholder="例如 c1-g1-l1" />
                      </Form.Item>
                      <Form.Item
                        name="productIdsText"
                        label="商品 ID（逗号分隔，mode=productIds）"
                      >
                        <Input.TextArea rows={3} placeholder="c1-g1-l1-p1, c1-g1-l1-p2" />
                      </Form.Item>
                      <Form.Item name="pageSize" label="数量">
                        <InputNumber min={1} max={100} style={{ width: '100%' }} />
                      </Form.Item>
                    </Form>
                    <Typography.Text type="secondary">
                      商品主数据仍在「Products」维护；这里只配置首页如何取货。
                    </Typography.Text>
                  </Card>
                ),
              },
            ]}
          />
        </Col>

        <Col xs={24} xl={10}>
          <Card
            title="App 返回预览"
            extra={
              <Typography.Text type="secondary" style={{ fontSize: 12 }}>
                /banners · quick-entries · popup · feed · products
              </Typography.Text>
            }
          >
            <div className="home-phone">
              <div className="home-phone__frame">
                <div className="home-phone__banner">
                  {banners.find((b) => b.enabled)?.title || 'Banner'}
                </div>
                <div className="home-quick-preview home-quick-preview--compact">
                  {entries
                    .filter((e) => e.enabled)
                    .slice(0, 8)
                    .map((item) => (
                      <div key={item.id} className="home-quick-preview__item">
                        <div className="home-quick-preview__icon">{item.icon}</div>
                        <div>{item.title}</div>
                      </div>
                    ))}
                </div>
                <div className="home-phone__feed-title">{feed.title}</div>
                <div className="home-phone__feed-grid">
                  {Array.from({ length: 4 }).map((_, i) => (
                    <div key={i} className="home-phone__feed-card" />
                  ))}
                </div>
              </div>
            </div>
            <pre className="category-json" style={{ marginTop: 12 }}>
              {previewJson}
            </pre>
          </Card>
        </Col>
      </Row>

      <Modal
        title={editingEntry ? '编辑快捷入口' : '新增快捷入口'}
        open={entryModalOpen}
        onCancel={() => setEntryModalOpen(false)}
        onOk={() => entryForm.submit()}
        destroyOnClose
      >
        <Form
          form={entryForm}
          layout="vertical"
          onFinish={(values) => {
            const nextItem: QuickEntry = {
              id: values.id,
              title: values.title,
              icon: values.icon || '🏷️',
              link: values.link,
              sort: editingEntry?.sort ?? entries.length,
              enabled: values.enabled !== false,
            };
            setEntries((prev) => {
              if (editingEntry) {
                return prev.map((item) =>
                  item.id === editingEntry.id ? nextItem : item,
                );
              }
              return [...prev, nextItem];
            });
            setEntryModalOpen(false);
          }}
        >
          <Form.Item name="id" label="ID" rules={[{ required: true }]}>
            <Input disabled={Boolean(editingEntry)} />
          </Form.Item>
          <Form.Item name="title" label="标题" rules={[{ required: true }]}>
            <Input />
          </Form.Item>
          <Form.Item name="icon" label="图标 Emoji">
            <Input placeholder="⚡" />
          </Form.Item>
          <Form.Item name="link" label="跳转链接" rules={[{ required: true }]}>
            <Input placeholder="/flash-sale?activityId=activity_flash_001" />
          </Form.Item>
          <Form.Item name="enabled" label="启用" valuePropName="checked">
            <Switch />
          </Form.Item>
        </Form>
      </Modal>
    </div>
  );
}
