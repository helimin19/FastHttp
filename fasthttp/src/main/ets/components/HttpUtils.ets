
/**
 * 合并两个对象
 * @param target 目标对象
 * @param source 源对象列表
 * @returns 目标对象
 */
export function assign(target: Record<string, Object> = {}, ...source: Object[]): Record<string, Object> {
  for (const items of source) {
    if (items) {
      for (const key of Object.keys(items)) {
        if (Reflect.get(items, key) instanceof Object) {
          target[key] = assign(target[key] as Record<string, Object>, Reflect.get(items, key));
        } else {
          target[key] = Reflect.get(items, key);
        }
      }
    }
  }
  return target;
}

/**
 * 合并两个ArrayBuffer
 * @param buffer1 合并两个ArrayBuffer
 * @param buffer2 合并两个ArrayBuffer
 * @returns 合并后的合并两个ArrayBuffer
 */
export function mergeArrayBuffers(buffer1: ArrayBuffer, buffer2: ArrayBuffer): ArrayBuffer {
  // 计算新ArrayBuffer的总长度
  const totalLength = buffer1.byteLength + buffer2.byteLength;

  // 创建一个新的ArrayBuffer，其长度为两个源ArrayBuffer的总长度
  const mergedBuffer = new ArrayBuffer(totalLength);

  // 创建一个DataView来操作新的ArrayBuffer
  const view = new DataView(mergedBuffer);

  // 将第一个ArrayBuffer的内容复制到新的ArrayBuffer中
  const view1 = new Uint8Array(buffer1);
  for (let i = 0; i < view1.length; i++) {
    view.setUint8(i, view1[i]);
  }

  // 将第二个ArrayBuffer的内容复制到新的ArrayBuffer中，开始于第一个ArrayBuffer之后的位置
  const view2 = new Uint8Array(buffer2);
  for (let i = 0; i < view2.length; i++) {
    view.setUint8(buffer1.byteLength + i, view2[i]);
  }

  // 返回合并后的ArrayBuffer
  return mergedBuffer;
}

/**
 * 取得Record的值，不区分大小写
 * @param record Record对象
 * @param key key
 * @returns value
 */
export function getRecordValue(record: Record<string, string>, key: string): string | undefined {
  const lowerCaseKey = key.toLowerCase();
  const keys = Object.keys(record);
  for (const k of keys) {
    if (k.toLowerCase() === lowerCaseKey) {
      return record[k];
    }
  }
  return "";
}
