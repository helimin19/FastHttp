import { AntPathRequestMatcher, HttpConfiguration, HttpDebugListener,
  HttpPerformanceListener,
  HttpRequest } from 'fasthttp';
import { rcp } from '@kit.RemoteCommunicationKit';

export class LocalHttpConfiguration implements HttpConfiguration {

    private _customHttpEventsHandler: rcp.HttpEventsHandler = {
    onDataReceive: (incomingData: ArrayBuffer) => {
      // Custom logic for handling incoming data
      console.info("Received data:", incomingData);
      return incomingData.byteLength;
    },
    onUploadProgress: (totalSize: number, transferredSize: number) => {
      // Custom logic for handling upload progress
      console.info("Upload progress:", transferredSize, "of", totalSize);
    },
    onDownloadProgress: (totalSize: number, transferredSize: number) => {
      // Custom logic for handling download progress
      console.info("Download progress:", transferredSize, "of", totalSize);
    },
    onHeaderReceive: (headers: rcp.ResponseHeaders) => {
      // Custom logic for handling response headers
      console.info("Received headers:", headers);
    },
    onDataEnd: () => {
      // Custom logic for handling data transfer completion
      console.info("Data transfer complete");
    },
    onCanceled: () => {
      // Custom logic for handling cancellation
      console.info("Request/response canceled");
    },
  };

  private _sessionConfiguration: rcp.SessionConfiguration = {
    baseAddress: "http://192.168.100.66:8080",
    requestConfiguration: {
      tracing: {
        verbose: true,
        infoToCollect: {
          incomingHeader:true,
          outgoingHeader: true,
          incomingData: true,
          outgoingData: true
        },
        httpEventsHandler: {
          onDownloadProgress: (totalSize: number, transferredSize: number) => {
            console.log("limin-1", "totalSize=" + totalSize, "transferredSize=" + transferredSize);
          }
        }
      }
    }
  };

  sessionConfiguration(): rcp.SessionConfiguration {
    return {
      baseAddress: "http://192.168.100.66:8080",
      requestConfiguration: {
        tracing: {
          verbose: true,
          infoToCollect: {
            incomingHeader:true,
            outgoingHeader: true
          },
          httpEventsHandler: {
            onDownloadProgress: (totalSize: number, transferredSize: number) => {
              console.log("limin-1", "totalSize=" + totalSize, "transferredSize=" + transferredSize);
            }
          }
        },
        security: {

        }
      }
    };
  }

  debugListener(): HttpDebugListener {
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
    } as HttpDebugListener;
  }

  performanceListener(): HttpPerformanceListener {
    return {

    } as HttpPerformanceListener;
  }

  matches(request: HttpRequest): boolean {
    const antPathRequestMatcher = new AntPathRequestMatcher("http://192.168.100.66:8080/**");
    return antPathRequestMatcher.matches(request) || 99 === request.getTag("type");
  }

}