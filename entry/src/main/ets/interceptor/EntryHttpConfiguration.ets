import {
  AbstractHttpConfiguration,
  AntPathRequestMatcher, HttpTracingListener,
  HttpRequest } from 'httpProxy';
import { rcp } from '@kit.RemoteCommunicationKit';

export class EntryHttpConfiguration extends AbstractHttpConfiguration {

  getBaseAddress(): rcp.URLOrString {
    return "https://developer.huawei.com";
  }

  tracingListener(): HttpTracingListener {
    return {
      onRequestHeader(context: string) {
        console.log("limin", "requestHeader", context);
      },
      onRequestBody(context: string) {
        console.log("limin", "requestBody", context);
      },
      onResponseHeader(context: string) {
        console.log("limin", "responseHeader", context);
      },
      onResponseBody(context: string) {
        console.log("limin", "responseBody", context);
      },
      onSslIn(context: ArrayBuffer) {
        console.log("limin", "sslIn", context);
      },
      onSslOut(context: ArrayBuffer) {
        console.log("limin", "sslOut", context);
      },
      onText(context: string) {
        console.log("limin", "text", context);
      }
    } as HttpTracingListener;
  }

  matches(request: HttpRequest): boolean {
    const antPathRequestMatcher = new AntPathRequestMatcher("https://developer.huawei.com/**");
    return antPathRequestMatcher.matches(request);
  }

}