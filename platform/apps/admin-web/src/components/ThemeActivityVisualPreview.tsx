import { Tag, Typography } from 'antd';
import type { CSSProperties } from 'react';

type JsonRecord = Record<string, unknown>;

function isRecord(v: unknown): v is JsonRecord {
  return Boolean(v) && typeof v === 'object' && !Array.isArray(v);
}

function asString(v: unknown, fallback = ''): string {
  return v == null ? fallback : String(v);
}

function moduleBoxStyle(mod: JsonRecord): CSSProperties {
  const style = isRecord(mod.style) ? mod.style : {};
  const margin = isRecord(mod.margin) ? mod.margin : {};
  const padding = isRecord(mod.padding) ? mod.padding : {};
  const bg = asString(style.backgroundColor, '#F3F4F6');
  const radius = Number(style.borderRadius ?? 12);

  const edge = (box: JsonRecord, key: string, fallback: number) =>
    Number(box[key] ?? fallback);

  return {
    backgroundColor: bg,
    borderRadius: radius,
    margin: `${edge(margin, 'top', 6)}px ${edge(margin, 'right', 10)}px ${edge(margin, 'bottom', 6)}px ${edge(margin, 'left', 10)}px`,
    padding: `${edge(padding, 'top', 8)}px ${edge(padding, 'right', 8)}px ${edge(padding, 'bottom', 8)}px ${edge(padding, 'left', 8)}px`,
    border: '1px solid rgba(0,0,0,0.06)',
  };
}

function ModuleHeader({ mod }: { mod: JsonRecord }) {
  return (
    <div className="theme-preview__module-head">
      <Tag color="blue">{asString(mod.type, 'unknown')}</Tag>
      <Typography.Text type="secondary" style={{ fontSize: 11 }}>
        {asString(mod.moduleId, '—')}
      </Typography.Text>
    </div>
  );
}

function ImageBlock({ url, ratio = 2.5 }: { url: string; ratio?: number }) {
  if (!url) {
    return <div className="theme-preview__placeholder" style={{ aspectRatio: ratio }} />;
  }
  return (
    <img
      src={url}
      alt=""
      className="theme-preview__image"
      style={{ aspectRatio: ratio }}
      onError={(e) => {
        (e.target as HTMLImageElement).style.display = 'none';
      }}
    />
  );
}

function renderModuleBody(mod: JsonRecord) {
  const type = asString(mod.type);

  switch (type) {
    case 'bannerRow':
      return (
        <ImageBlock
          url={asString(mod.image)}
          ratio={Number(mod.aspectRatio ?? 2.5)}
        />
      );

    case 'bannerStack': {
      const items = Array.isArray(mod.items) ? mod.items.filter(isRecord) : [];
      return (
        <div className="theme-preview__stack">
          {items.map((item, i) => (
            <ImageBlock
              key={i}
              url={asString(item.image)}
              ratio={Number(item.aspectRatio ?? 2.5)}
            />
          ))}
        </div>
      );
    }

    case 'countdown':
      return (
        <div className="theme-preview__countdown">
          <span>{asString(mod.prefixText, '倒计时')}</span>
          <strong>00 : 12 : 34 : 56</strong>
          <Typography.Text type="secondary" style={{ fontSize: 11 }}>
            {asString(mod.format, 'DHMS')} · {asString(mod.layout, 'block')}
          </Typography.Text>
        </div>
      );

    case 'coupon': {
      const items = Array.isArray(mod.items) ? mod.items.filter(isRecord) : [];
      return (
        <div className="theme-preview__coupon-row">
          {items.map((item, i) => (
            <div key={i} className="theme-preview__coupon">
              <div className="theme-preview__coupon-amt">
                ¥{asString(item.amount, '0')}
              </div>
              <div className="theme-preview__coupon-title">
                {asString(item.title, '优惠券')}
              </div>
              <div className="theme-preview__coupon-btn">
                {asString(item.buttonText, '领取')}
              </div>
            </div>
          ))}
        </div>
      );
    }

    case 'marquee': {
      const items = Array.isArray(mod.items) ? mod.items.filter(isRecord) : [];
      const text = items.map((item) => asString(item.text)).filter(Boolean).join('  ·  ');
      return (
        <div className="theme-preview__marquee">
          {text || '跑马灯文案'}
        </div>
      );
    }

    case 'grid':
    case 'menu': {
      const items = Array.isArray(mod.items) ? mod.items.filter(isRecord) : [];
      const columns = Number(mod.columns ?? 4);
      return (
        <>
          {type === 'menu' && mod.showTitleBar && isRecord(mod.titleBar) ? (
            <div className="theme-preview__menu-title">
              <span>{asString(mod.titleBar.title, 'Menu')}</span>
              <span className="theme-preview__menu-more">
                {asString(mod.titleBar.moreText, '更多')}
              </span>
            </div>
          ) : null}
          <div
            className="theme-preview__grid"
            style={{ gridTemplateColumns: `repeat(${columns}, 1fr)` }}
          >
            {items.slice(0, 8).map((item, i) => (
              <div key={i} className="theme-preview__grid-item">
                <ImageBlock url={asString(item.image)} ratio={1} />
                <span>{asString(item.title)}</span>
              </div>
            ))}
          </div>
        </>
      );
    }

    case 'unevenGrid': {
      const slots = Array.isArray(mod.slots) ? mod.slots.filter(isRecord) : [];
      return (
        <div className="theme-preview__uneven">
          {slots.slice(0, 3).map((slot, i) => (
            <div key={i} className={`theme-preview__uneven-slot theme-preview__uneven-slot--${i}`}>
              <ImageBlock url={asString(slot.image)} ratio={1} />
            </div>
          ))}
        </div>
      );
    }

    case 'productScroll': {
      const ds = isRecord(mod.dataSource) ? mod.dataSource : {};
      const items = Array.isArray(ds.items) ? ds.items.filter(isRecord) : [];
      return (
        <div className="theme-preview__scroll-row">
          {items.slice(0, 4).map((item, i) => (
            <div key={i} className="theme-preview__product-card">
              <ImageBlock url={asString(item.image ?? item.imageUrl)} ratio={1} />
              <div className="theme-preview__product-title">
                {asString(item.title, '商品')}
              </div>
              <div className="theme-preview__product-price">
                ¥{(Number(item.price ?? 0) / 100).toFixed(2)}
              </div>
            </div>
          ))}
        </div>
      );
    }

    case 'web':
      return (
        <div className="theme-preview__web">
          <div className="theme-preview__web-icon">🌐</div>
          <Typography.Text ellipsis style={{ fontSize: 11, maxWidth: '100%' }}>
            {asString(mod.url, 'https://…')}
          </Typography.Text>
          {mod.fallbackImage ? (
            <ImageBlock url={asString(mod.fallbackImage)} ratio={1.6} />
          ) : null}
        </div>
      );

    default:
      return (
        <Typography.Text type="secondary" style={{ fontSize: 12 }}>
          未知模块类型
        </Typography.Text>
      );
  }
}

function sortedModules(config: JsonRecord): JsonRecord[] {
  const modules = Array.isArray(config.modules)
    ? config.modules.filter(isRecord)
    : [];
  return [...modules].sort(
    (a, b) => Number(a.sort ?? 0) - Number(b.sort ?? 0),
  );
}

export default function ThemeActivityVisualPreview({
  config,
}: {
  config: JsonRecord | null;
}) {
  if (!config) {
    return (
      <Typography.Text type="secondary">
        编辑右侧 JSON 或点击「刷新预览」查看效果
      </Typography.Text>
    );
  }

  const pageBg = isRecord(config.pageBackground)
    ? asString(config.pageBackground.color, '#F5F5F5')
    : '#F5F5F5';
  const navBar = isRecord(config.navBar) ? config.navBar : {};
  const navBg = asString(navBar.backgroundColor, '#1A237E');
  const navTitle = asString(config.title, '主题活动');
  const modules = sortedModules(config).filter(
    (m) => m.visible !== false && asString(m.moduleId),
  );
  const footer = isRecord(config.footer) ? config.footer : null;
  const access = isRecord(config._access) ? config._access : null;

  return (
    <div className="theme-preview">
      <div
        className="home-phone__frame theme-preview__phone"
        style={{ background: pageBg }}
      >
        <div
          className="theme-preview__navbar"
          style={{
            background:
              asString(navBar.style) === 'transparent'
                ? 'rgba(0,0,0,0.35)'
                : navBg,
            color: asString(navBar.titleColor, '#FFFFFF'),
          }}
        >
          <span>‹</span>
          <span className="theme-preview__navbar-title">{navTitle}</span>
          <span>{navBar.showShare ? '⎙' : ' '}</span>
        </div>

        {access && access.allowed === false ? (
          <div className="theme-preview__blocked">
            活动不可访问（{asString(access.reason, 'blocked')}）
          </div>
        ) : (
          <div className="theme-preview__scroll">
            {modules.length === 0 ? (
              <div className="theme-preview__empty">暂无 modules</div>
            ) : (
              modules.map((mod) => (
                <div key={asString(mod.moduleId)} style={moduleBoxStyle(mod)}>
                  <ModuleHeader mod={mod} />
                  {renderModuleBody(mod)}
                </div>
              ))
            )}

            {footer ? (
              <div
                className="theme-preview__footer"
                style={{
                  backgroundColor: asString(
                    isRecord(footer.style) ? footer.style.backgroundColor : '',
                    '#FFFFFF',
                  ),
                }}
              >
                <div className="theme-preview__footer-title">
                  {isRecord(footer.header)
                    ? asString(footer.header.title, '商品区')
                    : `Footer · ${asString(footer.type)}`}
                </div>
                <div className="home-phone__feed-grid">
                  {Array.from({ length: 4 }).map((_, i) => (
                    <div key={i} className="home-phone__feed-card" />
                  ))}
                </div>
              </div>
            ) : null}
          </div>
        )}
      </div>
    </div>
  );
}
