import { HttpRequest } from './HttpRequest';
import { RequestMatcher } from './RequestMatcher';

export class AntPathRequestMatcher implements RequestMatcher {

  private pattern: string;
  private regexPattern: RegExp;
  private segments: string[];
  private isWildcardMatchAll: boolean;

  constructor(pattern: string) {
    this.pattern = pattern;
    this.isWildcardMatchAll = pattern.endsWith('**');
    if (this.isWildcardMatchAll) {
      // 如果模式以 ** 结尾，我们移除它以便构建正则表达式
      this.pattern = pattern.slice(0, -2);
    }
    this.segments = this.pattern.split('/').filter(segment => segment !== '');
    this.regexPattern = this.buildRegexPattern();
  }

  matches(request: HttpRequest): boolean {
    const path = request.url.toString();
    if (this.isWildcardMatchAll) {
      // 如果模式以 ** 结尾，我们特别处理
      const basePath = this.pattern;
      return path.startsWith(basePath) || (basePath === '/' && path === '/');
    } else {
      // 使用正则表达式进行匹配
      return this.regexPattern.test(path);
    }
  }

  private escapeRegex(str: string): string {
    return str.replace(/[.*+?${}()|[\]\\]/g, '\\$&'); // $& 表示整个匹配的字符串
  }

  private buildRegexPattern(): RegExp {
    let regexStr = '';
    for (let segment of this.segments) {
      if (segment === '**') {
        // ** 表示任意层级的目录
        regexStr += '(/.*)?';
      } else if (segment.includes('*') || segment.includes('?')) {
        // 处理 * 和 ? 通配符
        regexStr += '/' + this.escapeRegex(segment.replace(/\*/g, '.*').replace(/\?/g, '.'));
      } else {
        // 普通路径段
        regexStr += '/' + this.escapeRegex(segment);
      }
    }
    if (!this.isWildcardMatchAll) {
      // 如果不是以 ** 结尾，我们需要确保路径的结尾匹配
      regexStr += '$';
    }
    return new RegExp(regexStr);
  }


}