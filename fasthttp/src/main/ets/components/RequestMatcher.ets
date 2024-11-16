import { HttpRequest } from './HttpRequest'

/**
 * 请求匹配器
 */
export interface RequestMatcher {

  /**
   * 请求是否匹配
   * @param request
   * @returns 匹配结果,true:匹配成功; false: 匹配失败;
   */
  matches(request: HttpRequest): boolean;

}