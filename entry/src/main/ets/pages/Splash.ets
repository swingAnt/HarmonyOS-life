
import router from '@ohos.router';
import { CommonConstants as Const} from '../common/constants/CommonConstants';
import { splashImages } from '../viewmodel/SplashModel';
@Entry
@Component
struct Splash {
  // 初始化Swiper实例
  private swiperController: SwiperController = new SwiperController();
  //显示图片
  private data: Resource[] = [];
  //跳转页面时间
  @State countdown: number = Const.COUNTDOWN;
  //是否显示轮播
  @State showSwiper: boolean = false;
  //计时器
  private timer:number = -1;

  aboutToAppear(): void {//aboutToAppear：组件即将出现时回调该接口，具体时机为在创建自定义组件的新实例后，在执行其build()函数之前执行。
    //根据时间初始化一组对应图片
    let hours = new Date().getHours();
    if (hours >= Const.MORNING_TIME && hours < Const.EVENING_TIME) {
      this.data = splashImages.day;
    } else if (hours >= Const.EVENING_TIME && hours <= Const.NIGHT_TIME) {
      this.data = splashImages.dusk;
    } else {
      this.data = splashImages.night;
    }
    setTimeout(() => {//3秒后添加轮播图展示，并开启计时器
      this.showSwiper = true;
      this.startTiming();
    }, Const.SPLASH_DURATION);
  }

  startTiming() {
    this.timer = setInterval(() => {
      this.countdown--; //5秒之后自动跳转页面，清除计时器
      if (this.countdown === 0) {
        this.clearTiming();
        this.jumpToMainPage();
      }
    }, Const.DURATION);
  }

  clearTiming() {//清除计时器
    if (this.timer !== -1) {
      clearInterval(this.timer);
      this.timer = -1;
    }
  }

  jumpToMainPage() {//页面跳转
    this.clearTiming();
    router.replaceUrl({
      url: 'pages/MainPage'
    });
  }

  aboutToDisappear() {//aboutToDisappear：在自定义组件即将析构销毁时执行。
    this.clearTiming();
  }

  build() {
// 执行build方法渲染系统组件，如果子组件为自定义组件，则创建自定义组件的实例。在执行build()函数的过程中，框架会观察每个状态变量的读取状态，将保存两个map：
// 状态变量 -> UI组件（包括ForEach和if）。
// UI组件 -> 此组件的更新函数，即一个lambda方法，作为build()函数的子集，创建对应的UI组件并执行其属性方法
    Column() {
      Stack() {
        if (this.showSwiper) {
          Swiper(this.swiperController) {
            ForEach(this.data, (item: Resource) => {
              Image(item)
                .width(Const.FULL_SIZE)
                .height(Const.FULL_SIZE)
                .objectFit(ImageFit.Cover)
            })
          }
          .loop(true)//通过loop属性控制是否循环播放，该属性默认值为true。如果为false，切换到最后一张则无法切回第一张
          .autoPlay(true)     //autoPlay为true时，会自动切换播放子组件，
          .interval(2 * Const.DURATION)//子组件与子组件之间的播放间隔通过interval属性设置。interval属性默认值为3000，单位毫秒。
          .duration(Const.DURATION)
          .indicatorStyle({//通过indicatorStyle属性自定义导航点的位置和样式。
            bottom: $r('app.float.100'),
            color: $r('app.color.swiper_dot_color')
          })
          .curve(Curve.Linear)
          .onChange((index: number) => {
            console.info(index.toString())
          })

          Text() {
            Span($r('app.string.skip'))
            Span(`${this.countdown}`)
          }
          .onClick(() => this.jumpToMainPage())
          .fontColor(Color.White)
          .fontSize($r('app.float.12fp'))
          .backgroundColor($r('app.color.swiper_jump_bg_color'))
          .width($r('app.float.63'))
          .height($r('app.float.24'))
          .borderRadius($r('app.float.10'))
          .textAlign(TextAlign.Center)
          .position({
            x: Const.PERCENTAGE_78,
            y: $r('app.float.35')
          })
        } else {
          Image($r('app.media.splash_bg'))
            .width(Const.FULL_PERCENT)
            .height(Const.FULL_PERCENT)
          Image($r('app.media.ic_splash'))
            .width($r('app.float.192'))
            .height($r('app.float.192'))
            .offset({
              y: `-${Const.PERCENTAGE_15}`
            })
            .objectFit(ImageFit.Contain)

          Column() {
            Text(Const.SPLASH_DES)
              .fontColor(Color.White)
              .fontSize($r('app.float.font_size_24fp'))
              .fontWeight(FontWeight.Medium)

            Text(Const.SPLASH_WELCOME)
              .fontSize($r('app.float.font_size_16fp'))
              .fontColor(Color.White)
              .margin({
                top: $r('app.float.5')
              })
          }
          .offset({
            y: Const.PERCENTAGE_25
          })
        }
      }
    }
    .height(Const.FULL_SIZE)
    .width(Const.FULL_SIZE)
  }
}
//虚拟像素单位：vp (virtual pixel)
// 以屏幕相对像素为单位, 是一台设备针对应用而言所具有的虚拟尺寸（区别于屏幕硬件本身的像素单位）。它提供了一种灵活的方式来适应不同屏幕密度的显示效果,使用虚拟像素，使元素在不同密度的设备上具有一致的视觉体量。
// 字体像素单位：fp (font pixel)
// 字体像素(font pixel) 大小默认情况下与 vp 相同，即默认情况下 1 fp = 1vp。如果用户在设置中选择了更大的字体，字体的实际显示大小就会在 vp 的基础上乘以 scale 系数，即 1 fp = 1 vp * scale。
// 屏幕像素单位：px (pixel)
// 屏幕上的实际像素, 1px代表手机屏幕上的一个像素点, 如果这个不怎么好理解,看下常见的手机比如:1080×1920  这个数值的单位都是px,由于px在不同手机上的大小不同，差别较大，适配性太差，不建议使用,所以无论是android 还是HarmonyOS 无论写距离大小换是字体大小,都不建议使用px。