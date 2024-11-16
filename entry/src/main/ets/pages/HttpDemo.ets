import { common } from '@kit.AbilityKit';
import { FastHttp, HttpMethod, HttpRequest } from 'httpProxy';
import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';


class Result<T> {
  code: number = 0;
  message: string = "";
  data?: T;
}

class UserInfo {
  userId: string = "";
  userName: string = "";
  nickName: string = "";

  constructor() {
  }
}
class Ticket {
  token: string = "";
  userInfo: UserInfo = new UserInfo();
}

@Entry
@Component
struct HttpDemo {
  private context = getContext(this) as common.UIAbilityContext;
  private http: FastHttp = new FastHttp(new Map().set("type", 99).set("id", "id"));

  build() {
    Column() {
      Button("请求获取Map")
        .width("100%").margin({ top: 16 })
        .onClick(() => {
          this.requestMap();
        })

      Button("请求获取带包装的对象")
        .width("100%").margin({ top: 16 })
        .onClick(() => {
          this.requestResultEntity();
        })

      Button("请求获取带包装的字符串")
        .width("100%").margin({ top: 16 })
        .onClick(() => {
          this.requestResultString();
        })

      Button("请求获取不带包装的字符串")
        .width("100%").margin({ top: 16 })
        .onClick(() => {
          this.requestString();
        })

      Button("请求获取不带包装的数字")
        .width("100%").margin({ top: 16 })
        .onClick(() => {
          this.requestNumber();
        })

      Button("请求获取不带包装的布尔型")
        .width("100%").margin({ top: 16 })
        .onClick(() => {
          this.requestBoolean();
        })
    }
    .height('100%')
    .width('100%')
  }

  private requestMap() {
    this.http.request<Map<string, object>>(new HttpRequest("http://192.168.100.66:8080/auth/login/username")).then((result: Map<string, object>) => {
      promptAction.showToast({message: JSON.stringify(result)});
      console.log("limin", "Result", result);
    }).catch((err: BusinessError) => {
      console.error(`Response err: Code is ${err.code}, message is ${JSON.stringify(err)}`);
    });
  }

  private requestResultEntity() {
    const json = `{"method":"GET","url":"http://192.168.100.66:8080/auth/login/username","headers":{"token":"11","content-type":"application/json"},"body":{"name": "李太白", "age": 100}, "configuration":{"tracing":{"verbose":true, "infoToCollect": {"incomingHeader":true, "outgoingHeader":true, "incomingData": true, "outgoingData": true, "textual": true, "incomingSslData": true, "outgoingSslData": true}, "collectTimeInfo": true}}}`;

    this.http.request<Ticket>(new HttpRequest(json)).then((result: Ticket) => {
      promptAction.showToast({message: JSON.stringify(result)});
    }).catch((err: BusinessError) => {
      console.error(`Response err: Code is ${err.code}, message is ${JSON.stringify(err)}`);
    });
  }

  private requestResultString() {
    const request: HttpRequest = new HttpRequest();
    request.setUrl("http://192.168.100.66:8080/auth/login")
      .addHeader("token", "11")
      .addHeader("content-type", "application/json")
      .setBody("{name: '杜小甫', age: 100}")
    this.http.request<Result<string>>(request).then((result: Result<string>) => {
      promptAction.showToast({message: JSON.stringify(result)});
      console.log("limin", "Result", result.code, result.message, result.data);
    }).catch((err: BusinessError) => {
      console.error(`Response err: Code is ${err.code}, message is ${JSON.stringify(err)}`);
    });
  }

  private requestString(){
    const request: HttpRequest = new HttpRequest();
    request.setUrl("https://developer.huawei.com/consumer/cn/doc/assets/aui-icons/aui_close-svg-es2015.ee2a1c13a45d9c8572dd.js?20241016")

    console.log("limin1", "request", JSON.stringify(request));
    this.http.request<string>(request).then((result: string) => {
      promptAction.showToast({message: result});
      console.log("limin", "Result", result);
    }).catch((err: BusinessError) => {
      console.error(`Response err: Code is ${err.code}, message is ${JSON.stringify(err)}`);
    });
  }

  private requestNumber() {
    const request: HttpRequest = new HttpRequest("/auth/login/number");
    this.http.request<number>(request).then((result: number) => {
      promptAction.showToast({message: "" + result});
      console.log("limin", "Result", result);
    }).catch((err: BusinessError) => {
      console.error(`Response err: Code is ${err.code}, message is ${JSON.stringify(err)}`);
    });
  }

  private requestBoolean() {
    const request: HttpRequest = new HttpRequest("/auth/login/boolean").addTag("type", 99);
    this.http.request<boolean>(request).then((result: boolean) => {
      promptAction.showToast({message: "" + result});
      console.log("limin", "Result", result);
    }).catch((err: BusinessError) => {
      console.error(`Response err: Code is ${err.code}, message is ${JSON.stringify(err)}`);
    });
  }


}