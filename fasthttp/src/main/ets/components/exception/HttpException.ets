
/**
 * HTTP请求异常
 */
export class HttpException  {
  code: number;
  message: string;
  stack?: string | undefined;

  constructor(code: number, message: string, stack?: string | undefined) {
    this.code = code;
    this.message = message;
    this.stack = stack;
  }

}