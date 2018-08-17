# PKHUrlManager

## 👣 웹 url에서 json으로 미리 지정해놓은 값이 들어올경우 특정 함수를 실행해주는 매니져..

![blogimg](https://github.com/pkh0225/PKHUrlManager/blob/master/screen.png)

## Core Functions


```
func runFunction(url: String, instanc: NSObject? = nil, data: [String: Any]? = nil) -> Bool {
        if type == .webAction && webFunctionRun == true {
            return true
        }
        
        webFunctionRun = true
        defer {
            webFunctionRun = false
        }
        guard let funNames = self.funNames else { return true }
        
        
        
        
        
        var toData: [String: Any?]!
        if data == nil {
            toData = [URLParserCallNames: [self.name], "data": self.data]
        }
        else {
            toData = data
            toData.updateValue(self.data, forKey: "data")
            if var names = toData[URLParserCallNames] as? [String] {
                names.append(self.name)
                toData.updateValue(names, forKey: URLParserCallNames)
            }
            else {
                toData.updateValue([self.name], forKey: URLParserCallNames)
            }
        }
        
        
        for (classType, function) in funNames {
            
            if let aInstanc = instanc , aInstanc.responds(to: function) {
                if let _ = aInstanc.perform(function, with: url, with: toData) {
                    returnValue = true
                }
                else {
                    returnValue = false
                }
                #if DEBUG
                print("\t 🌈 RunFunction \(aInstanc.className).\(function), data: \(toData), return: \(returnValue)\n")
                #else
                #endif
                
            }
            else {
                guard let nsobjAbleType = classType as? NSObject.Type else {
                    preconditionFailure(" >>>>> Class Not NSObject")
                    continue
                }
                let obj = nsobjAbleType.init()
                guard obj.responds(to: function) else {
                    preconditionFailure(" >>>>> \(classType) Not function")
                    continue
                }
                
                if let _ = obj.perform(function, with: url, with: toData) {
                    returnValue = true
                }
                else {
                    returnValue = false
                }
                #if DEBUG
                print("\t 🌈 RunFunction \(nsobjAbleType.className)).\(function), data: \(toData), return: \(returnValue)\n")
                #else
                #endif
                
            }
            
        }
        
        return returnValue
    }

```
