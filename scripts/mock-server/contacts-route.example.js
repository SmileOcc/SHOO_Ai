/**
 * 将本段注册信息追加到本地 server/src/routeRegistry.js（server/ 目录默认 gitignore）。
 *
 * 与 Flutter 内置 Mock 保持一致：
 *   GET /api/v1/contacts?q=关键字
 *   静态 JSON：../assets/mock/contacts.json（或复制到 server/mock/contacts.json）
 */
module.exports.contactsRoute = {
  method: 'GET',
  path: '/contacts',
  asset: 'mock/contacts.json',
  filterQueryKey: 'q',
  filterFields: ['name', 'phone', 'pinyin', 'company'],
};
