import { HttpRequest } from './HttpRequest';
import { RequestMatcher } from './RequestMatcher';

export class AndRequestMatcher implements RequestMatcher {
  private requestMatchers: Array<RequestMatcher> = new Array();

  constructor(requestMatchers: Array<RequestMatcher>) {
    this.requestMatchers = requestMatchers;
  }

  matches(request: HttpRequest): boolean {
    return this.requestMatchers.every(requestMatcher => requestMatcher.matches(request));
  }

}
