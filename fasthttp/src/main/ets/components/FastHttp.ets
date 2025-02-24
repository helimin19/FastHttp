import { rcp } from '@kit.RemoteCommunicationKit'
import { HttpInterceptorManager } from './HttpInterceptorManager';
import { HttpRequest } from './HttpRequest';
import { BusinessError } from '@kit.BasicServicesKit';
import { url, util } from '@kit.ArkTS';
import { HttpException } from './exception/HttpException';
import { HttpConfiguration } from './HttpConfiguration';
import { HttpConfigurationManager } from './HttpConfigurationManager';
import { DefaultHttpConfiguration } from './DefaultHttpConfiguration';

import { assign, getRecordValue, mergeArrayBuffers } from './HttpUtils';
import { fileIo } from '@kit.CoreFileKit';
import { DownloadFile } from './DownloadFile';

/**
 * 快速Http
 */
export class FastHttp {

  private httpConfiguration: HttpConfiguration;
  private tags?: Map<string, object | string | number | boolean>;

  constructor(tags?: Map<string, object | string | number | boolean>) {
    this.tags = tags;
    this.httpConfiguration = new DefaultHttpConfiguration();
  }

  /**httpConfiguration
   * 创建HttpSession
   * @param request HttpRequest
   * @returns Session
   */
  public createSession(request: HttpRequest): rcp.Session {
    this.tags?.forEach((value, key) => {
      if (!request.jsonRequest.tags?.has(key)) {
        // 保证请求的tag优化
        request.addTag(key, value);
      }
    });
    this.httpConfiguration = HttpConfigurationManager.getInstance().getHttpConfiguration(request);

    const sessionConfiguration = this.httpConfiguration.sessionConfiguration();
    // 设置session的baseAddress
    if (!sessionConfiguration.baseAddress) {
      let link:url.URL;
      if (request.url instanceof url.URL) {
        link = request.url as url.URL;
      } else {
        link =  url.URL.parseURL(request.url);
      }
      sessionConfiguration.baseAddress = link.origin;
    }

    // 更新请求的url地址
    if (request.url.toString().startsWith("/")) {
      request.jsonRequest.url = `${sessionConfiguration.baseAddress}${request.jsonRequest.url}`;;
    }

    if (sessionConfiguration.interceptors) {
      sessionConfiguration.interceptors = sessionConfiguration.interceptors?.concat(HttpInterceptorManager.getInstance().getInterceptors(request))
    } else {
      sessionConfiguration.interceptors = HttpInterceptorManager.getInstance().getInterceptors(request);
    }

    if (request.interceptors && request.interceptors?.length > 0) {
      sessionConfiguration.interceptors = sessionConfiguration.interceptors?.concat(request.interceptors);
    }

    return rcp.createSession(sessionConfiguration);
  }

  /**
   * 请求得到一个Response
   * @param request HttpRequest
   * @param callback 回调函数
   * @returns Session
   */
  requestResponse(request: HttpRequest, callback: (error: BusinessError<string>|undefined, response?: rcp.Response) => void): rcp.Session {
    const session: rcp.Session = this.createSession(request);
    this.appendToSessionConfig(session, request);
    session.fetch(request.builder()).then((rep: rcp.Response) => {
      // 输出跟踪信息
      this.tracing(rep!.debugInfo);
      //  输出性能时间
      this.performance(rep.timeInfo);

      callback(undefined, rep);
      session.close();
    }).catch((err: BusinessError<string>) => {
      callback(err);
      session.close();
    });
    return session;
  }

  /**
   * 同步请求，需要取消的时候可以调用这个
   * @param request HttpRequest
   * @param callback 回调函数
   * @returns Session，可以使用Session.cancel来取消请求
   */
  requestSync<T>(request: HttpRequest, callback: (error: HttpException|undefined, entity?: T) => void): rcp.Session {
    return this.requestResponse(request, (err: BusinessError<string>|undefined, rep?: rcp.Response) => {
      if (err) {
        callback(new HttpException(err.code, (err.data ? err.data : err.message), err.stack));
        return;
      }

      let decoder = util.TextDecoder.create('utf-8');
      const contentType = rep!.headers['content-type'];
      if (contentType?.toLowerCase().includes('application/json')) {
        let json = decoder.decodeToString(new Uint8Array(rep!.body));
        callback(undefined, JSON.parse(json));
      } else {
        let text = decoder.decodeToString(new Uint8Array(rep!.body));
        callback(undefined, text as T);
      }
    });
  }

  /**
   * 请求
   * @param request HttpRequest
   * @returns Promise<T>
   */
  request<T>(request: HttpRequest): Promise<T> {
    return new Promise((resolve, reject) => {
      this.requestResponse(request, (err: BusinessError<string>|undefined, rep?: rcp.Response) => {
        if (err) {
          reject(new HttpException(err.code, (err.data ? err.data : err.message), err.stack));
          return;
        }

        let decoder = util.TextDecoder.create('utf-8');
        const contentType = rep!.headers['content-type'];
        if (contentType?.toLowerCase().includes('application/json')) {
          let json = decoder.decodeToString(new Uint8Array(rep!.body));
          resolve(JSON.parse(json));
        } else {
          let text = decoder.decodeToString(new Uint8Array(rep!.body));
          resolve(text as T);
        }
      });

    });
  }

  /**
   * 下载
   * @param url 下载的URL地址
   * @param downloadFile 下载文件要存储的本地位置
   * @param callback 回调
   * @returns Session
   */
  download(request: HttpRequest, download: rcp.DownloadToFile | rcp.DownloadToStream | string, callback: (error: HttpException|undefined, downloadFile?: DownloadFile) => void): rcp.Session {
    let fileBuffer: ArrayBuffer|undefined;
    const originalDownload = download;
    if (typeof download === "string") {
      if (download.endsWith("/")) {
        fileBuffer = new ArrayBuffer(0);
        const streamData: rcp.WriteStream = {
          write(buffer: ArrayBuffer): Promise<void | number> {
            fileBuffer = mergeArrayBuffers(fileBuffer!, buffer);
            return Promise.resolve(buffer.byteLength);
          }
        };
        download = {
          kind: 'stream',
          stream: streamData
        } as rcp.DownloadToStream;
      } else {
        download = {
          kind: "file",
          file: download
        } as rcp.DownloadToFile;
      }
    }

    if (download.kind === "stream") {
      return this.downloadToStream(request, download as rcp.DownloadToStream, (error: HttpException|undefined, rep?: rcp.Response) => {
          if (error) {
            callback(error);
            return;
          }

          let filePath = "";
          if (fileBuffer) {
            const fileName = this.getFileNameFromContentDisposition(getRecordValue(rep!.headers as Record<string, string>, "content-disposition"));
            filePath = originalDownload + "/" + fileName;
            if (fileIo.accessSync(filePath)) {
              fileIo.unlink(filePath);
            }

            const fileStream = fileIo.createStreamSync(filePath, "w");
            fileStream.writeSync(fileBuffer);
          }

          callback(undefined, {
            response: rep!,
            filePath: filePath
          });
      });
    } else {
      return this.downloadToFile(request, download as rcp.DownloadToFile, callback);
    }
  }

  downloadToFile(request: HttpRequest, download: rcp.DownloadToFile, callback: (error: HttpException|undefined, downloadFile?: DownloadFile) => void): rcp.Session {
    const session: rcp.Session = this.createSession(request);
    this.appendToSessionConfig(session, request);

    session.downloadToFile(request.url, download).then((rep: rcp.Response) => {
      // 输出跟踪信息
      this.tracing(rep!.debugInfo);
      //  输出性能时间
      this.performance(rep.timeInfo);

      // 内容下载的路径。在使用下载至文件对象和文件标识符两种方式时，默认情况下，并未设置回调信息。
      let filePath = rep.downloadedTo?.path;
      if (!filePath) {
        if (download.kind === "file") {
          if (typeof download.file === "string") {
            filePath = download.file;
          }
        } else {
          filePath = download.path;
        }
      }
      callback(undefined, {
        response: rep!,
        filePath: filePath
      });

      session.close();
    }).catch((err: BusinessError<string>) => {
      callback(new HttpException(err.code, (err.data ? err.data : err.message), err.stack));
      session.close();
    });
    return session;
  }

  downloadToStream(request: HttpRequest, download: rcp.DownloadToStream, callback: (error: HttpException|undefined, rep?: rcp.Response) => void): rcp.Session {
    const session: rcp.Session = this.createSession(request);
    this.appendToSessionConfig(session, request);

    session.downloadToStream(request.url, download).then((rep: rcp.Response) => {
      // 输出跟踪信息
      this.tracing(rep!.debugInfo);
      //  输出性能时间
      this.performance(rep.timeInfo);

      callback(undefined, rep);

      session.close();
    }).catch((err: BusinessError<string>) => {
      callback(new HttpException(err.code, (err.data ? err.data : err.message), err.stack));
      session.close();
    });
    return session;
  }

  /**
   * 给Session追加配置
   * @param session Session
   * @param request HttpRequest
   */
  private appendToSessionConfig(session: rcp.Session, request: HttpRequest) {
    session.configuration!.headers = assign(session.configuration!.headers as Record<string, Object>, request.jsonRequest.headers as Object) as rcp.RequestHeaders;
    session.configuration!.cookies = assign(session.configuration!.cookies as Record<string, Object>, request.jsonRequest.cookies as Object) as rcp.RequestCookies;
    session.configuration!.requestConfiguration = assign(session.configuration?.requestConfiguration as Record<string, Object>, request.jsonRequest.configuration as Object) as rcp.Configuration

    if (!session.configuration!.requestConfiguration.tracing) {
      session.configuration!.requestConfiguration.tracing = {};
    }
    if (!session.configuration!.requestConfiguration.tracing.httpEventsHandler) {
      session.configuration!.requestConfiguration.tracing.httpEventsHandler = {};
    }
    if (request.jsonRequest.configuration?.tracing?.httpEventsHandler?.onDataReceive) {
      session.configuration!.requestConfiguration.tracing.httpEventsHandler!.onDataReceive = request.jsonRequest.configuration?.tracing?.httpEventsHandler?.onDataReceive;
    }
    if (request.jsonRequest.configuration?.tracing?.httpEventsHandler?.onUploadProgress) {
      session.configuration!.requestConfiguration.tracing.httpEventsHandler!.onUploadProgress = request.jsonRequest.configuration?.tracing?.httpEventsHandler?.onUploadProgress;
    }
    if (request.jsonRequest.configuration?.tracing?.httpEventsHandler?.onDownloadProgress) {
      session.configuration!.requestConfiguration.tracing.httpEventsHandler!.onDownloadProgress = request.jsonRequest.configuration?.tracing?.httpEventsHandler?.onDownloadProgress;
    }
    if (request.jsonRequest.configuration?.tracing?.httpEventsHandler?.onHeaderReceive) {
      session.configuration!.requestConfiguration.tracing.httpEventsHandler!.onHeaderReceive = request.jsonRequest.configuration?.tracing?.httpEventsHandler?.onHeaderReceive;
    }
    if (request.jsonRequest.configuration?.tracing?.httpEventsHandler?.onDataEnd) {
      session.configuration!.requestConfiguration.tracing.httpEventsHandler!.onDataEnd = request.jsonRequest.configuration?.tracing?.httpEventsHandler?.onDataEnd;
    }
    if (request.jsonRequest.configuration?.tracing?.httpEventsHandler?.onCanceled) {
      session.configuration!.requestConfiguration.tracing.httpEventsHandler!.onCanceled = request.jsonRequest.configuration?.tracing?.httpEventsHandler?.onCanceled;
    }

    if (request.jsonRequest.configuration?.processing) {
      session.configuration!.requestConfiguration.processing = request.jsonRequest.configuration?.processing;
    }

  }

  /**
   * 跟踪信息
   * @param debugInfo 调试信息
   */
  private tracing(debugInfo?: rcp.DebugInfo[]) {
    const httpDebugListener = this.httpConfiguration.tracingListener();
    if (httpDebugListener && debugInfo) {
      let decoder = util.TextDecoder.create('utf-8');
      debugInfo?.forEach(debugInfo => {
        if (debugInfo.type === 'headerOut' && httpDebugListener.onRequestHeader) {
          httpDebugListener.onRequestHeader(decoder.decodeWithStream(new Uint8Array(debugInfo.data)));
        } else if (debugInfo.type === 'dataOut' && httpDebugListener.onRequestBody) {
          httpDebugListener.onRequestBody(decoder.decodeWithStream(new Uint8Array(debugInfo.data)));
        } else if (debugInfo.type === 'headerIn' && httpDebugListener.onResponseHeader) {
          httpDebugListener.onResponseHeader(decoder.decodeWithStream(new Uint8Array(debugInfo.data)));
        } else if (debugInfo.type === 'dataIn' && httpDebugListener.onResponseBody) {
          httpDebugListener.onResponseBody(decoder.decodeWithStream(new Uint8Array(debugInfo.data)));
        } else if (debugInfo.type === 'sslDataOut' && httpDebugListener.onSslOut) {
          httpDebugListener.onSslOut(debugInfo.data);
        } else if (debugInfo.type === 'sslDataIn' && httpDebugListener.onSslIn) {
          httpDebugListener.onSslIn(debugInfo.data);
        } else if (debugInfo.type === 'text' && httpDebugListener.onText) {
          httpDebugListener.onText(decoder.decodeWithStream(new Uint8Array(debugInfo.data)));
        }
      });
    }
  }

  /**
   * 输出性能
   * @param debugInfo 调用时间信息
   */
  private performance(timeInfo?: rcp.TimeInfo) {
    const performanceListener = this.httpConfiguration.performanceListener();
    if (performanceListener && performanceListener.onPerformance && timeInfo) {
      performanceListener.onPerformance(timeInfo);
    }
  }

  /**
   * 从ContentDisposition中提取文件名称
   * @param contentDisposition ContentDisposition
   * @returns 文件名称
   */
  private getFileNameFromContentDisposition(contentDisposition: string | undefined): string | undefined {
    // 检查header是否存在
    if (!contentDisposition) {
      return undefined;
    }

    let fileName = contentDisposition.split('filename')[1];
    if (!fileName) {
      return undefined;
    }
    fileName = fileName.trim();
    if (fileName.startsWith("*")) {
      fileName = fileName.substring(1, fileName.length);
    }
    fileName = fileName.trim();
    if (fileName.startsWith("=")) {
      fileName = fileName.substring(1, fileName.length);
    }
    fileName = fileName.replaceAll("\"", "");
    fileName = decodeURIComponent(fileName);

    return fileName;
  }


}

