export type ThemeValidationIssue = {
  level: 'error' | 'warn';
  path: string;
  message: string;
};

export type ThemeValidationResult = {
  ok: boolean;
  errors: ThemeValidationIssue[];
  warnings: ThemeValidationIssue[];
};

const MODULE_TYPES = new Set([
  'grid',
  'unevenGrid',
  'web',
  'coupon',
  'countdown',
  'marquee',
  'bannerRow',
  'bannerStack',
  'productScroll',
  'menu',
]);

const FOOTER_TYPES = new Set([
  'productListSingle',
  'productListDouble',
  'productWaterfall',
]);

const STATUS = new Set(['draft', 'online', 'offline']);
const EXPIRED = new Set(['block', 'browse']);

/** Paths / hosts we accept as Deep Link-ish (backend whitelist). */
const LINK_OK =
  /^(https?:\/\/shoo\.app\/|shoo:\/\/|shoo\.app\/|\/|[a-z][\w-]*:\/\/)/i;

function isRecord(v: unknown): v is Record<string, unknown> {
  return Boolean(v) && typeof v === 'object' && !Array.isArray(v);
}

function push(
  list: ThemeValidationIssue[],
  level: 'error' | 'warn',
  path: string,
  message: string,
) {
  list.push({ level, path, message });
}

function validateLink(
  link: unknown,
  path: string,
  errors: ThemeValidationIssue[],
  warnings: ThemeValidationIssue[],
  required: boolean,
) {
  if (link == null || link === '') {
    if (required) {
      push(warnings, 'warn', path, '可点击项缺少 link（将不可点或仅展示）');
    }
    return;
  }
  if (typeof link !== 'string') {
    push(errors, 'error', path, 'link 必须为 string');
    return;
  }
  const trimmed = link.trim();
  if (!LINK_OK.test(trimmed) && !trimmed.startsWith('/')) {
    push(
      errors,
      'error',
      path,
      `link 无法识别为 Deep Link / in-app path: ${trimmed}`,
    );
  }
}

function walkForbiddenAction(
  node: unknown,
  path: string,
  errors: ThemeValidationIssue[],
) {
  if (Array.isArray(node)) {
    node.forEach((item, i) => walkForbiddenAction(item, `${path}[${i}]`, errors));
    return;
  }
  if (!isRecord(node)) return;
  if (isRecord(node.action) && typeof node.action.type === 'string') {
    const t = node.action.type;
    if (
      ['product', 'category', 'route', 'url', 'webview', 'coupon', 'custom'].includes(
        t,
      )
    ) {
      push(
        errors,
        'error',
        `${path}.action.type`,
        `废弃跳转 DSL action.type=${t}，请改用 link（Deep Link）`,
      );
    }
  }
  for (const [k, v] of Object.entries(node)) {
    if (k === 'action') continue;
    walkForbiddenAction(v, `${path}.${k}`, errors);
  }
}

function validateModule(
  mod: Record<string, unknown>,
  path: string,
  errors: ThemeValidationIssue[],
  warnings: ThemeValidationIssue[],
) {
  const moduleId = String(mod.moduleId ?? '');
  if (!moduleId) {
    push(errors, 'error', `${path}.moduleId`, 'moduleId 必填');
  }
  const type = String(mod.type ?? '');
  if (!MODULE_TYPES.has(type)) {
    push(
      warnings,
      'warn',
      `${path}.type`,
      `未知 module type="${type}"，客户端将跳过`,
    );
  }

  if (type === 'grid') {
    const cols = Number(mod.columns ?? 4);
    if (cols < 1 || cols > 6) {
      push(warnings, 'warn', `${path}.columns`, 'columns 应在 1～6，将 clamp');
    }
  }

  if (type === 'web') {
    if (!mod.height && mod.aspectRatio == null) {
      push(errors, 'error', path, 'web 模块需 height 或 aspectRatio');
    }
    if (!mod.url) {
      push(errors, 'error', `${path}.url`, 'web 模块 url 必填');
    }
    validateLink(mod.fallbackLink, `${path}.fallbackLink`, errors, warnings, false);
  }

  if (type === 'countdown') {
    const mode = String(mod.mode ?? 'toEnd');
    if (mode === 'toEnd' && !mod.endAt) {
      push(errors, 'error', `${path}.endAt`, 'countdown toEnd 需 endAt');
    }
    if (mode === 'toStart' && !mod.startAt) {
      push(errors, 'error', `${path}.startAt`, 'countdown toStart 需 startAt');
    }
    validateLink(mod.onExpireLink, `${path}.onExpireLink`, errors, warnings, false);
  }

  if (type === 'unevenGrid') {
    if (!Array.isArray(mod.slots) || mod.slots.length === 0) {
      push(errors, 'error', `${path}.slots`, 'unevenGrid 需 slots[]');
    }
  }

  if (type === 'bannerRow') {
    if (!mod.image) {
      push(errors, 'error', `${path}.image`, 'bannerRow 需 image');
    }
    validateLink(mod.link, `${path}.link`, errors, warnings, false);
    if (Array.isArray(mod.hotspots)) {
      mod.hotspots.forEach((h, i) => {
        if (isRecord(h)) {
          validateLink(h.link, `${path}.hotspots[${i}].link`, errors, warnings, true);
        }
      });
    }
  }

  if (type === 'coupon' && Array.isArray(mod.items)) {
    mod.items.forEach((item, i) => {
      if (!isRecord(item)) return;
      const status = String(item.status ?? '');
      const button = String(item.buttonText ?? '');
      if (status === 'claimed' && /去使用|use/i.test(button)) {
        validateLink(
          item.link,
          `${path}.items[${i}].link`,
          errors,
          warnings,
          true,
        );
        if (!item.link) {
          push(
            errors,
            'error',
            `${path}.items[${i}].link`,
            'claimed 券「去使用」必须配置 link',
          );
        }
      } else {
        validateLink(item.link, `${path}.items[${i}].link`, errors, warnings, false);
      }
    });
  }

  const defaultLink = mod.defaultLink;
  validateLink(defaultLink, `${path}.defaultLink`, errors, warnings, false);

  const items = mod.items;
  if (Array.isArray(items)) {
    items.forEach((item, i) => {
      if (!isRecord(item)) return;
      if ('link' in item) {
        validateLink(item.link, `${path}.items[${i}].link`, errors, warnings, false);
      }
      if (Array.isArray(item.hotspots)) {
        item.hotspots.forEach((h, j) => {
          if (isRecord(h)) {
            validateLink(
              h.link,
              `${path}.items[${i}].hotspots[${j}].link`,
              errors,
              warnings,
              true,
            );
          }
        });
      }
    });
  }

  if (Array.isArray(mod.slots)) {
    mod.slots.forEach((slot, i) => {
      if (isRecord(slot)) {
        validateLink(slot.link, `${path}.slots[${i}].link`, errors, warnings, false);
      }
    });
  }

  if (isRecord(mod.titleBar)) {
    validateLink(
      mod.titleBar.moreLink,
      `${path}.titleBar.moreLink`,
      errors,
      warnings,
      false,
    );
  }

  walkForbiddenAction(mod, path, errors);
}

function validateFooter(
  footer: Record<string, unknown>,
  path: string,
  errors: ThemeValidationIssue[],
  warnings: ThemeValidationIssue[],
) {
  const type = String(footer.type ?? '');
  if (!FOOTER_TYPES.has(type)) {
    push(
      errors,
      'error',
      `${path}.type`,
      `footer.type 必须是 productListSingle | productListDouble | productWaterfall`,
    );
  }
  if (!isRecord(footer.dataSource)) {
    push(errors, 'error', `${path}.dataSource`, 'footer 必须有 dataSource');
  }
  walkForbiddenAction(footer, path, errors);
}

/**
 * Validate ThemeActivity page config per design doc §10.
 */
export function validateThemeActivityConfig(
  raw: unknown,
): ThemeValidationResult {
  const errors: ThemeValidationIssue[] = [];
  const warnings: ThemeValidationIssue[] = [];

  if (!isRecord(raw)) {
    push(errors, 'error', '$', '配置必须是 JSON 对象');
    return { ok: false, errors, warnings };
  }

  const activityId = String(raw.activityId ?? '').trim();
  const title = String(raw.title ?? '').trim();
  if (!activityId) push(errors, 'error', 'activityId', 'activityId 必填');
  if (!title) push(errors, 'error', 'title', 'title 必填');

  if (raw.status != null && !STATUS.has(String(raw.status))) {
    push(errors, 'error', 'status', 'status 须为 draft | online | offline');
  }
  if (
    raw.expiredBehavior != null &&
    !EXPIRED.has(String(raw.expiredBehavior))
  ) {
    push(errors, 'error', 'expiredBehavior', '须为 block | browse');
  }

  if (Array.isArray(raw.footer)) {
    push(errors, 'error', 'footer', 'footer 只能是 0 或 1 个对象，不能是数组');
  } else if (raw.footer != null) {
    if (!isRecord(raw.footer)) {
      push(errors, 'error', 'footer', 'footer 必须是对象');
    } else {
      validateFooter(raw.footer, 'footer', errors, warnings);
    }
  }

  if (raw.modules != null) {
    if (!Array.isArray(raw.modules)) {
      push(errors, 'error', 'modules', 'modules 必须是数组');
    } else {
      raw.modules.forEach((mod, i) => {
        if (!isRecord(mod)) {
          push(errors, 'error', `modules[${i}]`, '模块必须是对象');
          return;
        }
        validateModule(mod, `modules[${i}]`, errors, warnings);
      });
    }
  }

  walkForbiddenAction(raw, '$', errors);

  return {
    ok: errors.length === 0,
    errors,
    warnings,
  };
}
