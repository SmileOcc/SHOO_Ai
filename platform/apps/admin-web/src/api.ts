import axios from 'axios';

export type Envelope<T> = {
  code: number;
  message: string;
  data: T;
};

const client = axios.create({
  baseURL: import.meta.env.VITE_API_BASE || '/api',
});

client.interceptors.request.use((config) => {
  const token = localStorage.getItem('shoo_admin_token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

client.interceptors.response.use((response) => {
  const body = response.data as Envelope<unknown>;
  if (body && typeof body === 'object' && 'code' in body && body.code !== 0) {
    return Promise.reject(new Error(body.message || 'Request failed'));
  }
  return response;
});

export async function apiGet<T>(url: string, params?: object): Promise<T> {
  const res = await client.get<Envelope<T>>(url, { params });
  return res.data.data;
}

export async function apiPost<T>(url: string, data?: object): Promise<T> {
  const res = await client.post<Envelope<T>>(url, data);
  return res.data.data;
}

export async function apiPatch<T>(url: string, data?: object): Promise<T> {
  const res = await client.patch<Envelope<T>>(url, data);
  return res.data.data;
}

export async function apiPut<T>(url: string, data?: object): Promise<T> {
  const res = await client.put<Envelope<T>>(url, data);
  return res.data.data;
}

export async function apiDelete<T>(url: string): Promise<T> {
  const res = await client.delete<Envelope<T>>(url);
  return res.data.data;
}

export default client;
