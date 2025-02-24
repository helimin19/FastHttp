import { GET, Header, HttpMethod, POST, Request, RequestBody, Variable } from "httpProxy";
import { rcp } from "@kit.RemoteCommunicationKit";
import { fileIo, picker } from "@kit.CoreFileKit";
import { common } from "@kit.AbilityKit";
import { fileIo as fs } from '@kit.CoreFileKit';

export interface UserTicket {
  code: string,
  message: string,
  data: string
}

export interface UserInfo {
  userId: string,
  userName: string,
  password: string
}

export interface FileInfo {
  fileName: string,
  fileSize: number
}

export class UserApi {

  @Request({method: HttpMethod.POST, url: "http://192.168.100.2:8080/auth/login/username",headers:{"token":"11","content-type":"application/json"}, body:{name: "{name}", age: `{age}`}, "configuration":{transfer: { timeout: { connectMs: 3000, transferMs: 3000 }}}})
  requestData(@Variable("age") age: number, @Variable("name")  key: string, result?: Promise<UserTicket>): Promise<UserTicket> {
    return result!;
  }

@Header({"token": "aaa", "tenantCode": "{name}"})
@GET("http://192.168.100.2:8080/auth/login?id={id}")
getData(@Variable("id") id: number, @Variable("name")  key: string, result?: Promise<UserTicket>): Promise<UserTicket> {
  return new Promise<UserTicket>((resolve, reject) => {
    result!.then((user: UserTicket) => {
      resolve(user);
    }).catch((err: Error) => {
      reject(err);
    });
  });
}

@Header({"age": "{age}", "name": "{name}"})
@POST("http://192.168.100.2:8080/auth/user/insert")
postData(@Variable("age") age: number, @Variable("name") key: string, @RequestBody body: rcp.Form, result?: Promise<UserInfo>): Promise<UserInfo> {
  return new Promise<UserInfo>((resolve, reject) => {
    result!.then((user: UserInfo) => {
      console.log("limin888", "insert user = " + JSON.stringify(user));
      resolve(user);
    }).catch((err: Error) => {
      console.log("limin888", "insert user = " + JSON.stringify(err));
      reject(err);
    });
  });
}

@POST("http://192.168.100.2:8080/auth/upload")
uploadFile(@RequestBody body: rcp.MultipartForm, result?: Promise<FileInfo>): Promise<FileInfo> {
  return result!;
}

// 这里下载的文件不能超过5M
@POST("http://192.168.100.2:8080/auth/download/text")
downLoadFile(result?: Promise<ArrayBuffer>): Promise<ArrayBuffer> {
  return result!;
}


@GET("http://192.168.100.2:8080/auth/login/number")
@Header({"token1": "bbb", "tenantCode1": "222"})
async getNumber(result?: Promise<number>) {
  const item: number = await result!;
  return item;
}

@GET("http://192.168.100.2:8080/auth/login/boolean")
getBoolean(result?: Promise<boolean>): Promise<boolean> {
  return result!;
}

}

@Entry
@Component
struct HttpDecorator {
  private context = getContext(this) as common.UIAbilityContext;
  @State message: string = 'Hello World';

  build() {
    Column() {
      Button("Request装饰器请求")
        .width("100%")
        .onClick(() => {
          const userApi = new UserApi();
          userApi.requestData(90, "杜小甫").then((user: UserTicket) => {
            console.log("limin666", "user = " + JSON.stringify(user));
          }).catch((err: Error) => {
            console.log("limin666", "err = " + JSON.stringify(err));
          })
        })

      Button("GET请求")
        .width("100%")
        .onClick(() => {
          const userApi = new UserApi();
          userApi.getData(10, "深圳").then((user: UserTicket) => {
            console.log("limin666", "user = " + JSON.stringify(user));
          }).catch((err: Error) => {
            console.log("limin666", "err = " + JSON.stringify(err));
          })
        })

      Button("POST请求")
        .width("100%")
        .onClick(() => {
          const userApi = new UserApi();
          const body: rcp.Form = new rcp.Form({userId: "admin", userName: "管理员", password: "123"});

          userApi.postData(99, "深圳", body)?.then((user: UserInfo) => {
            console.log("limin666", "user = " + JSON.stringify(user));
          }).catch((err: Error) => {
            console.log("limin666", "err = " + JSON.stringify(err));
          })
        })

      Button("上传文件")
        .width("100%")
        .onClick(() => {

          let documentPicker = new picker.DocumentViewPicker(getContext(this) as common.UIAbilityContext);
          documentPicker.select().then((files: Array<string>) => {
            const fileInfo = fileIo.openSync(files[0]);
            const form = new rcp.MultipartForm({
              "file": {
                contentOrPath: fileInfo.path
              }
            });

            const userApi = new UserApi();
            userApi.uploadFile(form).then((file: FileInfo) => {
              console.log("limin666", "uploadFile = " + JSON.stringify(file));
            }).catch((err: Error) => {
              console.log("limin666", "uploadFile = " + JSON.stringify(err));
            })
          })

        })

      Button("下载文件")
        .width("100%")
        .onClick(() => {
            const userApi = new UserApi();
            userApi.downLoadFile().then((stream: ArrayBuffer) => {

              const filePath = this.context.tempDir + "/demo.txt";
              if (fileIo.accessSync(filePath)) {
                fileIo.unlink(filePath);
              }

              const fileStream = fileIo.createStreamSync(filePath, "w");
              fileStream.writeSync(stream);
              fileStream.closeSync();

              console.log("limin666", "downLoadFile = " + stream.byteLength);
            }).catch((err: Error) => {
              console.log("limin666", "downLoadFile = " + JSON.stringify(err));
            })
        })


      Button("获取数字")
        .width("100%")
        .onClick(async () => {
          const userApi = new UserApi();
          const result = await userApi.getNumber();
          console.log("limin666", "number = " + result);
        })

      Button("获取布尔值")
        .width("100%")
        .onClick(() => {
          const userApi = new UserApi();
          userApi.getBoolean().then((result: boolean) => {
            console.log("limin666", "boolean = " + result);
          }).catch((err:Error) => {
            console.log("limin666", "boolean = " + JSON.stringify(err));
          })
        })

    }
    .height('100%')
    .width('100%')
  }
}