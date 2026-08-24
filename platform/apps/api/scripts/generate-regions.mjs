/**
 * Generates CN (full province/city/district) + US (state/city) region shards.
 * Run: node scripts/generate-regions.mjs
 */
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const API_DATA = path.resolve(__dirname, '../src/region/data');
const FLUTTER_DATA = path.resolve(
  __dirname,
  '../../../../assets/mock/regions',
);

const CN_SOURCES = {
  provinces:
    'https://cdn.jsdelivr.net/gh/modood/Administrative-divisions-of-China@master/dist/provinces.json',
  cities:
    'https://cdn.jsdelivr.net/gh/modood/Administrative-divisions-of-China@master/dist/cities.json',
  areas:
    'https://cdn.jsdelivr.net/gh/modood/Administrative-divisions-of-China@master/dist/areas.json',
};

const US_STATES = [
  { code: 'AL', name: 'Alabama' },
  { code: 'AK', name: 'Alaska' },
  { code: 'AZ', name: 'Arizona' },
  { code: 'AR', name: 'Arkansas' },
  { code: 'CA', name: 'California' },
  { code: 'CO', name: 'Colorado' },
  { code: 'CT', name: 'Connecticut' },
  { code: 'DE', name: 'Delaware' },
  { code: 'DC', name: 'District of Columbia' },
  { code: 'FL', name: 'Florida' },
  { code: 'GA', name: 'Georgia' },
  { code: 'HI', name: 'Hawaii' },
  { code: 'ID', name: 'Idaho' },
  { code: 'IL', name: 'Illinois' },
  { code: 'IN', name: 'Indiana' },
  { code: 'IA', name: 'Iowa' },
  { code: 'KS', name: 'Kansas' },
  { code: 'KY', name: 'Kentucky' },
  { code: 'LA', name: 'Louisiana' },
  { code: 'ME', name: 'Maine' },
  { code: 'MD', name: 'Maryland' },
  { code: 'MA', name: 'Massachusetts' },
  { code: 'MI', name: 'Michigan' },
  { code: 'MN', name: 'Minnesota' },
  { code: 'MS', name: 'Mississippi' },
  { code: 'MO', name: 'Missouri' },
  { code: 'MT', name: 'Montana' },
  { code: 'NE', name: 'Nebraska' },
  { code: 'NV', name: 'Nevada' },
  { code: 'NH', name: 'New Hampshire' },
  { code: 'NJ', name: 'New Jersey' },
  { code: 'NM', name: 'New Mexico' },
  { code: 'NY', name: 'New York' },
  { code: 'NC', name: 'North Carolina' },
  { code: 'ND', name: 'North Dakota' },
  { code: 'OH', name: 'Ohio' },
  { code: 'OK', name: 'Oklahoma' },
  { code: 'OR', name: 'Oregon' },
  { code: 'PA', name: 'Pennsylvania' },
  { code: 'RI', name: 'Rhode Island' },
  { code: 'SC', name: 'South Carolina' },
  { code: 'SD', name: 'South Dakota' },
  { code: 'TN', name: 'Tennessee' },
  { code: 'TX', name: 'Texas' },
  { code: 'UT', name: 'Utah' },
  { code: 'VT', name: 'Vermont' },
  { code: 'VA', name: 'Virginia' },
  { code: 'WA', name: 'Washington' },
  { code: 'WV', name: 'West Virginia' },
  { code: 'WI', name: 'Wisconsin' },
  { code: 'WY', name: 'Wyoming' },
];

async function fetchJson(url) {
  const res = await fetch(url);
  if (!res.ok) throw new Error(`Failed to fetch ${url}: ${res.status}`);
  return res.json();
}

function node(code, name, level, countryCode, parentCode, hasChildren) {
  return {
    code,
    name,
    nameEn: name,
    level,
    countryCode,
    parentCode: parentCode ?? '',
    hasChildren: !!hasChildren,
  };
}

function writeShard(dir, country, parentCode, items) {
  const key = parentCode || 'root';
  const folder = path.join(dir, 'children', country);
  fs.mkdirSync(folder, { recursive: true });
  fs.writeFileSync(
    path.join(folder, `${key}.json`),
    JSON.stringify(
      {
        countryCode: country,
        parentCode: parentCode ?? '',
        items,
      },
      null,
      0,
    ),
  );
}

function copyDir(src, dest) {
  fs.mkdirSync(dest, { recursive: true });
  for (const entry of fs.readdirSync(src, { withFileTypes: true })) {
    const from = path.join(src, entry.name);
    const to = path.join(dest, entry.name);
    if (entry.isDirectory()) copyDir(from, to);
    else fs.copyFileSync(from, to);
  }
}

async function buildChina(dir) {
  const [provinces, cities, areas] = await Promise.all([
    fetchJson(CN_SOURCES.provinces),
    fetchJson(CN_SOURCES.cities),
    fetchJson(CN_SOURCES.areas),
  ]);

  const citiesByProvince = new Map();
  for (const city of cities) {
    const list = citiesByProvince.get(city.provinceCode) ?? [];
    list.push(city);
    citiesByProvince.set(city.provinceCode, list);
  }

  const areasByCity = new Map();
  for (const area of areas) {
    const list = areasByCity.get(area.cityCode) ?? [];
    list.push(area);
    areasByCity.set(area.cityCode, list);
  }

  const provinceNodes = provinces.map((p) =>
    node(p.code, p.name, 2, 'CN', 'CN', true),
  );
  writeShard(dir, 'CN', 'CN', provinceNodes);

  for (const province of provinces) {
    const cityList = citiesByProvince.get(province.code) ?? [];
    const cityNodes = cityList.map((c) =>
      node(c.code, c.name, 3, 'CN', province.code, true),
    );
    writeShard(dir, 'CN', province.code, cityNodes);

    for (const city of cityList) {
      const areaList = areasByCity.get(city.code) ?? [];
      const areaNodes = areaList.map((a) =>
        node(a.code, a.name, 4, 'CN', city.code, false),
      );
      writeShard(dir, 'CN', city.code, areaNodes);
    }
  }

  return {
    provinces: provinces.length,
    cities: cities.length,
    areas: areas.length,
  };
}

async function buildUs(dir) {
  const { State, City } = await import('country-state-city');

  const states = State.getStatesOfCountry('US') ?? [];
  const stateNodes = states.map((s) =>
    node(s.isoCode, s.name, 2, 'US', 'US', true),
  );
  writeShard(dir, 'US', 'US', stateNodes);

  let totalCities = 0;
  for (const state of states) {
    const cities = City.getCitiesOfState('US', state.isoCode) ?? [];
    const seen = new Set();
    const cityNodes = [];
    for (const city of cities) {
      const code = `${state.isoCode}-${slug(city.name)}`;
      if (seen.has(code)) continue;
      seen.add(code);
      cityNodes.push(node(code, city.name, 3, 'US', state.isoCode, false));
    }
    cityNodes.sort((a, b) => a.name.localeCompare(b.name));
    if (cityNodes.length === 0) {
      cityNodes.push(
        node(`${state.isoCode}-main`, `${state.name} City`, 3, 'US', state.isoCode, false),
      );
    }
    writeShard(dir, 'US', state.isoCode, cityNodes);
    totalCities += cityNodes.length;
  }

  return { states: states.length, cities: totalCities };
}

function slug(name) {
  return name
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '')
    .slice(0, 40);
}

async function main() {
  fs.rmSync(API_DATA, { recursive: true, force: true });
  fs.mkdirSync(API_DATA, { recursive: true });

  const meta = {
    dataVersion: `v1-${new Date().toISOString().slice(0, 10)}`,
    countries: [
      {
        countryCode: 'CN',
        name: '中国',
        nameEn: 'China',
        maxLevel: 4,
        requiredLevels: [1, 2, 3, 4],
        labels: { '2': '省份', '3': '城市', '4': '区/县' },
      },
      {
        countryCode: 'US',
        name: '美国',
        nameEn: 'United States',
        maxLevel: 3,
        requiredLevels: [1, 2, 3],
        labels: { '2': '州', '3': '城市' },
      },
    ],
  };

  const countries = [
    node('CN', '中国', 1, 'CN', '', true),
    node('US', '美国', 1, 'US', '', true),
  ];

  fs.writeFileSync(path.join(API_DATA, 'meta.json'), JSON.stringify(meta));
  fs.writeFileSync(
    path.join(API_DATA, 'countries.json'),
    JSON.stringify({ items: countries }),
  );

  console.log('Building China regions...');
  const cnStats = await buildChina(API_DATA);
  console.log('CN stats:', cnStats);

  console.log('Building US regions...');
  const usStats = await buildUs(API_DATA);
  console.log('US stats:', usStats);

  meta.stats = { cn: cnStats, us: usStats };
  fs.writeFileSync(path.join(API_DATA, 'meta.json'), JSON.stringify(meta));

  fs.rmSync(FLUTTER_DATA, { recursive: true, force: true });
  copyDir(API_DATA, FLUTTER_DATA);
  console.log('Done. API:', API_DATA);
  console.log('Flutter mock:', FLUTTER_DATA);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
