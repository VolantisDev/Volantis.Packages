class PackageInfoBase {
    readOnly := ""
    infoFileLocation := ""
    packageInfo := ""
    packageInfoLoaded := false

    Name {
        get => this.Get("name")
        set => this.Set("name", value)
    }

    PackageType {
        get => this.Get("type", "package")
        set => this.Set("type", value)
    }

    Dependencies {
        get => this.Get("require", Map(), true)
        set => this.Set("require", value)
    }

    DevDependencies {
        get => this.Get("require-dev", Map(), true)
        set => this.Set("require-dev", value)
    }

    Repositories {
        get => this.Get("repositories", Map(), true)
        set => this.Set("repositories", value)
    }

    __Item[key] {
        get => this.Get(key)
        set => this.Set(key, value)
    }

    __New(infoFileLocation := "", readOnly := true) {
        this.readOnly := readOnly
        this.infoFileLocation := infoFileLocation
        this.packageInfo := ParameterBag()

        if (infoFileLocation != "") {
            this.ReadPackageInfo()
        }
    }

    Has(field) {
        if (!this.packageInfoLoaded && this.infoFileLocation) {
            this.ReadPackageInfo()
        }

        return this.packageInfo.Has(field)
    }

    Get(field, defaultValue := "", setDefaultIfUnset := false) {
        if (!this.packageInfoLoaded && this.infoFileLocation) {
            this.ReadPackageInfo()
        }

        if (!this.packageInfo.Has(field) && setDefaultIfUnset) {
            this.packageInfo[field] := defaultValue
        }

        return this.packageInfo.Get(field, defaultValue)
    }

    Set(field, value) {
        if (!this.packageInfoLoaded && this.infoFileLocation) {
            this.ReadPackageInfo()
        }

        this.packageInfo.Set(field, value)
    }

    ReadPackageInfo(reload := false) {
        if (!this.packageInfoLoaded || reload) {
            packageInfo := this._readPackageInfoFile(this.infoFileLocation)

            if (packageInfo) {
                this.packageInfo.Replace(packageInfo)
                this.packageInfoLoaded := true
            }
        }

        return this
    }

    _readPackageInfoFile(infoFileLocation) {
        throw MethodNotImplementedException("PackageInfoBase", "_readPackageInfoFile")
    }

    WritePackageInfo() {
        if (!this.readOnly  && this.infoFileLocation) {
            this._writePackageInfoFile(this.packageInfo.All(), this.infoFileLocation)
        }

        return this
    }

    _writePackageInfoFile(packageInfo, infoFileLocation) {
        throw MethodNotImplementedException("PackageInfoBase", "_writePackageInfoFile")
    }
}
