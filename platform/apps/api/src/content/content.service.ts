import { Injectable } from '@nestjs/common';
import { DocumentsService } from '../documents/documents.service';

@Injectable()
export class ContentService {
  constructor(private readonly docs: DocumentsService) {}

  async communityFeed(sort?: string) {
    const payload = await this.docs.getPayload<{
      menuItems?: unknown[];
      items?: Array<Record<string, unknown>>;
      [key: string]: unknown;
    }>('community_feed');

    const items = Array.isArray(payload.items)
      ? payload.items.map((e) => ({ ...e }))
      : [];

    const mode = sort ?? 'all';
    items.sort((a, b) => {
      if (mode === 'latest') {
        return String(b.publishedAt ?? '').localeCompare(
          String(a.publishedAt ?? ''),
        );
      }
      if (mode === 'hot') {
        return Number(b.hotScore ?? 0) - Number(a.hotScore ?? 0);
      }
      return 0;
    });

    return { ...payload, items };
  }

  documents() {
    return this.docs.getPayload('documents');
  }
}
