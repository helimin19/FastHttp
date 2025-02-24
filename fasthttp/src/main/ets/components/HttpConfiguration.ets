import { rcp } from '@kit.RemoteCommunicationKit';
import { HttpTracingListener } from './HttpTracingListener';
import { HttpPerformanceListener } from './HttpPerformanceListener';
import { HttpRequest } from './HttpRequest';

/**
 * Http配置
 */
export interface HttpConfiguration  {

  sessionConfiguration(): rcp.SessionConfiguration;

  /**
   * 调试监听
   * @returns HTTP调试监听
   */
  tracingListener(): HttpTracingListener | undefined;

  /**
   * 性能监听
   * @returns HTTP性能监听
   */
  performanceListener(): HttpPerformanceListener  | undefined;

  /**
   * 请求是否匹配
   * @param request
   * @returns 匹配结果,true:匹配成功; false: 匹配失败;
   */
  matches(request: HttpRequest): boolean;

}
