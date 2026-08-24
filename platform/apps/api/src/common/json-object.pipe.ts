import {
  BadRequestException,
  Injectable,
  PipeTransform,
} from '@nestjs/common';

/** 校验请求体为 JSON 对象（非数组 / null / 原始类型）。 */
@Injectable()
export class JsonObjectPipe implements PipeTransform {
  transform(value: unknown) {
    if (value === null || typeof value !== 'object' || Array.isArray(value)) {
      throw new BadRequestException('Body must be a JSON object');
    }
    return value as Record<string, unknown>;
  }
}
