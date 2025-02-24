import { fileIo, fileUri, picker } from '@kit.CoreFileKit';
import { promptAction } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { FastHttp, HttpException, HttpRequest, HttpMethod } from 'httpProxy';
import { rcp } from '@kit.RemoteCommunicationKit';

@Entry
@Component
struct UploadDemo {
  private context = getContext(this) as common.UIAbilityContext;
  private http: FastHttp = new FastHttp(new Map().set("type", 99).set("id", "id"));

  build() {
    Column() {
      Button("从字符串路径上传")
        .width("100%").margin({ top: 16 })
        .onClick(() => {
          this.uploadFromStringPath();
        })


    }
    .height('100%')
    .width('100%')
  }



  private async uploadFromStringPath() {
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
      // this.http.upload<Result<FileInfo>>(new HttpRequest("/auth/upload"), form, (error: HttpException|undefined, result?: Result<FileInfo>) => {
      //   promptAction.showToast({message: JSON.stringify(result), duration: 50000});
      // });
    })
  }

}


class Result<T> {
  code: number = 0;
  message: string = "";
  data?: T;
}

class FileInfo {
  fileName: string = "";
  fileSize: number = 0;

  constructor() {
  }
}
