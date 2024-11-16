import { AbilityStage } from '@kit.AbilityKit';
import { AuthInterceptor } from '../interceptor/AuthInterceptor';
import { EntryHttpConfiguration } from '../interceptor/EntryHttpConfiguration';
// import { LocalHttpConfiguration } from 'setting/src/main/ets/abilitystage/LocalHttpConfiguration';
import { HttpConfigurationManager, HttpInterceptorManager } from 'httpProxy';
import { TempInterceptor } from '../interceptor/TempInterceptor';

export default class EntryAbilityStage extends AbilityStage {

  onCreate(): void {
    console.log("limin", "EntryAbilityStage.....");

    HttpInterceptorManager.getInstance().register(new AuthInterceptor());
    HttpInterceptorManager.getInstance().register(new TempInterceptor());

    HttpConfigurationManager.getInstance().register(new EntryHttpConfiguration());

    let moduleName = 'httpProxy';
    import(moduleName).then((es:ESObject) => {
      HttpInterceptorManager.getInstance().register(new es["ResultInterceptor"]());
      HttpConfigurationManager.getInstance().register(new es["LocalHttpConfiguration"]());
    });

  }

}