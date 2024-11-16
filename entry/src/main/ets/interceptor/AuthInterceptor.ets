import { AntPathRequestMatcher, HttpInterceptor, HttpRequest } from 'httpProxy';
import { rcp } from '@kit.RemoteCommunicationKit';


export class AuthInterceptor implements HttpInterceptor {

  request?: HttpRequest;

  /**
   * 请求的Request是否匹配当前配置档
   * @param request 请求信息
   * @returns true: request请求使用这个配置档; false: request请求不使用这个配置档
   */
  matches(request: HttpRequest): boolean {
    this.request = request;
    // const antPathRequestMatcher = new AntPathRequestMatcher("https://developer.huawei.com/**");
    // return antPathRequestMatcher.matches(request);
    return true;
  }

  intercept(context: rcp.RequestContext, next: rcp.RequestHandler): Promise<rcp.Response> {
    if (!context.request.headers) {
      context.request.headers = {};
    }
    context.request.headers["token"] = "认证token";

console.log("limin-99", context.session.configuration?.baseAddress, "" + this.request?.jsonRequest.url);
    return next.handle(context);
  }

}