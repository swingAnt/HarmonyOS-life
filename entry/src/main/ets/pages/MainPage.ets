

import { CommonConstants as Const } from '../common/constants/CommonConstants';
import { Map } from '../view/MapComponent';
import { Zones } from '../view/ZonesComponent';
import { Trains } from '../view/TrainsComponent';
import { BottomTabsList } from '../viewmodel/BottomTabsModel';

@Entry
@Component
struct MainPage {
  // 当底部标签栏index改变时调用onIndexChange()方法，改变Tabs组件的index
  @State @Watch('onIndexChange') bottomTabIndex: number = 1;
  private controller: TabsController = new TabsController();

//设置自定义导航栏需要使用tabBar的参数，以其支持的CustomBuilder的方式传入自定义的函数组件样式。
  @Builder TabBuilder(index: number, _name: string) {
    Column() {
      Image(this.bottomTabIndex === index ? BottomTabsList[index].iconSelected : BottomTabsList[index].icon)
        .width(Const.ICON_SIZE)
        .height(Const.ICON_SIZE)
        .objectFit(ImageFit.Contain)

      Text(BottomTabsList[index].text)
        .fontSize($r('app.float.bottom_font_size'))
        .opacity(Const.OPACITY)
        .fontColor(this.bottomTabIndex === index ?
        $r('app.color.bottom_tabs_font_color_selected') : $r('app.color.bottom_tabs_font_color'))
    }
    .width(Const.FULL_PERCENT)
    .height(Const.FULL_PERCENT)
    .justifyContent(FlexAlign.Center)
    .border({ width: { top: Const.BORDER_WIDTH }, color: $r('app.color.color_border') })
    .backgroundColor($r('app.color.bottom_tabs_background_color'))
  }

  onIndexChange() {
    this.controller.changeIndex(this.bottomTabIndex);
  }
  //在区域导览页点击跳转到区域详情页时，使用pageTransition函数实现了界面跳转过程中的动画效果
  //在区域导览所在的@Entry界面和详情页所在的@Entry界面里使用pageTransition函数来改变他们入场和出场时的方向、缩放大小和透明度等。
  //进入动画（PageTransitionEnter）和退出动画（PageTransitionExit）。
  //进入动画使用.slide(SlideEffect.Top)方法从顶部滑入页面，持续时间由Const.SHARED_DURATION常量定义。
  pageTransition() {
    PageTransitionEnter({ duration: Const.SHARED_DURATION })
      .slide(SlideEffect.Top)
    PageTransitionExit({ delay: Const.EXIT_DELAY })
      .opacity(0)
  }

  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.End, justifyContent: FlexAlign.End }) {
      Tabs({ barPosition: BarPosition.End, index: 1, controller: this.controller }) {
        TabContent() {
          // “地图浏览”页
          Map()
        }.tabBar(this.TabBuilder(0, 'Map'))

        TabContent() {
          // “区域导览”页
          Zones()
        }.tabBar(this.TabBuilder(1, 'Zone'))

        TabContent() {
          // “小火车”页
          Trains()
        }.tabBar(this.TabBuilder(2, 'Train'))
      }
      .width(Const.FULL_PERCENT)
      .height(Const.FULL_PERCENT)
      .vertical(false)
      .scrollable(false)
      .barHeight(Const.BAR_HEIGHT)
      .onChange((index: number) => {
        // 当标签页切换时改变底部标签栏组件的index
        this.bottomTabIndex = index;
      })
    }
    .width(Const.FULL_PERCENT)
  }
}