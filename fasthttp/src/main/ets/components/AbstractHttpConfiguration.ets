import { HttpTracingListener } from './HttpTracingListener';
import { HttpConfiguration } from './HttpConfiguration';
import { HttpRequest } from './HttpRequest';
import { rcp } from '@kit.RemoteCommunicationKit';
import { HttpPerformanceListener } from './HttpPerformanceListener';

/**
 * 抽像的HTTP配置类
 */
export abstract class AbstractHttpConfiguration implements HttpConfiguration {

  sessionConfiguration(): rcp.SessionConfiguration {
    const tracingInfo = this.getTracingInfo();
    const tracingTimeInfo = this.isCollectTracingTimeInfo();
    return {
      // 请求/响应拦截器
      interceptors: this.getInterceptors(),
      // 指定与会话关联的HTTP请求的配置
      requestConfiguration: {
        // 配置与HTTP请求期间的数据传输相关的各个方面，例如自动重定向和超时设置。
        transfer: {
          // 指定HTTP客户端是否应自动遵循重定向。如果设置为true，客户端将自动遵循HTTP重定向；否则，它不会。默认值为true。
          autoRedirect: this.getAutoRedirect(),
          timeout: this.getTimeout(),
          // 指定连接是否具有HTTP/3功能，true代表连接具有HTTP/3功能，false代表没有，默认为false
          assumesHTTP3Capable: this.assumesHTTP3Capable(),
          // 这只是调用者的一个建议，系统决定使用哪个路径。可以是'自动'或'蜂窝'路径。默认为'自动'路径
          pathPreference: this.pathPreference(),
          // 服务类型。默认为undefined。
          serviceType: undefined,
          // 如果 autoRedirect 属性为 true，则设置请求要遵循的最大重定向次数。默认值为50，最大值为2147483647
          maxAutoRedirects: 50
        },
        // 使开发人员能够在HTTP请求期间捕获详细的跟踪信息，有助于调试和性能分析。
        tracing: {
          // 启用详细跟踪，捕获有关HTTP请求/响应流的大量信息。默认值为false，ture表示开启捕获，false表示不开启
          verbose: tracingInfo !== undefined,
          // 配置要收集的特定类型的信息事件。默认无事件需要收集。
          infoToCollect: tracingInfo,
          // 指示在跟踪过程中是否应收集与时间相关的信息，true代表收集，false代表不收集，默认值为false
          collectTimeInfo: tracingTimeInfo,
          // 为HTTP请求/响应过程中的特定操作定义响应处理程序的回调。默认值为undefined
          httpEventsHandler: this.getHttpEventsHandler()
        },
        // 配置会话的代理设置，允许开发人员定义'system'、'no-proxy'或WebProxy配置。
        proxy: this.getProxy(),
        // 指定与DNS相关的配置，包括自定义DNS规则和通过HTTPS使用DNS的选项。
        dns: this.getDns(),
        // 包括用于处理安全相关方面的设置，如证书和服务器身份验证。
        security: this.getSecurity(),
        // 响应处理配置
        processing: {
          validateResponse: this.getValidateResponseHandler()
        }
      },
      baseAddress: this.getBaseAddress(),
      // 为Session发出的HTTP请求定义自定义headers
      headers: this.getRequestHeader(),
      // 提供一种在与会话关联的HTTP请求中包含自定义cookie的方法
      cookies: this.getRequestCookies(),
      sessionListener: {
        // 当请求或会话被取消时的回调
        onCanceled: this.onCanceledHandler(),
        // 表示会话关闭时的回调
        onClosed: this.onClosedHandler()
      },
      // 连接配置
      connectionConfiguration: {
        // 单个主机允许的最大并发 TCP 连接数（主机与主机名+端口号对相同）。默认值为 6，最大值为 2147483647。
        maxConnectionsPerHost: this.getMaxConnectionsPerHost(),
        // 此会话中允许的最大同时 TCP 连接总数。 默认值为 64，最大值为 2147483647。
        maxTotalConnections: this.getMaxTotalConnections()
      }
    };
  }

  /**
   * 取得拦截器数组
   * @returns 拦截器数组
   */
  getInterceptors(): rcp.Interceptor[] {
    return [];
  }

  /**
   * 取得BaseUrl
   * @returns BaseUrl
   */
  getBaseAddress(): rcp.URLOrString {
    return "";
  }

  /**
   * 取得请求头
   * @returns 请求头
   */
  getRequestHeader(): rcp.RequestHeaders {
    return {};
  }

  /**
   * 取得请求Cookies
   * @returns 请求Cookies
   */
  getRequestCookies(): rcp.RequestCookies {
    return {};
  }

  /**
   * 取得单个主机允许的最大并发 TCP 连接数（主机与主机名+端口号对相同）。默认值为 6，最大值为 2147483647。
   * @returns 单个主机允许的最大并发 TCP 连接数
   */
  getMaxConnectionsPerHost(): number {
    return 6;
  }

  /**
   * 取得此会话中允许的最大同时 TCP 连接总数。 默认值为 64，最大值为 2147483647。
   * @returns 此会话中允许的最大同时 TCP 连接总数
   */
  getMaxTotalConnections(): number {
    return 64;
  }

  /**
   * 是否自动遵循HTTP重定向响应。默认为True
   * @returns 遵循HTTP重定向响应
   */
  getAutoRedirect(): boolean {
    return true;
  }

  /**
   * 取得超时时间
   * @returns 超时时间
   */
  getTimeout(): rcp.Timeout {
    return  {
      // 允许建立连接的最长时间（以毫秒为单位）。默认值为60000
      connectMs: this.getConnectTimeout(),
      // 允许传输数据的最长时间（以毫秒为单位）。默认值为60000
      transferMs: this.getTransferTimeout()
    };
  }

  /**
   * 连接超时时间。默认值为60000毫秒
   * @returns 连接超时时间
   */
  getConnectTimeout(): number {
    return 60000;
  }

  /**
   * 传输超时时间。默认值为60000毫秒
   * @returns 传输超时时间
   */
  getTransferTimeout(): number {
    return 60000;
  }

  /**
   * 是否假定目标服务器支持HTTP/3。默认值为false。
   * @returns 是否启动Http3
   */
  assumesHTTP3Capable(): boolean {
    return false;
  }

  /**
   * 请求路径首选项
   * @returns 请求路径首选项
   */
  pathPreference(): rcp.PathPreference {
    return 'auto';
  }

  /**
   * 获取跟踪信息
   * @returns 跟踪信息, undefined表示不启用跟踪
   */
  getTracingInfo(): rcp.InfoToCollect | undefined {
    const debugListener = this.tracingListener();
    if (!debugListener) {
      return undefined;
    }

    return {
      // 收集文本信息事件。默认值为false
      textual: debugListener.onText !== undefined,
      // 收集传入的header信息事件。默认值为false
      incomingHeader: debugListener.onRequestHeader !== undefined,
      // 收集传出的header信息事件。默认值为false
      outgoingHeader: debugListener.onResponseHeader !== undefined,
      // 收集传入的数据信息事件。默认值为false
      incomingData: debugListener.onRequestBody !== undefined,
      // 收集传出数据信息事件。默认值为false
      outgoingData: debugListener.onResponseBody !== undefined,
      // 收集传入的SSL/TLS数据信息事件。默认值为false
      incomingSslData: debugListener.onSslIn !== undefined,
      // 收集传出的SSL/TLS数据信息事件。默认值为false
      outgoingSslData: debugListener.onSslOut !== undefined
    };
  }

  /**
   * 获取调试监听器
   * @returns 调试监听器
   */
  tracingListener(): HttpTracingListener | undefined {
    return undefined;
  }

  /**
   * 是否收集跟踪时间信息 - 性能跟踪
   * @returns 是否收集跟踪时间信息
   */
  isCollectTracingTimeInfo(): boolean {
    if (this.performanceListener() && this.performanceListener()?.onPerformance) {
      return true;
    }
    return false;
  }

  /**
   * 获取性能监听器
   * @returns 性能监听器
   */
  performanceListener(): HttpPerformanceListener | undefined {
    return undefined;
  }

  /**
   * 为HTTP请求/响应过程中的特定操作定义响应处理程序的回调。默认值为undefined
   * @returns 处理程序
   */
  getHttpEventsHandler(): rcp.HttpEventsHandler | undefined {
    return undefined;
  }

  /**
   * 取得代理配置
   * @returns 代理配置
   */
  getProxy(): rcp.ProxyConfiguration {
    return 'system';
  }

  /**
   * 取得DNS配置
   * @returns DNS配置
   */
  getDns(): rcp.DnsConfiguration {
    return {
      // 配置DNS规则，默认值为undefined。
      dnsRules: this.getDnsRules(),
      // DNS over HTTPS配置。默认值为undefined
      dnsOverHttps: this.getDnsOverHttps()
    };
  }

  /**
   * 配置DNS规则，默认值为undefined
   * - DnsServers：表示优先使用指定的DNS服务器解析主机名
   * - StaticDnsRules：静态DNS规则，表示如果hostname匹配，则优先使用指定的地址
   * - DynamicDnsRule：动态DNS规则，表示优先使用函数中返回的地址
   * @returns DNS规则
   */
  getDnsRules(): rcp.DnsServers | rcp.StaticDnsRules | rcp.DynamicDnsRule | undefined {
    return undefined;
  }

  /**
   * DNS over HTTPS配置。默认值为undefined - 如果设置，则优先使用DNS服务器解析的地址
   * @returns DNS over HTTPS配置
   */
  getDnsOverHttps(): rcp.DnsOverHttpsConfiguration | undefined {
    return undefined;
  }

  /**
   * 取得安全配置
   * @returns 安全配置
   */
  getSecurity(): rcp.SecurityConfiguration {
    return  {
      // 证书颁发机构（CA），用于验证远程服务器的身份。默认值为'system'
      remoteValidation: this.getSecurityRemoteValidation(),
      // 客户端证书，发送到远程服务器，远程服务器将使用它来验证委托人的身份证明。默认值为undefined
      certificate: this.getSecurityCertificate(),
      // TLS版本选择器，用于选择TLS的版本，默认为'system'
      tlsOptions: this.getSecurityTlsOptions(),
      // 安全连接期间的服务器身份验证配置。默认不认证
      serverAuthentication: this.getSecurityServerAuthentication(),
      // 证书锁定配置
      certificatePinning: this.getSecurityCertificatePinning()
    };
  }

  /**
   * 证书颁发机构（CA），用于验证远程服务器的身份。默认值为'system'
   * 如果未设置此字段，系统CA将用于验证远程服务器的标识
   * - 'system'：表示使用系统CA配置
   * - 'skip'：跳过验证
   * - CertificateAuthority：证书颁发机构（CA）验证
   * - ValidationCallback：自定义证书校验
   * @returns 验证远程服务器的身份
   */
  getSecurityRemoteValidation(): 'system' | 'skip' | rcp.CertificateAuthority | rcp.ValidationCallback {
    return 'system';
  }

  /**
   * 客户端证书，发送到远程服务器，远程服务器将使用它来验证委托人的身份证明。
   * 默认值为undefined, 意味着服务器不需要验证客户端
   * @returns 客户端证书
   */
  getSecurityCertificate(): rcp.ClientCertificate | undefined {
    return undefined;
  }

  /**
   * TLS版本选择器，用于选择TLS的版本，默认为'system'
   * - 'system'：表示使用系统的TLS版本
   * - CipherSuite[]：用来声明加密套件的类型的数组
   * - TlsV13Option：表示使用TLS1.3版本
   * - TlsV12Option：表示使用TLS1.2版本
   * - TlsV11Option：表示使用TLS1.1版本
   * - TlsV10Option：表示使用TLS1.0版本
   * @returns
   */
  getSecurityTlsOptions(): 'system' | rcp.CipherSuite[] | rcp.TlsV13Option | rcp.TlsV12Option | rcp.TlsV11Option | rcp.TlsV10Option {
    return 'system';
  }

  /**
   * 安全连接期间的服务器身份验证配置。默认不认证
   * @returns 安全连接期间的服务器身份验证配置
   */
  getSecurityServerAuthentication(): rcp.ServerAuthentication | undefined {
    return undefined;
  }

  /**
   * 证书锁定配置
   * @returns 证书锁定配置
   */
  getSecurityCertificatePinning(): rcp.CertificatePinning| rcp.CertificatePinning[] | undefined {
    return undefined;
  }

  /**
   * 默认不处理。或者使用ResponseValidationCallback对响应进行校验。
   * @returns 响应处理
   */
  getValidateResponseHandler(): 'default' | rcp.ResponseValidationCallback {
    return 'default';
  }

  /**
   * 当请求或会话被取消时的回调函数
   * @returns 回调函数
   */
  onCanceledHandler(): (() => void) | undefined {
    return undefined;
  }

  /**
   * 表示会话关闭时的回调函数
   * @returns 回调函数
   */
  onClosedHandler(): (() => void) | undefined {
    return undefined;
  }

  /**
   * 当前Http配置是否符合当前请求
   * @param _request 当前请求
   * @returns true: 当前请求使用这个配置
   */
  matches(_request: HttpRequest): boolean {
    return true;
  }

}