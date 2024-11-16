import { AntPathRequestMatcher, HttpInterceptor, HttpRequest } from "fasthttp";
import { rcp } from "@kit.RemoteCommunicationKit";
import { BusinessError } from "@kit.BasicServicesKit";
import { JSON, util } from "@kit.ArkTS";

export class ResultInterceptor implements HttpInterceptor {

  request?: HttpRequest;

  matches(request: HttpRequest): boolean {
    this.request = request;
    const antPathRequestMatcher = new AntPathRequestMatcher("http://192.168.100.66:8080/**");
    return antPathRequestMatcher.matches(request);
  }

  intercept(context: rcp.RequestContext, next: rcp.RequestHandler): Promise<rcp.Response> {
    return new Promise((resolve, reject) => {
      next.handle(context).then((response: rcp.Response) => {
        let decoder = util.TextDecoder.create('utf-8');
        const contentType = response!.headers['content-type'];
        if (contentType?.toLowerCase().includes('application/json')) {
          let json = decoder.decodeToString(new Uint8Array(response!.body));
          let result: Object, isResult:boolean;
          try {
            result = JSON.parse(json) as object;
            isResult = Reflect.has(result, "code") && Reflect.has(result, "message") && Reflect.has(result, "data");
          } catch (e) {
            resolve(response);
            return;
          }

          if (!isResult) {
            resolve(response);
            return;
          }
          const data = Reflect.get(result, "data") as object;
          resolve({
            request: response.request,
            statusCode: response.statusCode,
            headers: response.headers,
            effectiveUrl: response.effectiveUrl,
            body: util.TextEncoder.create("utf-8").encodeInto(JSON.stringify(data)),
            downloadedTo: response.downloadedTo,
            debugInfo: response.debugInfo,
            timeInfo: response.timeInfo,
            cookies: response.cookies,
            httpVersion: response.httpVersion,
            reasonPhrase: response.reasonPhrase,
            toString: (): string | null => {
              return json;
            },
            toJSON:(): object | null => {
              return data;
            }
          });
        } else {
          resolve(response);
        }
      }).catch((error: BusinessError) => {
        reject(error);
      })
    });
  }

}
