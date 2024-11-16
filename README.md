# FastHttp

## 1. 简介与推荐
[FastHttp](https://github.com/helimin19/FastDb)
a. 支持统一配置，无需在请求时再配置，且在不同的HAP/HAR/HSP中针对不同的服务器做不同的配置
b. 支持统一添加请求/响应拦截器，无需在请求时再添加，且可以针对不同的请求启用不同的拦截器
c. 支持响应转换自动转换成对应的对象

## 2. 下载安装

`ohpm i @hlm/fasthttp`

OpenHarmony ohpm 环境配置等更多内容，请参考[如何安装 OpenHarmony ohpm 包](https://ohpm.openharmony.cn/#/cn/help/downloadandinstall)

## 3. 使用说明
### 创建FastHttp对象
```
private http: FastHttp = new FastHttp(tags?: Map<string, object | string | number | boolean>);
```
#### 参数说明
tags: [可选参数], 可在自定义配置，自定义拦截器中使用

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

### 定义一个JSON请求
```
const json = `{"method":"GET","url":"http://xxx","headers":{"token":"11","content-type":"application/json"},"body":{"name": "李太白", "age": 100}, "configuration":{"tracing":{"verbose":true, "infoToCollect": {"incomingHeader":true, "outgoingHeader":true, "incomingData": true, "outgoingData": true, "textual": true, "incomingSslData": true, "outgoingSslData": true}, "collectTimeInfo": true}}}`;
this.http.request<xxx>(new HttpRequest(json)).then((result: xxx) => {
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
  this.http.upload<Result<FileInfo>>(new HttpRequest("/xxx"), form, (error: HttpException|undefined, result?: Result<FileInfo>) => {
    promptAction.showToast({message: JSON.stringify(result), duration: 50000});
  });
```

### HTTP配置
1. 可针对不同的请求使用不同的配置
#### 定义配置类
```
export class XXXHttpConfiguration implements HttpConfiguration {
  // 创建Session配置
  sessionConfiguration(): rcp.SessionConfiguration {
    return {};
  }

  // 输出调试信息
  debugListener(): HttpDebugListener | undefined {
    return undefined;
  }

  // 输出性能信息
  performanceListener(): HttpPerformanceListener | undefined {
    return undefined;
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
#### 请求配置器(AntPathRequestMatcher)
AntPathRequestMatcher: 可参考stpring boot的AntPathRequestMatcher使用规则

### 请求响应拦截器
#### 定义响应拦截器
```
export class ResultInterceptor implements HttpInterceptor {

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





