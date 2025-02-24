import { DefaultHttpConfiguration } from './DefaultHttpConfiguration';
import { HttpConfiguration } from './HttpConfiguration';
import { HttpRequest } from './HttpRequest';

/**
 * Http配置管理
 */
export class HttpConfigurationManager {

  private static instance: HttpConfigurationManager;

  public static getInstance(): HttpConfigurationManager {
    if (!HttpConfigurationManager.instance) {
      HttpConfigurationManager.instance = new HttpConfigurationManager();
    }
    return HttpConfigurationManager.instance;
  }

  // HTTP配置列表
  private configurations = new Array<HttpConfiguration>();
  // 默认HTTP配置
  private default: HttpConfiguration = new DefaultHttpConfiguration();

  private constructor() {
  }

  /**
   * 设置默认的Http配置
   * @param configuration 默认的Http配置
   * @returns HttpConfigurationManager
   */
  public setDefault(configuration: HttpConfiguration): HttpConfigurationManager {
    this.default = configuration;
    return this;
  }

  /**
   * 注册Http配置
   * @param configuration Http配置
   * @returns HttpConfigurationManager
   */
  public register(configuration: HttpConfiguration): HttpConfigurationManager {
    this.configurations.push(configuration);
    return this;
  }

  /**
   * 取得Request匹配的Http配置
   * @param request 请求
   * @returns Http配置
   */
  public getHttpConfiguration(request: HttpRequest): HttpConfiguration {
    let res = this.configurations.filter(configuration => configuration.matches(request));
    if (res && res.length > 0) {
      return res[0];
    } else {
      return this.default;
    }
  }

}
