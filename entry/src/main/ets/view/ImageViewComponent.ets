/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import window from '@ohos.window';

import ZonesItem from '../viewmodel/ZonesItem';
import { CommonConstants as Const } from '../common/constants/CommonConstants';
import { DeviceScreen } from '../common/utils/DeviceScreen';

@CustomDialog
export struct ImageView {
  private controller: CustomDialogController = new CustomDialogController({
    builder: ImageView(),
  });
  private windowClass: window.Window | null = null;
  private deviceWidth: number = 0;
  private deviceHeight: number = 0;
  private imgWidth: number = 0;
  private imgHeight: number = 0;
  private displayHeight: number = 0
  @Consume('introductionData') introductionData: ZonesItem;
  @Prop currentImageId: number = 0;
  @State curIndex: number = this.currentImageId;
  @State isGesture: boolean = false;
  @State imgScale: number = 1;
  @State curScale: number = 1;
  @State imgOffsetX: number = 0;
  @State imgOffsetY: number = 0;
  @State preOffsetX: number = 0;
  @State preOffsetY: number = 0;

  aboutToAppear() {
    let deviceSize = DeviceScreen.getDeviceSize(getContext(this));
    deviceSize.then((data: window.Window) => {
      this.windowClass = data;
      let properties = this.windowClass.getWindowProperties();
      this.deviceWidth = properties.windowRect.width;
      this.deviceHeight = properties.windowRect.height;
    });
  }

  /**
   * Detect boundary to keep the image in window.
   */
  detectBoundary(): void {
    let maxOffsetX = this.imgScale * this.deviceWidth / 2 - this.deviceWidth / 2;
    if (vp2px(this.imgOffsetX) > (maxOffsetX)) {
      this.imgOffsetX = px2vp(maxOffsetX);
    }
    if (vp2px(this.imgOffsetX) < -(maxOffsetX)) {
      this.imgOffsetX = -px2vp(maxOffsetX);
    }
    let maxOffsetY = this.imgScale * this.displayHeight / 2 - this.deviceHeight / 2;
    if (this.imgScale * this.displayHeight >= this.deviceHeight) {
      if (vp2px(this.imgOffsetY) > (maxOffsetY)) {
        this.imgOffsetY = px2vp(maxOffsetY);
      }
      if (vp2px(this.imgOffsetY) < -(maxOffsetY)) {
        this.imgOffsetY = -px2vp(maxOffsetY);
      }
    } else {
      this.imgOffsetY = 0;
    }
  }

  /**
   * Limit scale to keep the image clear.
   */
  limitScale(isReset: boolean): void {
    if (this.imgScale < 1) {
      this.imgScale = 1;
      this.curScale = 1;
      if (isReset) {
        this.imgOffsetX = 0;
        this.imgOffsetY = 0;
      }
      this.isGesture = false;
    } else if (this.imgScale > Const.MAX_SCALE) {
      this.imgScale = Const.MAX_SCALE;
      this.curScale = Const.MAX_SCALE;
    } else {
      this.curScale = this.imgScale;
    }
  }

  build() {
    Stack() {
      Swiper() {
        ForEach(this.introductionData.imageList, (item: Resource) => {
          Column() {
            // 使用Blank组件填充空白处，点击可以关闭弹窗
            Blank()
              .onClick(() => {
                this.controller.close();
              })

            Image(item)
              .width(Const.FULL_PERCENT)
              .objectFit(ImageFit.Contain)
                // 触发捏合手势
              .gesture(
              PinchGesture()
                .onActionStart(() => {
                  // 识别到手势操作，将isGesture设为true
                  this.isGesture = true;
                  })
                  .onActionUpdate((event?: GestureEvent) => {
                    if (!event) {
                      return;
                    }
                    // 随着捏合操作的过程，逐渐调整图片缩放倍数
                    this.imgScale = this.curScale * event.scale;
                  })
                  .onActionEnd(() => {
                    // 为了避免图片无限缩放，在捏合操作结束时控制缩放倍数的值
                    this.limitScale(false);
                  })
              )

            Blank()
              .onClick(() => {
                this.controller.close();
              })
          }
          .width(Const.FULL_PERCENT)
          .height(Const.FULL_PERCENT)
          .justifyContent(FlexAlign.Center)
        })
      }
      .width(Const.FULL_PERCENT)
      .height(Const.FULL_PERCENT)
      .loop(false)
      .indicatorStyle({
        bottom: $r('app.float.indicator_bottom'),
        color: Color.Gray
      })
      .index(this.curIndex)
      .onChange((index: number) => {
        // swiper滑动时记录切换的index
        this.curIndex = index;
      })
      .visibility(this.isGesture ? Visibility.Hidden : Visibility.Visible)

      Row() {
        // 根据切换的index显示对应的图片
        Image(this.introductionData.imageList[this.curIndex])
          .objectFit(ImageFit.Contain)
            // 控制图片缩放倍数
          .scale({ x: this.imgScale, y: this.imgScale })
            // 控制图片偏移值
          .translate({ x: this.imgOffsetX, y: this.imgOffsetY })
          .onComplete((event) => {
            if (!event) {
              return;
            }
            this.imgWidth = event.width;
            this.imgHeight = event.height;
            // 根据图片宽高计算图片不缩放时的实际高度
            this.displayHeight = this.deviceWidth * this.imgHeight / this.imgWidth;
          })
      }
      .gesture(
        // 触发捏合手势
      PinchGesture()
          .onActionUpdate((event?: GestureEvent) => {
            if (!event) {
              return;
            }
            // 随着捏合操作的过程，逐渐调整图片缩放倍数
            this.imgScale = this.curScale * event.scale;
          })
          .onActionEnd(() => {
            // 为了避免图片偏移超出屏幕边界，检测到偏移值到达最大时停止继续偏移
            this.detectBoundary();
            // 为了避免图片无限缩放，在捏合操作结束时控制缩放倍数的值，并重置偏移值
            this.limitScale(true);
          })
      )
      .gesture(
        // 触发拖动手势
      PanGesture()
          .onActionStart(() => {
            // 记录先前的偏移值
            this.preOffsetX = this.imgOffsetX;
            this.preOffsetY = this.imgOffsetY;
          })
          .onActionUpdate((event?: GestureEvent) => {
            if (!event) {
              return;
            }
            // 随着拖动操作的过程，不断改变图片偏移值
            this.imgOffsetX = this.preOffsetX + event.offsetX;
            this.imgOffsetY = this.preOffsetY + event.offsetY;
          })
          .onActionEnd(() => {
            // 为了避免图片偏移超出屏幕边界，检测到偏移值到达最大时停止继续偏移
            this.detectBoundary();
          })
      )
      // 根据isGesture的值来控制显隐
      .visibility(this.isGesture ? Visibility.Visible : Visibility.Hidden)
    }
    .width(Const.FULL_PERCENT)
    .height(Const.FULL_PERCENT)
    .linearGradient({
      direction: GradientDirection.Top,
      colors: [[$r('app.color.color_gradient_1'), Const.COLOR_SCALE_1], [$r('app.color.color_gradient_2'), Const.COLOR_SCALE_2]]
    })
  }
}