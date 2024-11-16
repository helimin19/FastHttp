import { webview } from '@kit.ArkWeb';

@Entry
@Component
struct AdoWebview {
  @State message: string = 'Hello World';

  private controller: webview.WebviewController = new webview.WebviewController();

  build() {
    Column() {
      Web({src: "https://www.baidu.com", controller: this.controller})
        .javaScriptAccess(true)
        .width("100%")
        .height("100%")
    }
    .height('100%')
    .width('100%')
  }
}