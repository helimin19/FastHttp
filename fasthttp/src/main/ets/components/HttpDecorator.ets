import { FastHttp } from "./FastHttp";
import { HttpMethod, HttpRequest, JsonHttpRequest } from "./HttpRequest";

/**
 * 请求头装饰器
 * @param header 请求头信息
 * @returns 装饰器方法
 */
export function Header(header: Record<string, string>) {
  // 这个装饰器是一个方法
  return (target: Object, methodName: string, descriptor: PropertyDescriptor) => {
    Reflect.set(target, `__header__${methodName}`, header);
  }
}

/**
 * 变量装饰器
 * @param name 变量名称
 * @returns 装饰器方法
 */
export function Variable(name: string) {
  return (target: Object, methodName: string, parameterIndex: number) => {
    let variables = Reflect.get(target, `__variable__${methodName}`) as Record<string, Object>;
    if (!variables) {
      variables = {};
    }
    variables[name] = parameterIndex;
    Reflect.set(target, `__variable__${methodName}`, variables);
  }
}

/**
 * 请求体装饰器
 * @param target 类
 * @param methodName 方法名称
 * @param parameterIndex 请求体是第几个参数, 一个方法的参数中只需要有一个请求体装饰器
 */
export function RequestBody(target: Object, methodName: string, parameterIndex: number) {
  Reflect.set(target, `__request_body__${methodName}`, parameterIndex);
}

/**
 * 请求装饰器
 * @param request 请求对象
 * @returns 装饰器方法
 */
export function Request(request: JsonHttpRequest) {
  // 这是一个方法装饰器
  return (target: Object, methodName: string, descriptor: PropertyDescriptor) => {
    // 获取原来的方法
    const originalMethod = descriptor.value as Function;
    Reflect.set(target,`__request__${methodName}`, request);

    // 重写原来的方法
    descriptor.value = (...args: Object[]) => {
      const variables = getVariables(target, methodName, ...args);

      let requestEntity: JsonHttpRequest = Reflect.get(target, `__request__${methodName}`);
      requestEntity = replaceVariablesOfObject(requestEntity, variables) as JsonHttpRequest;

      const http: FastHttp = new FastHttp();
      const request: HttpRequest = new HttpRequest(requestEntity);

      const promise = http.request<Object>(request);
      args.push(promise);

      const result: Promise<Object> | undefined = originalMethod(...args);
      return result;

    };
  };
}

/**
 * GET请求
 * @param url 请求的URL
 * @returns 装饰器方法
 */
export function GET(url: string) {
  return (target: Object, methodName: string, descriptor: PropertyDescriptor) => {
    // 获取原来的方法
    const originalMethod = descriptor.value as Function;
    Reflect.set(target,`__url__get__${methodName}`, url);

    // 重写原来的方法
    descriptor.value = (...args: Object[]) => {
      const variables = getVariables(target, methodName, ...args);

      const http: FastHttp = new FastHttp();
      const request: HttpRequest = new HttpRequest();

      // 这个url不能为空
      let url = Reflect.get(target, `__url__get__${methodName}`) as string;
      // 替换url中的变量, 并设置URL
      url = replaceVariables(url, variables) as string;
      request.setUrl(url);

      // 添加请求头
      appendToHeader(request, target, methodName, variables);

      const promise = http.request<Object>(request);
      args.push(promise);

      const result: Promise<Object> | undefined = originalMethod(...args);
      return result;
    }
  }
}

/**
 * POST请求
 * @param url 请求的URL
 * @param body 请求体
 * @returns 装饰器方法
 */
export function POST(url: string) {
  return (target: Object, methodName: string, descriptor: PropertyDescriptor) => {
    // 获取原来的方法
    const originalMethod = descriptor.value as Function;
    Reflect.set(target,`__url__post__${methodName}`, url);

    // 重写原来的方法
    descriptor.value = (...args: Object[]) => {
      const variables = getVariables(target, methodName, ...args);

      const http: FastHttp = new FastHttp();
      const request: HttpRequest = new HttpRequest();
      request.setMethod(HttpMethod.POST);

      // 这个url不能为空
      let url = Reflect.get(target, `__url__post__${methodName}`) as string;
      // 替换url中的变量, 并设置URL
      url = replaceVariables(url, variables) as string;
      request.setUrl(url);

      // 设置请求体
      const requestBodyParameterIndex = Reflect.get(target, `__request_body__${methodName}`) as number;
      if (requestBodyParameterIndex !== undefined && requestBodyParameterIndex >= 0) {
        const body = args[requestBodyParameterIndex];
        request.setBody(body);
      }

      // 添加请求头
      appendToHeader(request, target, methodName, variables);

      const promise = http.request<Object>(request);
      args.push(promise);

      const result: Promise<Object> | undefined = originalMethod(...args);
      return result;
    }
  }
}

/**
 * 添加请求头
 * @param request 请求对象
 * @param target 类名称
 * @param methodName 方法名称
 * @param variables 变量映射关系
 */
function appendToHeader(request: HttpRequest, target: Object, methodName: string, variables: Record<string, Object>): void {
  const header = Reflect.get(target, `__header__${methodName}`) as Record<string, string>;
  if (header) {
    // 替换请求头串的变量, 并添加请求头
    Object.keys(header).forEach((key) => {
      const value = replaceVariables(header[key], variables) as string;
      // 下面的value有可能不是字符串，所以需要转换成字符串
      request.addHeader(key, `${value}`);
    });
  }
}

/**
 * 取得方法的所有变量映射关系
 * @param target 类名称
 * @param methodName 方法名称
 * @param args 方法的参数
 * @returns 变量映射关系
 */
function getVariables(target: Object, methodName: string, ...args: Object[]): Record<string, Object> {
  const variables: Record<string, Object> = {};
  const indexVariables = Reflect.get(target, `__variable__${methodName}`) as Record<string, number>;
  if (indexVariables) {
    Object.keys(indexVariables).forEach((key) => {
      variables[key] = args[indexVariables[key]];
    });
  }
  return variables;
}

/**
 * 替换对象变量
 * @param text 要替换的字符串文本
 * @param args 参数
 * @returns 替换后的文本
 */
function replaceVariablesOfObject(entity: Object, args: Record<string, Object>): Object {
  Reflect.ownKeys(entity).forEach(name => {
    name = name as string;
    let value = Reflect.get(entity, name) as Object;
    if (typeof(value) === "object") {
      value = replaceVariablesOfObject(value, args);
    } else {
      value = replaceVariables(value, args);
    }
    Reflect.set(entity, name, value);
  });

  return entity;
}

/**
 * 替换变量
 * @param text 要替换的字符串文本
 * @param args 参数
 * @returns 替换后的文本
 */
function replaceVariables(text: string, args: Record<string, Object>): Object {
  if (!args || args.length === 0) {
    return text;
  }

  // 使用正则表达式获取字符串中的{}之间的文字
  const items = extractStringsInBraces(text);

  if (items.length === 1 && `{${items[0]}}` === text) {
    // 一般用于处理对象number/boolean类型的值
    return args[items[0]];
  }

  items.forEach((item: string) => {
    text = text.replace(`{${item}}`, args[item] as string);
  });
  return text;
}

/**
 * 提取{}中的字符串
 * @param input 需要提取的字符串
 * @returns {}中的字符串数组
 */
function extractStringsInBraces(input: string): string[] {
  // 正则表达式匹配 {} 之间的内容
  const regex = /\{([^}]+)\}/g;
  const matches: string[] = [];
  let match: RegExpExecArray | null = null;
  // 使用 exec 方法遍历所有匹配项
  while ((match = regex.exec(input)) !== null) {
    // match[1] 是捕获组中的内容，即 {} 之间的字符串
    matches.push(match[1]);
  }

  return matches;
}
