import { rcp } from '@kit.RemoteCommunicationKit';
import { HttpRequest } from './HttpRequest';

export interface HttpInterceptor extends rcp.Interceptor {

  /**
   * 请求是否匹配
   * @param request
   * @returns 匹配结果,true:匹配成功; false: 匹配失败;
   */
  matches(request: HttpRequest): boolean;

}