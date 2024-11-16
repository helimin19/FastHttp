import { rcp } from "@kit.RemoteCommunicationKit";
import { HttpInterceptor, HttpRequest } from "httpProxy";

export class TempInterceptor implements HttpInterceptor {

  matches(_request: HttpRequest): boolean {

    return true;
  }

  intercept(context: rcp.RequestContext, next: rcp.RequestHandler): Promise<rcp.Response> {
    return next.handle(context);
  }

}