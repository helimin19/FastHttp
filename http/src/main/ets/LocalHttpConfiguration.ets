import {
  AbstractHttpConfiguration,
  AntPathRequestMatcher, HttpTracingListener,
  HttpPerformanceListener,
  HttpRequest } from 'fasthttp';
import { rcp } from '@kit.RemoteCommunicationKit';

export class LocalHttpConfiguration extends AbstractHttpConfiguration {

  getBaseAddress(): rcp.URLOrString {
    return  "http://192.168.100.2:8080";
  }

　 tracingListener(): HttpTracingListener {
    return {
      onRequestHeader(context: string) {
        console.log("limin-1", "requestHeader", context);
      },
      onRequestBody(context: string) {
        console.log("limin-1", "requestBody", context);
      },
      onResponseHeader(context: string) {
        console.log("limin-1", "responseHeader", context);
      },
      onResponseBody(context: string) {
        console.log("limin-1", "responseBody", context);
      },
      onSslIn(context: ArrayBuffer) {
        console.log("limin-1", "sslIn", context);
      },
      onSslOut(context: ArrayBuffer) {
        console.log("limin-1", "sslOut", context);
      },
      onText(context: string) {
        console.log("limin-1", "text", context);
      }
    } as HttpTracingListener;
  }

  performanceListener(): HttpPerformanceListener {
    return {
      onPerformance(timeInfo: rcp.TimeInfo) {
        console.log("limin-1", "timeInfo", JSON.stringify(timeInfo));
      }
    } as HttpPerformanceListener;
  }

  matches(request: HttpRequest): boolean {
    const antPathRequestMatcher = new AntPathRequestMatcher("http://192.168.100.2:8080/**");
    return antPathRequestMatcher.matches(request) || 99 === request.getTag("type");
  }

}