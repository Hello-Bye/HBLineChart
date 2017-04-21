# HBLineChart
一个用来画曲线图的view

##PS:测试cocoapods的

##Use CocoaPods install
###首先你需要支持CocoaPods，（已经安装过的直接跳过）

CocoaPods是一个Ruby Gem，因为直接访问RubyGem速度非常慢，建议先替换成淘宝镜像

```
$ gem sources --remove https://rubygems.org/ 
$ gem sources -a https://ruby.taobao.org/
```
安装CocoaPods

```
$ sudo gem install cocoapods
```
###管理第三方库
####创建Podfile
在项目根目录下创建Podfile，[Podfile的例子](http://guides.cocoapods.org/syntax/podfile.html#podfile)

```
platform :ios, '9.0'
 
target "MyApp" do
  pod 'HBLineChart', '~> 0.0.2'
end
```
####安装Pods
安装 pods

```
$ pod install
```
更新 pods

```
$ pod update
```
