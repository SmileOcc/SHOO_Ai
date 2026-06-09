import fs from 'node:fs';
import fsp from 'node:fs/promises';
import path from 'node:path';

import { config } from './config.js';

const MIME_BY_EXT = {
  pdf: 'application/pdf',
  doc: 'application/msword',
  docx: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  xls: 'application/vnd.ms-excel',
  xlsx: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  zip: 'application/zip',
  rar: 'application/vnd.rar',
  '7z': 'application/x-7z-compressed',
  mp4: 'video/mp4',
  mov: 'video/quicktime',
  mp3: 'audio/mpeg',
  png: 'image/png',
  jpg: 'image/jpeg',
  jpeg: 'image/jpeg',
  gif: 'image/gif',
  webp: 'image/webp',
  txt: 'text/plain',
  json: 'application/json',
  apk: 'application/vnd.android.package-archive',
};

const FILE_TYPE_BY_EXT = {
  pdf: 'pdf',
  doc: 'doc',
  docx: 'doc',
  xls: 'excel',
  xlsx: 'excel',
  zip: 'zip',
  rar: 'zip',
  '7z': 'zip',
  mp4: 'video',
  mov: 'video',
  mp3: 'audio',
  png: 'image',
  jpg: 'image',
  jpeg: 'image',
  gif: 'image',
  webp: 'image',
  apk: 'apk',
};

let catalogCache = null;

export function clearDownloadCatalogCache() {
  catalogCache = null;
}

/** @deprecated use clearDownloadCatalogCache */
export function clearDocumentsCatalogCache() {
  clearDownloadCatalogCache();
}

function inferMimeType(fileName) {
  const ext = path.extname(fileName).slice(1).toLowerCase();
  return MIME_BY_EXT[ext] ?? 'application/octet-stream';
}

function inferFileType(fileName) {
  const ext = path.extname(fileName).slice(1).toLowerCase();
  if (!ext) return 'file';
  return FILE_TYPE_BY_EXT[ext] ?? ext;
}

function displayTitle(fileName) {
  const base = path.basename(fileName, path.extname(fileName));
  return base || fileName;
}

export function resolveSafeDownloadPath(fileName) {
  const decoded = decodeURIComponent(fileName);
  const baseName = path.basename(decoded);

  if (!baseName || baseName !== decoded || baseName.includes('..')) {
    return null;
  }

  const resolved = path.resolve(config.downloadDir, baseName);
  const root = path.resolve(config.downloadDir);

  if (!resolved.startsWith(`${root}${path.sep}`)) {
    return null;
  }

  return resolved;
}

export async function listDownloadFiles() {
  await fsp.mkdir(config.downloadDir, { recursive: true });

  const entries = await fsp.readdir(config.downloadDir, { withFileTypes: true });
  const files = [];

  for (const entry of entries) {
    if (!entry.isFile() || entry.name.startsWith('.')) continue;

    const filePath = path.join(config.downloadDir, entry.name);
    const stat = await fsp.stat(filePath);

    files.push({
      title: displayTitle(entry.name),
      fileName: entry.name,
      fileType: inferFileType(entry.name),
      mimeType: inferMimeType(entry.name),
      sizeBytes: stat.size,
      downloadPath: `/download/${encodeURIComponent(entry.name)}`,
    });
  }

  return files.sort((a, b) => a.fileName.localeCompare(b.fileName, 'zh-CN'));
}

async function getCatalog() {
  if (catalogCache) return catalogCache;
  catalogCache = await listDownloadFiles();
  return catalogCache;
}

export async function handleDownloadCatalog(_req, res) {
  const data = await getCatalog();
  res.json({ code: 0, message: 'ok', data });
}

function escapeDispositionFilename(fileName) {
  return fileName.replace(/\\/g, '\\\\').replace(/"/g, '\\"');
}

/** RFC 6266 / RFC 5987 — HTTP 头仅允许 ASCII，中文等非 ASCII 文件名用 filename* */
function buildContentDisposition(fileName) {
  const hasNonAscii = /[^\x20-\x7E]/.test(fileName);
  const asciiFallback = fileName.replace(/[^\x20-\x7E]/g, '_');
  const escaped = escapeDispositionFilename(asciiFallback);

  if (!hasNonAscii) {
    return `attachment; filename="${escaped}"`;
  }

  return `attachment; filename="${escaped}"; filename*=UTF-8''${encodeURIComponent(fileName)}`;
}

function streamFile(req, res, filePath, fileName) {
  const stat = fs.statSync(filePath);
  const fileSize = stat.size;
  const range = req.headers.range;
  const mimeType = inferMimeType(fileName);

  res.setHeader('Accept-Ranges', 'bytes');
  res.setHeader('Content-Disposition', buildContentDisposition(fileName));

  if (range) {
    const match = /^bytes=(\d*)-(\d*)$/.exec(range);
    if (!match) {
      res.status(416).end();
      return;
    }

    const start = match[1] === '' ? 0 : Number.parseInt(match[1], 10);
    const end = match[2] === '' ? fileSize - 1 : Number.parseInt(match[2], 10);

    if (Number.isNaN(start) || Number.isNaN(end) || start > end || start >= fileSize) {
      res.status(416).setHeader('Content-Range', `bytes */${fileSize}`).end();
      return;
    }

    const safeEnd = Math.min(end, fileSize - 1);
    const chunkSize = safeEnd - start + 1;

    res.status(206);
    res.setHeader('Content-Range', `bytes ${start}-${safeEnd}/${fileSize}`);
    res.setHeader('Content-Length', chunkSize);
    res.setHeader('Content-Type', mimeType);

    const stream = fs.createReadStream(filePath, { start, end: safeEnd });
    stream.on('error', () => res.destroy());
    stream.pipe(res);
    return;
  }

  res.status(200);
  res.setHeader('Content-Length', fileSize);
  res.setHeader('Content-Type', mimeType);

  const stream = fs.createReadStream(filePath);
  stream.on('error', () => res.destroy());
  stream.pipe(res);
}

export async function handleFileDownload(req, res, fileName) {
  const filePath = resolveSafeDownloadPath(fileName);

  if (!filePath) {
    res.status(400).json({
      code: 400,
      message: 'Invalid file name',
      data: null,
    });
    return;
  }

  try {
    const stat = await fsp.stat(filePath);
    if (!stat.isFile()) {
      res.status(404).json({
        code: 404,
        message: `File not found: ${fileName}`,
        data: null,
      });
      return;
    }
  } catch {
    res.status(404).json({
      code: 404,
      message: `File not found: ${fileName}`,
      data: null,
    });
    return;
  }

  streamFile(req, res, filePath, path.basename(filePath));
}
