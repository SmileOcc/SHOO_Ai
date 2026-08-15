import {
  ArrowDownOutlined,
  ArrowUpOutlined,
  DeleteOutlined,
  EditOutlined,
  PlusOutlined,
  ReloadOutlined,
  SaveOutlined,
  EyeOutlined,
} from '@ant-design/icons';
import {
  Button,
  Card,
  Col,
  Empty,
  Form,
  Input,
  Modal,
  Row,
  Space,
  Tabs,
  Tag,
  Typography,
  message,
} from 'antd';
import { useEffect, useMemo, useState, type ReactNode } from 'react';
import { apiGet, apiPut } from '../api';

type CategoryLeaf = {
  id: string;
  name: string;
  icon?: string;
};

type CategoryGroup = {
  id: string;
  name: string;
  children: CategoryLeaf[];
};

type CategoryRoot = {
  id: string;
  name: string;
  icon: string;
  groups: CategoryGroup[];
};

const ICON_PRESETS = ['👗', '👔', '🧒', '🏠', '👟', '💄', '⌚', '🎒', '🏷️'];

function cloneTree(tree: CategoryRoot[]): CategoryRoot[] {
  return JSON.parse(JSON.stringify(tree)) as CategoryRoot[];
}

function normalizeTree(raw: unknown): CategoryRoot[] {
  if (!Array.isArray(raw)) return [];
  return raw.map((item, index) => {
    const row = (item ?? {}) as Record<string, unknown>;
    const groups = Array.isArray(row.groups) ? row.groups : [];
    return {
      id: String(row.id ?? `c${index + 1}`),
      name: String(row.name ?? `Category ${index + 1}`),
      icon: String(row.icon ?? '🏷️'),
      groups: groups.map((g, gi) => {
        const group = (g ?? {}) as Record<string, unknown>;
        const children = Array.isArray(group.children) ? group.children : [];
        return {
          id: String(group.id ?? `g${gi + 1}`),
          name: String(group.name ?? `Group ${gi + 1}`),
          children: children.map((c, ci) => {
            const leaf = (c ?? {}) as Record<string, unknown>;
            return {
              id: String(leaf.id ?? `l${ci + 1}`),
              name: String(leaf.name ?? `Leaf ${ci + 1}`),
              icon: leaf.icon != null ? String(leaf.icon) : '',
            };
          }),
        };
      }),
    };
  });
}

function moveItem<T>(list: T[], from: number, to: number): T[] {
  if (to < 0 || to >= list.length || from === to) return list;
  const next = [...list];
  const [item] = next.splice(from, 1);
  next.splice(to, 0, item);
  return next;
}

function nextRootId(tree: CategoryRoot[]): string {
  let max = 0;
  for (const item of tree) {
    const m = /^c(\d+)$/.exec(item.id);
    if (m) max = Math.max(max, Number(m[1]));
  }
  return `c${max + 1}`;
}

function nextGroupId(root: CategoryRoot): string {
  let max = 0;
  for (const group of root.groups) {
    const m = new RegExp(`^${root.id}-g(\\d+)$`).exec(group.id);
    if (m) max = Math.max(max, Number(m[1]));
  }
  return `${root.id}-g${max + 1}`;
}

function nextLeafId(group: CategoryGroup): string {
  let max = 0;
  for (const leaf of group.children) {
    const m = new RegExp(`^${group.id}-l(\\d+)$`).exec(leaf.id);
    if (m) max = Math.max(max, Number(m[1]));
  }
  return `${group.id}-l${max + 1}`;
}

type EditorTarget =
  | { level: 'root'; index: number }
  | { level: 'group'; rootIndex: number; index: number }
  | { level: 'leaf'; rootIndex: number; groupIndex: number; index: number };

export default function CategoriesPage() {
  const [tree, setTree] = useState<CategoryRoot[]>([]);
  const [savedSnapshot, setSavedSnapshot] = useState('[]');
  const [loading, setLoading] = useState(false);
  const [saving, setSaving] = useState(false);
  const [selectedRoot, setSelectedRoot] = useState(0);
  const [selectedGroup, setSelectedGroup] = useState(0);
  const [editorOpen, setEditorOpen] = useState(false);
  const [editorTarget, setEditorTarget] = useState<EditorTarget | null>(null);
  const [liveAppData, setLiveAppData] = useState<unknown>(null);
  const [form] = Form.useForm();

  const dirty = useMemo(
    () => JSON.stringify(tree) !== savedSnapshot,
    [tree, savedSnapshot],
  );

  const root = tree[selectedRoot];
  const group = root?.groups[selectedGroup];

  const load = async () => {
    setLoading(true);
    try {
      const data = await apiGet<unknown>('/admin/v1/catalog/categories');
      const normalized = normalizeTree(data);
      setTree(normalized);
      setSavedSnapshot(JSON.stringify(normalized));
      setSelectedRoot(0);
      setSelectedGroup(0);
    } catch (e) {
      message.error(e instanceof Error ? e.message : '加载失败');
    } finally {
      setLoading(false);
    }
  };

  const loadLiveAppResponse = async () => {
    try {
      const data = await apiGet<unknown>('/v1/categories');
      setLiveAppData(data);
      message.success('已拉取 App 接口返回');
    } catch (e) {
      message.error(e instanceof Error ? e.message : '拉取失败');
    }
  };

  useEffect(() => {
    void load();
    void loadLiveAppResponse();
  }, []);

  useEffect(() => {
    if (!root) {
      setSelectedRoot(0);
      setSelectedGroup(0);
      return;
    }
    if (selectedGroup >= root.groups.length) {
      setSelectedGroup(Math.max(0, root.groups.length - 1));
    }
  }, [root, selectedGroup]);

  const openCreate = (level: EditorTarget['level']) => {
    if (level === 'root') {
      setEditorTarget({ level: 'root', index: -1 });
      form.setFieldsValue({
        id: nextRootId(tree),
        name: '',
        icon: '🏷️',
      });
    } else if (level === 'group') {
      if (!root) return;
      setEditorTarget({ level: 'group', rootIndex: selectedRoot, index: -1 });
      form.setFieldsValue({
        id: nextGroupId(root),
        name: '',
        icon: undefined,
      });
    } else {
      if (!root || !group) return;
      setEditorTarget({
        level: 'leaf',
        rootIndex: selectedRoot,
        groupIndex: selectedGroup,
        index: -1,
      });
      form.setFieldsValue({
        id: nextLeafId(group),
        name: '',
        icon: '',
      });
    }
    setEditorOpen(true);
  };

  const openEdit = (target: EditorTarget) => {
    setEditorTarget(target);
    if (target.level === 'root') {
      const item = tree[target.index];
      form.setFieldsValue({
        id: item.id,
        name: item.name,
        icon: item.icon,
      });
    } else if (target.level === 'group') {
      const item = tree[target.rootIndex].groups[target.index];
      form.setFieldsValue({ id: item.id, name: item.name });
    } else {
      const item =
        tree[target.rootIndex].groups[target.groupIndex].children[target.index];
      form.setFieldsValue({
        id: item.id,
        name: item.name,
        icon: item.icon ?? '',
      });
    }
    setEditorOpen(true);
  };

  const submitEditor = async () => {
    const values = await form.validateFields();
    if (!editorTarget) return;
    const next = cloneTree(tree);

    if (editorTarget.level === 'root') {
      if (editorTarget.index < 0) {
        next.push({
          id: String(values.id).trim(),
          name: String(values.name).trim(),
          icon: String(values.icon || '🏷️').trim() || '🏷️',
          groups: [],
        });
        setSelectedRoot(next.length - 1);
        setSelectedGroup(0);
      } else {
        next[editorTarget.index] = {
          ...next[editorTarget.index],
          id: String(values.id).trim(),
          name: String(values.name).trim(),
          icon: String(values.icon || '🏷️').trim() || '🏷️',
        };
      }
    } else if (editorTarget.level === 'group') {
      const groups = next[editorTarget.rootIndex].groups;
      if (editorTarget.index < 0) {
        groups.push({
          id: String(values.id).trim(),
          name: String(values.name).trim(),
          children: [],
        });
        setSelectedGroup(groups.length - 1);
      } else {
        groups[editorTarget.index] = {
          ...groups[editorTarget.index],
          id: String(values.id).trim(),
          name: String(values.name).trim(),
        };
      }
    } else {
      const children =
        next[editorTarget.rootIndex].groups[editorTarget.groupIndex].children;
      if (editorTarget.index < 0) {
        children.push({
          id: String(values.id).trim(),
          name: String(values.name).trim(),
          icon: String(values.icon ?? '').trim(),
        });
      } else {
        children[editorTarget.index] = {
          id: String(values.id).trim(),
          name: String(values.name).trim(),
          icon: String(values.icon ?? '').trim(),
        };
      }
    }

    setTree(next);
    setEditorOpen(false);
  };

  const removeAt = (target: EditorTarget) => {
    Modal.confirm({
      title: '确认删除？',
      content: '删除后需点「保存」才会同步到服务器 / App。',
      okText: '删除',
      okButtonProps: { danger: true },
      cancelText: '取消',
      onOk: () => {
        const next = cloneTree(tree);
        if (target.level === 'root') {
          next.splice(target.index, 1);
          setSelectedRoot(0);
          setSelectedGroup(0);
        } else if (target.level === 'group') {
          next[target.rootIndex].groups.splice(target.index, 1);
          setSelectedGroup(0);
        } else {
          next[target.rootIndex].groups[target.groupIndex].children.splice(
            target.index,
            1,
          );
        }
        setTree(next);
      },
    });
  };

  const save = async () => {
    setSaving(true);
    try {
      await apiPut('/admin/v1/catalog/categories', { payload: tree });
      setSavedSnapshot(JSON.stringify(tree));
      message.success('已保存，App GET /api/v1/categories 将使用这份数据');
      await loadLiveAppResponse();
    } catch (e) {
      message.error(e instanceof Error ? e.message : '保存失败');
    } finally {
      setSaving(false);
    }
  };

  const appPayloadJson = useMemo(
    () => JSON.stringify(tree, null, 2),
    [tree],
  );

  const liveJson = useMemo(
    () => JSON.stringify(liveAppData ?? [], null, 2),
    [liveAppData],
  );

  return (
    <div className="category-admin">
      <Space style={{ width: '100%', justifyContent: 'space-between' }} wrap>
        <div>
          <Typography.Title level={3} style={{ margin: 0 }}>
            分类配置
          </Typography.Title>
          <Typography.Paragraph type="secondary" style={{ marginBottom: 0 }}>
            三级结构与 App 一致：一级类目 → 二级分组 → 三级叶子。保存后写入
            PostgreSQL，供 <code>GET /api/v1/categories</code> 返回。
          </Typography.Paragraph>
        </div>
        <Space wrap>
          {dirty ? <Tag color="orange">未保存</Tag> : <Tag color="green">已同步</Tag>}
          <Button icon={<ReloadOutlined />} onClick={() => void load()} loading={loading}>
            重新加载
          </Button>
          <Button icon={<EyeOutlined />} onClick={() => void loadLiveAppResponse()}>
            拉取 App 返回
          </Button>
          <Button
            type="primary"
            icon={<SaveOutlined />}
            loading={saving}
            disabled={!dirty}
            onClick={() => void save()}
          >
            保存到服务器
          </Button>
        </Space>
      </Space>

      <Row gutter={16} style={{ marginTop: 16 }}>
        <Col xs={24} lg={14}>
          <Row gutter={12}>
            <Col span={8}>
              <CategoryColumn
                title="一级类目"
                hint="App 左侧 Tab"
                onAdd={() => openCreate('root')}
                empty={!tree.length}
              >
                {tree.map((item, index) => (
                  <CategoryCard
                    key={item.id}
                    active={index === selectedRoot}
                    title={`${item.icon} ${item.name}`}
                    subtitle={item.id}
                    meta={`${item.groups.length} 个分组`}
                    onSelect={() => {
                      setSelectedRoot(index);
                      setSelectedGroup(0);
                    }}
                    onEdit={() => openEdit({ level: 'root', index })}
                    onDelete={() => removeAt({ level: 'root', index })}
                    onMoveUp={() =>
                      setTree((prev) => moveItem(prev, index, index - 1))
                    }
                    onMoveDown={() =>
                      setTree((prev) => moveItem(prev, index, index + 1))
                    }
                    disableUp={index === 0}
                    disableDown={index === tree.length - 1}
                  />
                ))}
              </CategoryColumn>
            </Col>
            <Col span={8}>
              <CategoryColumn
                title="二级分组"
                hint="App 右侧区块标题"
                onAdd={() => openCreate('group')}
                addDisabled={!root}
                empty={!root?.groups.length}
              >
                {root?.groups.map((item, index) => (
                  <CategoryCard
                    key={item.id}
                    active={index === selectedGroup}
                    title={item.name}
                    subtitle={item.id}
                    meta={`${item.children.length} 个叶子`}
                    onSelect={() => setSelectedGroup(index)}
                    onEdit={() =>
                      openEdit({
                        level: 'group',
                        rootIndex: selectedRoot,
                        index,
                      })
                    }
                    onDelete={() =>
                      removeAt({
                        level: 'group',
                        rootIndex: selectedRoot,
                        index,
                      })
                    }
                    onMoveUp={() =>
                      setTree((prev) => {
                        const next = cloneTree(prev);
                        next[selectedRoot].groups = moveItem(
                          next[selectedRoot].groups,
                          index,
                          index - 1,
                        );
                        return next;
                      })
                    }
                    onMoveDown={() =>
                      setTree((prev) => {
                        const next = cloneTree(prev);
                        next[selectedRoot].groups = moveItem(
                          next[selectedRoot].groups,
                          index,
                          index + 1,
                        );
                        return next;
                      })
                    }
                    disableUp={index === 0}
                    disableDown={index === (root?.groups.length ?? 0) - 1}
                  />
                ))}
              </CategoryColumn>
            </Col>
            <Col span={8}>
              <CategoryColumn
                title="三级叶子"
                hint="App 可点进商品列表"
                onAdd={() => openCreate('leaf')}
                addDisabled={!group}
                empty={!group?.children.length}
              >
                {group?.children.map((item, index) => (
                  <CategoryCard
                    key={item.id}
                    active={false}
                    title={`${item.icon ? `${item.icon} ` : ''}${item.name}`}
                    subtitle={item.id}
                    meta="leaf"
                    onSelect={() => undefined}
                    onEdit={() =>
                      openEdit({
                        level: 'leaf',
                        rootIndex: selectedRoot,
                        groupIndex: selectedGroup,
                        index,
                      })
                    }
                    onDelete={() =>
                      removeAt({
                        level: 'leaf',
                        rootIndex: selectedRoot,
                        groupIndex: selectedGroup,
                        index,
                      })
                    }
                    onMoveUp={() =>
                      setTree((prev) => {
                        const next = cloneTree(prev);
                        next[selectedRoot].groups[selectedGroup].children =
                          moveItem(
                            next[selectedRoot].groups[selectedGroup].children,
                            index,
                            index - 1,
                          );
                        return next;
                      })
                    }
                    onMoveDown={() =>
                      setTree((prev) => {
                        const next = cloneTree(prev);
                        next[selectedRoot].groups[selectedGroup].children =
                          moveItem(
                            next[selectedRoot].groups[selectedGroup].children,
                            index,
                            index + 1,
                          );
                        return next;
                      })
                    }
                    disableUp={index === 0}
                    disableDown={index === (group?.children.length ?? 0) - 1}
                  />
                ))}
              </CategoryColumn>
            </Col>
          </Row>
        </Col>

        <Col xs={24} lg={10}>
          <Card
            title="App 使用预览"
            extra={
              <Typography.Text type="secondary" style={{ fontSize: 12 }}>
                对应 GET /api/v1/categories
              </Typography.Text>
            }
          >
            <Tabs
              items={[
                {
                  key: 'ui',
                  label: '图形预览',
                  children: (
                    <div className="category-phone">
                      <div className="category-phone__frame">
                        <div className="category-phone__status">SHOO · Category</div>
                        <div className="category-phone__body">
                          <div className="category-phone__rail">
                            {tree.map((item, index) => (
                              <button
                                key={item.id}
                                type="button"
                                className={
                                  index === selectedRoot
                                    ? 'category-phone__tab active'
                                    : 'category-phone__tab'
                                }
                                onClick={() => {
                                  setSelectedRoot(index);
                                  setSelectedGroup(0);
                                }}
                              >
                                <span>{item.icon}</span>
                                <span>{item.name}</span>
                              </button>
                            ))}
                          </div>
                          <div className="category-phone__panel">
                            {!root?.groups.length ? (
                              <Empty description="暂无分组" image={Empty.PRESENTED_IMAGE_SIMPLE} />
                            ) : (
                              root.groups.map((g) => (
                                <div key={g.id} className="category-phone__group">
                                  <div className="category-phone__group-title">{g.name}</div>
                                  <div className="category-phone__leaves">
                                    {g.children.map((leaf) => (
                                      <div key={leaf.id} className="category-phone__leaf">
                                        <span className="category-phone__leaf-icon">
                                          {leaf.icon || '▫️'}
                                        </span>
                                        <span>{leaf.name}</span>
                                      </div>
                                    ))}
                                  </div>
                                </div>
                              ))
                            )}
                          </div>
                        </div>
                      </div>
                      <Typography.Paragraph
                        type="secondary"
                        style={{ marginTop: 12, marginBottom: 0, fontSize: 12 }}
                      >
                        左侧点击可切换一级类目；保存后 App 本地环境拉取到的就是右侧 JSON。
                      </Typography.Paragraph>
                    </div>
                  ),
                },
                {
                  key: 'draft',
                  label: '当前编辑 JSON',
                  children: (
                    <pre className="category-json">{appPayloadJson}</pre>
                  ),
                },
                {
                  key: 'live',
                  label: '服务器已生效返回',
                  children: (
                    <div>
                      <Space style={{ marginBottom: 8 }}>
                        <Button size="small" onClick={() => void loadLiveAppResponse()}>
                          刷新
                        </Button>
                        <Typography.Text type="secondary" style={{ fontSize: 12 }}>
                          直接请求 /api/v1/categories（App 同款）
                        </Typography.Text>
                      </Space>
                      <pre className="category-json">{liveJson}</pre>
                    </div>
                  ),
                },
              ]}
            />
          </Card>
        </Col>
      </Row>

      <Modal
        title={
          editorTarget &&
          ((editorTarget.level === 'root' && editorTarget.index < 0) ||
            (editorTarget.level === 'group' && editorTarget.index < 0) ||
            (editorTarget.level === 'leaf' && editorTarget.index < 0))
            ? `新增${
                editorTarget.level === 'root'
                  ? '一级类目'
                  : editorTarget.level === 'group'
                    ? '二级分组'
                    : '三级叶子'
              }`
            : `编辑${
                editorTarget?.level === 'root'
                  ? '一级类目'
                  : editorTarget?.level === 'group'
                    ? '二级分组'
                    : '三级叶子'
              }`
        }
        open={editorOpen}
        onCancel={() => setEditorOpen(false)}
        onOk={() => void submitEditor()}
        okText="确定"
        cancelText="取消"
        destroyOnClose
      >
        <Form form={form} layout="vertical" style={{ marginTop: 12 }}>
          <Form.Item
            name="id"
            label="ID"
            rules={[{ required: true, message: '请输入 ID' }]}
            extra="叶子 ID 常被商品 categoryId 引用，改动需谨慎"
          >
            <Input placeholder="例如 c1 / c1-g1 / c1-g1-l1" />
          </Form.Item>
          <Form.Item
            name="name"
            label="名称"
            rules={[{ required: true, message: '请输入名称' }]}
          >
            <Input placeholder="显示名称" />
          </Form.Item>
          {editorTarget?.level !== 'group' ? (
            <Form.Item name="icon" label="图标（Emoji）">
              <Input placeholder="👗" />
            </Form.Item>
          ) : null}
          {editorTarget?.level === 'root' ? (
            <Space wrap>
              {ICON_PRESETS.map((icon) => (
                <Button
                  key={icon}
                  onClick={() => form.setFieldValue('icon', icon)}
                >
                  {icon}
                </Button>
              ))}
            </Space>
          ) : null}
        </Form>
      </Modal>
    </div>
  );
}

function CategoryColumn({
  title,
  hint,
  onAdd,
  addDisabled,
  empty,
  children,
}: {
  title: string;
  hint: string;
  onAdd: () => void;
  addDisabled?: boolean;
  empty?: boolean;
  children: ReactNode;
}) {
  return (
    <Card
      size="small"
      title={
        <div>
          <div>{title}</div>
          <Typography.Text type="secondary" style={{ fontSize: 12, fontWeight: 400 }}>
            {hint}
          </Typography.Text>
        </div>
      }
      extra={
        <Button
          type="link"
          size="small"
          icon={<PlusOutlined />}
          disabled={addDisabled}
          onClick={onAdd}
        >
          添加
        </Button>
      }
      styles={{ body: { minHeight: 420, maxHeight: 640, overflow: 'auto' } }}
    >
      {empty ? (
        <Empty image={Empty.PRESENTED_IMAGE_SIMPLE} description="暂无数据" />
      ) : (
        <Space direction="vertical" style={{ width: '100%' }} size={8}>
          {children}
        </Space>
      )}
    </Card>
  );
}

function CategoryCard({
  active,
  title,
  subtitle,
  meta,
  onSelect,
  onEdit,
  onDelete,
  onMoveUp,
  onMoveDown,
  disableUp,
  disableDown,
}: {
  active: boolean;
  title: string;
  subtitle: string;
  meta: string;
  onSelect: () => void;
  onEdit: () => void;
  onDelete: () => void;
  onMoveUp: () => void;
  onMoveDown: () => void;
  disableUp?: boolean;
  disableDown?: boolean;
}) {
  return (
    <div
      className={active ? 'category-item active' : 'category-item'}
      onClick={onSelect}
      onKeyDown={(e) => {
        if (e.key === 'Enter' || e.key === ' ') onSelect();
      }}
      role="button"
      tabIndex={0}
    >
      <div className="category-item__main">
        <div className="category-item__title">{title}</div>
        <div className="category-item__sub">{subtitle}</div>
        <div className="category-item__meta">{meta}</div>
      </div>
      <Space size={0} onClick={(e) => e.stopPropagation()}>
        <Button
          type="text"
          size="small"
          icon={<ArrowUpOutlined />}
          disabled={disableUp}
          onClick={onMoveUp}
        />
        <Button
          type="text"
          size="small"
          icon={<ArrowDownOutlined />}
          disabled={disableDown}
          onClick={onMoveDown}
        />
        <Button type="text" size="small" icon={<EditOutlined />} onClick={onEdit} />
        <Button
          type="text"
          size="small"
          danger
          icon={<DeleteOutlined />}
          onClick={onDelete}
        />
      </Space>
    </div>
  );
}
