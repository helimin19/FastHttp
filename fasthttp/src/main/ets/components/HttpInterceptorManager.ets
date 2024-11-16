import { HttpInterceptor } from './HttpInterceptor';
import { HttpRequest } from './HttpRequest';
import { rcp } from '@kit.RemoteCommunicationKit';

/**
 * HTTP拦截器管理
 */
export class HttpInterceptorManager {

  private static instance: HttpInterceptorManager;

  public static getInstance(): HttpInterceptorManager {
    if (!HttpInterceptorManager.instance) {
      HttpInterceptorManager.instance = new HttpInterceptorManager();
    }
    return HttpInterceptorManager.instance;
  }

  private interceptors = new Array<HttpInterceptor>();

  private constructor() {
  }

  /**
   * 注册请求拦截器
   * @param interceptor 请求拦截器
   */
  public register(interceptor: HttpInterceptor) {
    this.interceptors.push(interceptor);
  }

  /**
   * 取得Request匹配的请求拦截器
   * @param request 请求
   * @returns 请求拦截器列表
   */
  public getInterceptors(request: HttpRequest): Array<rcp.Interceptor> {
    return this.interceptors.filter(interceptor => interceptor.matches(request));
  }

}