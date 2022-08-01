# SRToast
一个加载和提示模块

# 安装方法
    在Podfile中添加 pod 'SRToast','~> 0.0.8'
    然后使用 pod install 命令
    
# 使用方法
    加载框使用：
    let hub = self.view.showHub()
    hub.setHubContent(value: "中途改变文字")
    hub.remove()

    提示使用：
    let tip = self.view.showTip(value: "提示文字") { tap in
        if tap{
            print("点击消失")
        }else{
            print("自动消失")
        }
    }
    tip.setTipContent(value: "中途改变文字")
