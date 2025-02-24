
import { BusinessError } from '@kit.BasicServicesKit';
import { router } from '@kit.ArkUI';
import { common, Want } from '@kit.AbilityKit';
import {FastHttp, GET, Header } from 'httpProxy';
import { notificationManager } from '@kit.NotificationKit';



@Entry
@Component
struct Index {
  @State message: string = 'Hello World';
  private context = getContext(this) as common.UIAbilityContext;
  private http: FastHttp = new FastHttp(new Map().set("type", 99).set("id", "id"));

  aboutToAppear(): void {

  }

  build() {
    Column() {
      Scroll() {
        Column() {
          Button("打开Setting")
            .width("100%").margin({ top: 16 })
            .onClick(() => {
              const want: Want = {
                bundleName: this.context.abilityInfo.bundleName,
                abilityName: "SettingAbility"
              };
              this.context.startAbility(want).then(() => {
                console.log("limin", "打开SettingAbility成功.");
              }).catch((err: BusinessError) => {
                console.log("limin", "打开SettingAbility失败:", err);
              })
            })

          Button("装饰器请求")
            .width("100%").margin({ top: 16 })
            .onClick(() => {
              router.pushUrl({url: "pages/HttpDecorator"})
            })

          Button("Http Demo")
            .width("100%").margin({ top: 16 })
            .onClick(() => {
              router.pushUrl({url: "pages/HttpDemo"})
            })

          Button("Download Demo")
            .width("100%").margin({ top: 16 })
            .onClick(() => {
              router.pushUrl({url: "pages/DownloadDemo"})
            })


          Button("Upload Demo")
            .width("100%").margin({ top: 16 })
            .onClick(() => {
              router.pushUrl({url: "pages/UploadDemo"})
            })

          Button("publishNotification")
            .width("100%").margin({ top: 16 })
            .onClick(() => {
              this.publishNotification();
            })

        }
        .height('100%')
        .width('100%')
        .padding({ top: 16 })

      }
      .scrollable(ScrollDirection.Vertical) // 滚动方向纵向
      .scrollBar(BarState.On) // 滚动条常驻显示
      .scrollBarColor(Color.Gray) // 滚动条颜色
      .scrollBarWidth(10) // 滚动条宽度
      .friction(0.6)
      .edgeEffect(EdgeEffect.None)
      .onWillScroll((xOffset: number, yOffset: number, scrollState: ScrollState) => {
        console.info(xOffset + ' ' + yOffset)
      })
      .onScrollEdge((side: Edge) => {
        console.info('To the edge')
      })
      .onScrollStop(() => {
        console.info('Scroll Stop')
      })
      .height('100%')
      .width('100%')
    }
    .height('100%')
    .width('100%')
  }


  publishNotification() {
    notificationManager.isNotificationEnabled().then((data: boolean) => {
      console.info("isNotificationEnabled success, data: " + JSON.stringify(data));
    }).catch((err: BusinessError) => {
      console.error(`isNotificationEnabled fail: ${JSON.stringify(err)}`);
      return;
    });

    // publish回调
    let publishCallback = (err: BusinessError): void => {
      if (err) {
        console.error(`publish failed, code is ${err.code}, message is ${err.message}`);
      } else {
        console.info("publish success");
      }
    }
    // 通知Request对象
    let notificationRequest: notificationManager.NotificationRequest = {
      id: 1,
      content: {
        notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
        normal: {
          title: "test_title",
          text: "test_text",
          additionalText: "test_additionalText"
        }
      },
      // notificationSlotType: notificationManager.SlotType.SOCIAL_COMMUNICATION
    };

    // addslot回调
    let addSlotCallBack = (err: BusinessError): void => {
      if (err) {
        console.error(`addSlot failed, code is ${err.code}, message is ${err.message}`);
      } else {
        console.info("addSlot success");
      }
    }
    notificationManager.addSlot(notificationManager.SlotType.SOCIAL_COMMUNICATION, addSlotCallBack);


    notificationManager.publish(notificationRequest, publishCallback);



  }



}
