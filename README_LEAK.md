# Leak Detect

---

一個偵測 swift 潛在 leaks 的小工具

## 安裝

``` bash
mint install yume190/typefill
```

## 使用方式

``` bash
USAGE: command [--verbose] [--mode <mode>]
```

### 必要的環境參數

 * `PROJECT_TEMP_ROOT`/`PROJECT_PATH`
 * `TARGET_NAME`

#### 參數範例

 * `PROJECT_TEMP_ROOT`="/PATH_TO/DerivedData/TypeFill-abpidkqveyuylveyttvzvsspldln/Build/Intermediates.noindex"
 * `PROJECT_PATH`="/PATH_TO/xxx.xcodeproj" or "/PATH_TO/Tangran-xxx.xcworkspace"
 * `TARGET_NAME`="Typefill"

> PROJECT_PATH 相對路徑，雖然叫做 PROJECT_PATH 但是請填入以妳主要開啟的檔案為主

> PROJECT_TEMP_ROOT 絕對路徑

### 模式(mode)

 * `assign`
 * `capture`

#### Assign

偵測 assign instance function `x = self.func` or `y(self.func)`.
詳細請參考 [Don't use this syntax!](https://www.youtube.com/watch?v=mzsz_Tit1HA)

|範例|Inspect|Leak|
|:--|:-----:|:---:|
|`let x = self.func`|X| |
|`x = self.func`|func|O|
|`x = func`|func|O|
|`y(instanceF1, staticF, instanceF1)`|instanceF1, staticF, instanceF1|instanceF1, instanceF1|

#### Capture

偵測在 closure 內，被 capture 的 `self`
[Origin Source Code](https://github.com/grab/swift-leak-check)

## 目前已知問題

> TARGET_NAME 請不要含有 `-` 或 `_`

> assign mode 會誤判 `button.addTarget(self, ...)` 的 self

> capture mode 會誤判 在 ResultBuilder 的 non escaping closure
