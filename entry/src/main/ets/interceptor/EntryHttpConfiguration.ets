import { AntPathRequestMatcher, HttpConfiguration, HttpDebugListener,
  HttpPerformanceListener,
  HttpRequest } from 'httpProxy';
import { rcp } from '@kit.RemoteCommunicationKit';

export class EntryHttpConfiguration implements HttpConfiguration {

  private _sessionConfiguration: rcp.SessionConfiguration = {
    baseAddress: "https://developer.huawei.com",
    requestConfiguration: {
      tracing: {
        verbose: true,
        infoToCollect: {
          incomingHeader:true,
          incomingData: true,
          outgoingHeader: true,
          outgoingData: true
        }
      }
    }
  };

  sessionConfiguration(): rcp.SessionConfiguration {
    return this._sessionConfiguration;
  }

  debugListener(): HttpDebugListener {
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
    } as HttpDebugListener;
  }

  performanceListener(): HttpPerformanceListener | undefined {
    return undefined;
  }

  matches(request: HttpRequest): boolean {
    const antPathRequestMatcher = new AntPathRequestMatcher("https://developer.huawei.com/**");
    return antPathRequestMatcher.matches(request);
  }

}