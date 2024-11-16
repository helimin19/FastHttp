import { DownloadFile, FastHttp, HttpException, HttpRequest } from 'httpProxy';
import { promptAction } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { rcp } from '@kit.RemoteCommunicationKit';
import { fileIo } from '@kit.CoreFileKit';

@Entry
@Component
struct DownloadDemo {
  private context = getContext(this) as common.UIAbilityContext;
  private http: FastHttp = new FastHttp(new Map().set("type", 99).set("id", "id"));


  build() {
    Column() {
      Button("下载文件到指定文件路径")
        .width("100%").margin({ top: 16 })
        .onClick(() => {
          this.downFileToFilePath();
        })

      Button("下载文件到文件对象")
        .width("100%").margin({ top: 16 })
        .onClick(() => {
          this.downFileToEntity();
        })

      Button("下载文件到指定目录")
        .width("100%").margin({ top: 16 })
        .onClick(() => {
          this.downFileToFolder();
        })

      Button("自定义下载文件")
        .width("100%").margin({ top: 16 })
        .onClick(() => {
          this.downFileToCustom();
        })

      Button("下载文件到字符串文件")
        .width("100%").margin({ top: 16 })
        .onClick(() => {
          this.downFileToStringFile();
        })

      Button("下载文件到字符串目录")
        .width("100%").margin({ top: 16 })
        .onClick(() => {
          this.downFileToStringFolder();
        })


      Button("下载文件自定义存储")
        .width("100%").margin({ top: 16 })
        .onClick(() => {
          this.downFileToCustomSave();
        })

      Button("下载文件到文件流")
        .width("100%").margin({ top: 16 })
        .onClick(() => {
          this.downFileToStream();
        })
    }
    .height('100%')
    .width('100%')
  }



  private downFileToFilePath() {
    const downFile: rcp.DownloadToFile = {
      kind: "file",
      file: this.context.getApplicationContext().filesDir + "/bb1.jpg",
      keepLocal: false
    };

    const request = new HttpRequest("/auth/download/image")
      .setDownloadProgress((totalSize: number, transferredSize: number) => {
        console.log("helimin-8", `${totalSize}-${transferredSize}`);
      });

    this.http.download(request, downFile, (error: HttpException|undefined, downloadFile?: DownloadFile) => {
      if (error) {
        promptAction.showToast({message: "" + error.message});
      } else {
        promptAction.showToast({message: "" + downloadFile?.filePath});
      }
    });
  }

  private downFileToEntity() {
    const file = fileIo.openSync(this.context.getApplicationContext().tempDir + "/a2.jpg", fileIo.OpenMode.CREATE | fileIo.OpenMode.WRITE_ONLY);

    const downFile: rcp.DownloadToFile = {
      kind: "file",
      file: file
    };

    this.http.download(new HttpRequest("/auth/download/image"), downFile, (error: HttpException|undefined, downloadFile?: DownloadFile) => {
      if (error) {
        promptAction.showToast({message: "" + error.message});
      } else {
        promptAction.showToast({message: "" + downloadFile?.filePath});
      }
    });
  }

  private downFileToFolder() {
    const downFile: rcp.DownloadToFile = {
      kind: "folder",
      path:  this.context.filesDir
    };

    this.http.download(new HttpRequest("https://developer.huawei.com/images/logo-developer-header.svg"), downFile, (error: HttpException|undefined, downloadFile?: DownloadFile) => {
      if (error) {
        promptAction.showToast({message: "" + error.message});
      } else {
        promptAction.showToast({message: "" + downloadFile?.filePath});
      }
    });
  }

  private downFileToCustom() {
    const downFile: rcp.DownloadToFile = {
      kind: "file",
      file: (request: rcp.Request, suggestedPath: rcp.Path) => {
        console.log("limin", `${suggestedPath}`);
        return {
          path: this.context.filesDir + "/nocc-app-release.apk",
        } as rcp.TargetFile;
      }
    };

    const httpRequest = new HttpRequest("/auth/download/file");
    httpRequest.jsonRequest.configuration = {
      tracing: {
        infoToCollect: {
          textual: false
        },
        httpEventsHandler: {
          onDownloadProgress: (totalSize: number, transferredSize: number) => {
            console.log("limin-9", `totalSize=${totalSize}, transferredSize=${transferredSize}`);
          }
        }
      }
    }
    this.http.download(httpRequest, downFile, (error: HttpException|undefined, downloadFile?: DownloadFile) => {
      if (error) {
        promptAction.showToast({message: "" + error.message});
      } else {
        promptAction.showToast({message: "" + downloadFile?.filePath});
      }
    });
  }

  private downFileToCustomSave() {
    const downFile: rcp.DownloadToFile = {
      kind: "file",
      file: {
        write: (buffer: ArrayBuffer)=> {
          return new Promise<void | number>((_resolve, _reject) => {

          });
        }
      } as rcp.WriteFile,
      keepLocal: false
    };

    this.http.download(new HttpRequest("/auth/download/file"), downFile, (error: HttpException|undefined, downloadFile?: DownloadFile) => {
      if (error) {
        promptAction.showToast({message: "" + error.message});
      } else {
        promptAction.showToast({message: "" + downloadFile?.filePath});
      }
    });
  }

  private downFileToStream() {
    const filePath = this.context.tempDir + "/app.jpg";
    if (fileIo.accessSync(filePath)) {
      fileIo.unlink(filePath);
    }

    const fileStream = fileIo.createStreamSync(filePath, "w");

    const streamData: rcp.WriteStream = {
      write(buffer: ArrayBuffer): Promise<void | number> {
        fileStream.writeSync(buffer);
        return Promise.resolve(buffer.byteLength);
      }
    };

    let downloadToStream: rcp.DownloadToStream = {
      kind: 'stream',
      stream: streamData
    }

    this.http.download(new HttpRequest("/auth/download/image"), downloadToStream, (error: HttpException|undefined, downloadFile?: DownloadFile) => {
      if (error) {
        promptAction.showToast({message: "" + error.message, duration: 50000});
      } else {
        promptAction.showToast({message: `${downloadFile?.filePath}`});
      }
    });
  }

  private downFileToStringFile() {
    const request = new HttpRequest("/auth/download/image")
      .setDownloadProgress((totalSize: number, transferredSize: number) => {
        console.log("helimin-8", `${totalSize}-${transferredSize}`);
      });
    this.http.download(request, this.context.tempDir + "/q1.jpg", (error: HttpException|undefined, downloadFile?: DownloadFile) => {
      if (error) {
        promptAction.showToast({message: "" + error.message, duration: 50000});
      } else {
        promptAction.showToast({message: `${downloadFile?.filePath}`});
      }
    });
  }

  private downFileToStringFolder() {
    const request = new HttpRequest("/auth/download/image")
      .setDownloadProgress((totalSize: number, transferredSize: number) => {
        console.log("helimin-8", `${totalSize}-${transferredSize}`);
      });
    this.http.download(request, this.context.filesDir + "/", (error: HttpException|undefined, downloadFile?: DownloadFile) => {
      if (error) {
        promptAction.showToast({message: "" + error.message, duration: 50000});
      } else {
        promptAction.showToast({message: `${downloadFile?.filePath}`});
      }
    });
  }


}