# FastHttp

## 一. 简介与推荐
[FastHttp](https://github.com/helimin19/FastDb)
a. 支持统一配置，无需在请求时再配置，且在不同的HAP/HAR/HSP中针对不同的服务器做不同的配置
b. 支持统一添加请求/响应拦截器，无需在请求时再添加，且可以针对不同的请求启用不同的拦截器
c. 支持响应转换自动转换成对应的对象

## 二. 下载安装

`ohpm i @hlm/fasthttp`

OpenHarmony ohpm 环境配置等更多内容，请参考[如何安装 OpenHarmony ohpm 包](https://ohpm.openharmony.cn/#/cn/help/downloadandinstall)

## 三. 配置说明

### HTTP配置
1. 可针对不同的请求使用不同的配置
#### 定义配置类
```
export class XXXHttpConfiguration extends AbstractHttpConfiguration {
  getBaseAddress(): rcp.URLOrString {
    return  "http://192.168.100.2:8080";
  }
  /**
   * 请求的Request是否匹配当前配置档
   * @param request 请求信息
   * @returns true: request请求使用这个配置档; false: request请求不使用这个配置档
   */
  matches(request: HttpRequest): boolean {
    const antPathRequestMatcher = new AntPathRequestMatcher("https://xxx/**");
    return antPathRequestMatcher.matches(request);
  }
}
```
#### 注册配置类
```
HttpConfigurationManager.getInstance().register(new XXXHttpConfiguration());
```
#### 抽像的HTTP配置类(AbstractHttpConfiguration)
可以在这个类中实现如下操作
1. 添加请求响应拦截器
2. 设置BaseUrl
3. 设置请求头
4. 设置请求Cookies
5. 设置超时时间
6. 设置跟踪日志
7. 设置性能日志
8. 设置代理、DNS配置
9. 设置证书安全
不同的请求使用不同的配置需要实现matches方法
参数: request: HttpRequest表示当前请求
#### 请求配置器(AntPathRequestMatcher)
AntPathRequestMatcher: 可参考stpring boot的AntPathRequestMatcher使用规则

### 请求响应拦截器
#### 定义响应拦截器
```
export class ResultInterceptor implements HttpInterceptor {
  // 这个方法用来确认请求是否使用这个拦截器
  matches(request: HttpRequest): boolean {
    const antPathRequestMatcher = new AntPathRequestMatcher("http://xxx/**");
    return antPathRequestMatcher.matches(request);
  }

  intercept(context: rcp.RequestContext, next: rcp.RequestHandler): Promise<rcp.Response> {
    return new Promise((resolve, reject) => {
      next.handle(context).then((response: rcp.Response) => {
        let decoder = util.TextDecoder.create('utf-8');
        const contentType = response!.headers['content-type'];
        if (contentType?.toLowerCase().includes('application/json')) {
          let json = decoder.decodeToString(new Uint8Array(response!.body));
          let result: Object, isResult:boolean;
          try {
            result = JSON.parse(json) as object;
            isResult = Reflect.has(result, "code") && Reflect.has(result, "message") && Reflect.has(result, "data");
          } catch (e) {
            resolve(response);
            return;
          }

          if (!isResult) {
            resolve(response);
            return;
          }
          const data = Reflect.get(result, "data") as object;
          resolve({
            request: response.request,
            statusCode: response.statusCode,
            headers: response.headers,
            effectiveUrl: response.effectiveUrl,
            body: util.TextEncoder.create("utf-8").encodeInto(JSON.stringify(data)),
            downloadedTo: response.downloadedTo,
            debugInfo: response.debugInfo,
            timeInfo: response.timeInfo,
            cookies: response.cookies,
            httpVersion: response.httpVersion,
            reasonPhrase: response.reasonPhrase,
            toString: (): string | null => {
              return json;
            },
            toJSON:(): object | null => {
              return data;
            }
          });
        } else {
          resolve(response);
        }
      }).catch((error: BusinessError) => {
        reject(error);
      })
    });
  }

}
```
#### 注册响应拦截器
```
 HttpInterceptorManager.getInstance().register(new ResultInterceptor());
```

## 四. 使用说明

### 1. 装饰器的使用方式
#### Request装饰器
这是一个通用的请求装饰器
1. 使用位置: 方法
2. 装饰器的参数: JsonHttpRequest对象
3. 使用示例:
```
@Request({method: HttpMethod.POST, url: "http://192.168.100.2:8080/auth/login/username",headers:{"token":"11","content-type":"application/json"}, body:{name: "{name}", age: `{age}`}, "configuration":{transfer: { timeout: { connectMs: 3000, transferMs: 3000 }}}})
requestData(@Variable("age") age: number, @Variable("name")  key: string, result?: Promise<UserTicket>): Promise<UserTicket> {
    return result!;
}
```
注： 具体方法的最后一个参数result表示这个请求的返回值
#### Header装饰器
定义这个方法所对应请求的请求头，支持变量
1. 使用位置: 方法
2. 装饰器的参数:  Record<string, string>
#### RequestBody装饰器
定义这个方法所对应的POST请求的请求体
1. 使用位置: 方法的参数，一个方法的参数中只能有一个
2. 支持的类型: string | ArrayBuffer | object | rcp.Form | rcp.MultipartForm | rcp.GetDataCallback | rcp.GetDataCallback | rcp.UploadFromStream
#### Variable装饰器
会将装饰器中使用{xxx}表示的变量替换成这个参数
1. 使用位置: 方法的参数
2. 装饰器的参数: 变量名称
#### GET装饰器
1. 使用位置: 方法
2. 示例
```
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
```
注: 可以在这个方法里面使用result来处理请求结果, 也可以不处理，不处理时请返回return result!;
#### POST装饰器
1. 使用位置: 方法
2. 示例
```
@Header({"age": "{age}", "name": "{name}"})
@POST("http://192.168.100.2:8080/auth/user/insert")
postData(@Variable("age") age: number, @Variable("name") key: string, @RequestBody body: rcp.Form, result?: Promise<UserInfo>): Promise<UserInfo> {
  return new Promise<UserInfo>((resolve, reject) => {
    result!.then((user: UserInfo) => {
      resolve(user);
    }).catch((err: Error) => {
      reject(err);
    });
  });
}
```
#### 上传文件
```
@POST("http://192.168.100.2:8080/auth/upload")
uploadFile(@RequestBody body: rcp.MultipartForm, result?: Promise<FileInfo>): Promise<FileInfo> {
  return result!;
}
```
#### 下载文件
```
// 这里下载的文件不能超过5M
@POST("http://192.168.100.2:8080/auth/download/text")
downLoadFile(result?: Promise<ArrayBuffer>): Promise<ArrayBuffer> {
  return result!;
}
```

### 2. API的使用方式

### 创建FastHttp对象
```
private http: FastHttp = new FastHttp(tags?: Map<string, object | string | number | boolean>);
```
#### 参数说明
tags: [可选参数], 可在自定义配置，自定义拦截器中使用, 如可以在自定义配置中使用这个TAG来区分对应的服务使用哪个配置

### GET请求获得对象
```
const url = "https://xxx" 或 "/xxx";
this.http.request<Ticket>(new HttpRequest(url)).then((result: Ticket) => {
  promptAction.showToast({message: JSON.stringify(result)});
});
```

### POST请求获得对象
```
const request: HttpRequest = new HttpRequest();
request.setUrl("/xxx")
  .setMethod(HttpMethod.POST)
  .addHeader("token", "11")
  .addHeader("content-type", "application/json")
  .setBody("{name: '杜小甫', age: 100}")
this.http.request<Ticket>(request).then((result: Ticket) => {
  promptAction.showToast({message: JSON.stringify(result)});
})
```

### 请求获得string/boolean/number
```
this.http.request<string/boolean/number>(new HttpRequest('/xxx')).then((result: string/boolean/number) => {
  promptAction.showToast({message: `${result}`});
})
```

### 下载文件
```
const request = new HttpRequest("/xxx")
  .setDownloadProgress((totalSize: number, transferredSize: number) => {
    
  });
this.http.download(request, this.context.filesDir + "/", (error: HttpException|undefined, downloadFile?: DownloadFile) => {
  if (error) {
    promptAction.showToast({message: "" + error.message, duration: 50000});
  } else {
    promptAction.showToast({message: `${downloadFile?.filePath}`});
  }
});
```
#### 下载文件方法
```
download(request: HttpRequest, download: rcp.DownloadToFile | rcp.DownloadToStream | string, callback: (error: HttpException|undefined, downloadFile?: DownloadFile) => void): rcp.Session
```
##### 参数说明:
1. request: 请求参数, 可参考:HttpRequest
2. download: 下载文件需要存储的位置，rcp.DownloadToFile|rcp.DownloadToStream可参考系统的这两个方法，如果是string类型，如果是以/结尾则存储的文件名称则从响应头的content-disposition中获取
3. callback: 下载完成后的回调

### 上传文件
```
let documentPicker = new picker.DocumentViewPicker(getContext(this) as common.UIAbilityContext);
documentPicker.select().then((files: Array<string>) => {
  const fileInfo = fileIo.openSync(files[0]);
  const form = new rcp.MultipartForm({
    "file": {
      contentOrPath: fileInfo.path
    }
  });
  const request: HttpRequest = new HttpRequest();
  request.setUrl("/auth/upload");
  request.setMethod(HttpMethod.POST);
  request.setBody(form);
  this.http.request<Result<FileInfo>>(request).then((result: Result<FileInfo>) => {
    promptAction.showToast({message: JSON.stringify(result), duration: 50000});
  }).catch((err: Error) => {
    promptAction.showToast({message: JSON.stringify(err), duration: 50000});
  })
})
```

### 3. JSON字符串转换成请求
```
const json = `{"method":"GET","url":"http://xxx","headers":{"token":"11","content-type":"application/json"},"body":{"name": "李太白", "age": 100}, "configuration":{"tracing":{"verbose":true, "infoToCollect": {"incomingHeader":true, "outgoingHeader":true, "incomingData": true, "outgoingData": true, "textual": true, "incomingSslData": true, "outgoingSslData": true}, "collectTimeInfo": true}}}`;
this.http.request<xxx>(new HttpRequest(json)).then((result: xxx) => {
  promptAction.showToast({message: `${result}`});
})
```


