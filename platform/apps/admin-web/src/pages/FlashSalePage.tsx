import JsonDocumentEditor from '../components/JsonDocumentEditor';
import { useJsonDocument } from '../hooks/useJsonDocument';

export default function FlashSalePage() {
  const { jsonText, setJsonText, loading, load, save } = useJsonDocument({
    path: '/admin/v1/marketing/flash-sale-catalog',
    successMessage: '闪购配置已保存',
  });

  return (
    <JsonDocumentEditor
      title="闪购配置"
      description={
        <>
          编辑 <code>flash_sale_catalog</code> 文档，包含场次模板、优惠券、商品等。
          App 端 <code>GET /flash-sale/*</code> 接口读取此配置。
        </>
      }
      jsonText={jsonText}
      loading={loading}
      onChange={setJsonText}
      onReload={() => void load()}
      onSave={() => void save()}
    />
  );
}
