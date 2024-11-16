import { rcp } from '@kit.RemoteCommunicationKit'
import { ValueType } from '@kit.ArkData';

/**
 * 请求方式
 */
export enum HttpMethod {
  GET = 'GET',
  POST = 'POST',
  HEAD = 'HEAD',
  PUT = 'PUT',
  DELETE = 'DELETE',
  PATCH = 'PATCH',
  OPTIONS = 'OPTIONS'
}

/**
 * JSON请求对象
 */
export interface JsonHttpRequest {
  url: rcp.URLOrString;
  method: HttpMethod;
  headers?: rcp.RequestHeaders;
  body?: rcp.RequestContent;
  cookies?: rcp.RequestCookies;
  transferRange?: rcp.TransferRange | rcp.TransferRange[];
  configuration?: rcp.Configuration;
  tags?: Map<string, object | string | number | boolean>;
}


/**
 * HTTP请求
 */
export class HttpRequest {

  public jsonRequest: JsonHttpRequest = {
    url: "",
    method: HttpMethod.GET
  };

  interceptors?: rcp.Interceptor[] = [];

  constructor(json?: JsonHttpRequest | string) {
    if (json) {
      if (typeof(json) === "string") {
        try {
          this.jsonRequest = JSON.parse(json as string) as JsonHttpRequest
        } catch(e) {
          this.jsonRequest.url = json;
        }
      } else {
        this.jsonRequest = json as JsonHttpRequest;
      }
    }
  }

  get url(): rcp.URLOrString {
    return this.jsonRequest.url;
  }

  /**
   * 取得标志
   * @param key 标志的Key
   * @returns 标志的值，不存在返回undefined
   */
  public getTag(key: string): object | string | number | boolean | undefined {
    if (this.jsonRequest.tags?.has(key)) {
      return this.jsonRequest.tags.get(key);
    }
    return undefined;
  }

  /**
   * 设置请求地址
   * @param url 请求地址
   * @returns HttpRequest
   */
  public setUrl(url: rcp.URLOrString) {
    this.jsonRequest.url = url;
    return this;
  }

  /**
   * 设置请求方式
   * @param method 请求方式
   * @returns HttpRequest
   */
  public setMethod(method: HttpMethod) {
    this.jsonRequest.method = method;
    return this;
  }

  /**
   * 添加请求头
   * @param name 请求头名称
   * @param value 请求头值
   * @returns HttpRequest
   */
  public addHeader(name: string, value: string | string[] | undefined) {
   if (!this.jsonRequest.headers) {
     this.jsonRequest.headers = {};
   }
   this.jsonRequest.headers[name] = value;
   return this;
  }

  /**
   * 添加cookie
   * @param name cookie名称
   * @param value cookie值
   * @returns HttpRequest
   */
  public addCookie(name: string, value: string) {
    if (!this.jsonRequest.cookies) {
      this.jsonRequest.cookies = {};
    }
    this.jsonRequest.cookies[name] = value;
    return this;
  }

  /**
   * 设置传输范围（HTTP Range头）
   * @param from 开始位置
   * @param to 结束位置
   * @returns HttpRequest
   */
  public setTransferRange(from?: number, to?: number) {
    this.jsonRequest.transferRange = {
      from: from,
      to: to
    }
    return this;
  }

  /**
   * 设置超时时间
   * @param timeout 超时时间
   * @returns HttpRequest
   */
  public setTimeout(timeout: number) {
    if (!this.jsonRequest.configuration) {
      this.jsonRequest.configuration = {};
    }
    if (!this.jsonRequest.configuration.transfer) {
      this.jsonRequest.configuration.transfer = {};
    }
    if (!this.jsonRequest.configuration.transfer.timeout) {
      this.jsonRequest.configuration.transfer.timeout = {}
    }
    this.jsonRequest.configuration.transfer.timeout.connectMs = timeout;
    this.jsonRequest.configuration.transfer.timeout.transferMs = timeout;
    return this;
  }

  /**
   * 是否启动跟踪信息
   * @param enabled 是否启动
   * @returns HttpRequest
   */
  public enabledTracing(enabled: boolean) {
    if (!this.jsonRequest.configuration) {
      this.jsonRequest.configuration = {};
    }
    if (!this.jsonRequest.configuration.tracing) {
      this.jsonRequest.configuration.tracing = {};
    }
    this.jsonRequest.configuration.tracing.verbose = enabled;
    this.jsonRequest.configuration.tracing.collectTimeInfo = enabled;
    this.jsonRequest.configuration.tracing.infoToCollect = {
      textual: enabled,
      incomingHeader: enabled,
      outgoingHeader: enabled,
      incomingData: enabled,
      outgoingData: enabled,
      incomingSslData: enabled,
      outgoingSslData: enabled
    };
    return this;
  }

  /**
   * 设置请求体
   * @param content 请求体
   * @returns HttpRequest
   */
  public setBody(content: string | ArrayBuffer | object | rcp.Form | rcp.MultipartForm | rcp.GetDataCallback | rcp.GetDataCallback | rcp.UploadFromStream) {
    this.jsonRequest.body = content;
    return this;
  }

  /**
   * 添加标志
   * @param key 标志的key
   * @param value 标志的值
   * @returns HttpRequest
   */
  public addTag(key: string, value: object | string | number | boolean) {
    if (!this.jsonRequest.tags) {
      this.jsonRequest.tags = new Map();
    }
    this.jsonRequest.tags.set(key, value);
    return this;
  }

  public addInterceptor(interceptor: rcp.Interceptor) {
    this.interceptors?.push(interceptor);
    return this;
  }

  public setDownloadProgress(handler: rcp.OnDownloadProgress) {
    if (!this.jsonRequest.configuration) {
      this.jsonRequest.configuration = {};
    }
    if (!this.jsonRequest.configuration.tracing) {
      this.jsonRequest.configuration.tracing = {};
    }
    if (!this.jsonRequest.configuration.tracing.httpEventsHandler) {
      this.jsonRequest.configuration.tracing.httpEventsHandler = {}
    }
    this.jsonRequest.configuration.tracing.httpEventsHandler.onDownloadProgress = handler;
    return this;
  }

  /**
   * 创建Http请求对象
   * @returns Http请求对象
   */
  public builder() {
    return new rcp.Request(this.jsonRequest.url, this.jsonRequest.method, this.jsonRequest.headers, this.jsonRequest.body, this.jsonRequest.cookies, this.jsonRequest.transferRange, this.jsonRequest.configuration);
  }

}