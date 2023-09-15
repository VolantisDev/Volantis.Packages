class JsonDataPackageInfo extends PackageInfoBase {
    jsonDataObj := ""

    _readPackageInfoFile(infoFileLocation) {
        if (!this.jsonDataObj) {
            this.jsonDataObj := JsonData()
        }

        return this.jsonDataObj.FromFile(infoFileLocation)
    }

    _writePackageInfoFile(packageInfo, infoFileLocation) {
        if (!this.jsonDataObj) {
            this.jsonDataObj := JsonData()
        }

        this.jsonDataObj.Obj := packageInfo
        this.jsonDataObj.ToFile(infoFileLocation)
        return true
    }
}
