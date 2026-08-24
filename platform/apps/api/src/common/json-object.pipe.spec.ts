import { BadRequestException } from '@nestjs/common';
import { JsonObjectPipe } from './json-object.pipe';

describe('JsonObjectPipe', () => {
  const pipe = new JsonObjectPipe();

  it('accepts plain objects', () => {
    expect(pipe.transform({ foo: 'bar' })).toEqual({ foo: 'bar' });
  });

  it('rejects arrays', () => {
    expect(() => pipe.transform([])).toThrow(BadRequestException);
  });

  it('rejects null', () => {
    expect(() => pipe.transform(null)).toThrow(BadRequestException);
  });

  it('rejects primitives', () => {
    expect(() => pipe.transform('text')).toThrow(BadRequestException);
  });
});
