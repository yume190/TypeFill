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
 * `PROJECT_PATH`="PATH_TO/xxx.xcodeproj" or "/PATH_TO/Tangran-xxx.xcworkspace"
 * `TARGET_NAME`="Typefill"

### 模式(mode)

 * `assign`
   偵測 assign instance function `x = self.func` or `y(self.func)`.
   詳細
   請參考 [Don't use this syntax!](https://www.youtube.com/watch?v=mzsz_Tit1HA)
 * `capture`
   偵測在 closure 內，被 capture 的 `self`
   [Origin Source Code](https://github.com/grab/swift-leak-check)
