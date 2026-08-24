import { useCallback, useEffect, useState } from 'react';
import { message } from 'antd';
import { apiGet, apiPut } from '../api';

type UseJsonDocumentOptions = {
  path: string;
  successMessage?: string;
};

export function useJsonDocument({
  path,
  successMessage = '已保存',
}: UseJsonDocumentOptions) {
  const [jsonText, setJsonText] = useState('{}');
  const [loading, setLoading] = useState(false);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const data = await apiGet<unknown>(path);
      setJsonText(JSON.stringify(data ?? {}, null, 2));
    } finally {
      setLoading(false);
    }
  }, [path]);

  useEffect(() => {
    void load();
  }, [load]);

  const save = useCallback(async () => {
    setLoading(true);
    try {
      const payload = JSON.parse(jsonText) as unknown;
      await apiPut(path, payload);
      message.success(successMessage);
    } catch (error) {
      message.error(error instanceof Error ? error.message : 'JSON 格式错误');
      throw error;
    } finally {
      setLoading(false);
    }
  }, [jsonText, path, successMessage]);

  return {
    jsonText,
    setJsonText,
    loading,
    load,
    save,
  };
}
