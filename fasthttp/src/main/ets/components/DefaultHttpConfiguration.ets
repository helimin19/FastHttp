import { HttpDebugListener } from './HttpDebugListener';
import { HttpConfiguration } from './HttpConfiguration';
import { HttpRequest } from './HttpRequest';
import { rcp } from '@kit.RemoteCommunicationKit';
import { HttpPerformanceListener } from './HttpPerformanceListener';

/**
 * 默认的HTTP配置
 */
export class DefaultHttpConfiguration implements HttpConfiguration {

  // TransferConfiguration接口为开发人员提供了一组选项，用于调整会话中HTTP请求期间的数据传输行为。这包括与自动重定向和超时配置相关的设置
  private _transfer:rcp.TransferConfiguration = {
    // 指定HTTP客户端是否应自动遵循重定向。如果设置为true，客户端将自动遵循HTTP重定向；否则，它不会。默认值为true。
    autoRedirect: true,
    timeout: {
      // 允许建立连接的最长时间（以毫秒为单位）。默认值为60000
      connectMs: 60000,
      // 允许传输数据的最长时间（以毫秒为单位）。默认值为60000
      transferMs: 60000
    },
    // 指定连接是否具有HTTP/3功能，true代表连接具有HTTP/3功能，false代表没有，默认为false
    assumesHTTP3Capable: false,
    // 这只是调用者的一个建议，系统决定使用哪个路径。可以是'自动'或'蜂窝'路径。默认为'自动'路径
    pathPreference: 'auto',
    // 服务类型。默认为undefined。
    serviceType: undefined,
    // 如果 autoRedirect 属性为 true，则设置请求要遵循的最大重定向次数。默认值为50，最大值为2147483647
    maxAutoRedirects: 50
  };

  // 使开发人员能够在HTTP请求期间捕获详细的跟踪信息，有助于调试和性能分析
  private _tracing: rcp.TracingConfiguration = {
    // 启用详细跟踪，捕获有关HTTP请求/响应流的大量信息。默认值为false，ture表示开启捕获，false表示不开启
    verbose: false,
    infoToCollect: {
      // 收集文本信息事件。默认值为false
      textual: false,
      // 收集传入的header信息事件。默认值为false
      incomingHeader: false,
      // 收集传出的header信息事件。默认值为false
      outgoingHeader: false,
      // 收集传入的数据信息事件。默认值为false
      incomingData: false,
      // 收集传出数据信息事件。默认值为false
      outgoingData: false,
      // 收集传入的SSL/TLS数据信息事件。默认值为false
      incomingSslData: false,
      // 收集传出的SSL/TLS数据信息事件。默认值为false
      outgoingSslData: false
    },
    // 指示在跟踪过程中是否应收集与时间相关的信息，true代表收集，false代表不收集，默认值为false
    collectTimeInfo: false
  };

  sessionConfiguration(): rcp.SessionConfiguration {
    return {
      // 请求/响应拦截器
      interceptors:[],
      // 指定与会话关联的HTTP请求的配置
      requestConfiguration: {
        transfer: this._transfer,
        tracing: this._tracing,
        proxy: 'no-proxy'
      },
      // 为Session发出的HTTP请求定义自定义headers
      headers: {

      },
      // 提供一种在与会话关联的HTTP请求中包含自定义cookie的方法
      cookies: {

      },
      // 连接配置
      connectionConfiguration: {
        // 单个主机允许的最大并发 TCP 连接数（主机与主机名+端口号对相同）。默认值为 6，最大值为 2147483647。
        maxConnectionsPerHost: 6,
        // 此会话中允许的最大同时 TCP 连接总数。 默认值为 64，最大值为 2147483647。
        maxTotalConnections: 64
      }
    };
  }

  debugListener(): HttpDebugListener | undefined {
    return undefined;
  }

  performanceListener(): HttpPerformanceListener | undefined {
    return undefined;
  }

  matches(_request: HttpRequest): boolean {
    return true;
  }

}