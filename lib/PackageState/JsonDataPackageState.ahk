class JsonDataPackageState extends PackageStateBase {
    _loadState(stateFilePath) {
        this.parameters.Replace(JsonData().FromFile(stateFilePath))
    }

    _saveState(stateFilePath) {
        dataObj := JsonData()
        dataObj.Obj := this.parameters.Get()
        dataObj.ToFile(stateFilePath)
    }
}
