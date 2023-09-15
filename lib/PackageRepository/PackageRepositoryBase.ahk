class PackageRepositoryBase {
    _repositoryType := ""
    _repositoryLocation := ""
    _repositoryCache := ""
    _packageCache := ""
    packagesData := ""
    _repositoryConfig := ""

    RepositoryType {
        get {
            return this.repositoryTypeStr
        }
    }

    RepositoryLocation {
        get {
            return this.repositoryLocationStr
        }
    }

    __New(repositoryConfig, repositoryCache, packageCache) {
        this._repositoryConfig := repositoryConfig
        this._repositoryCache := repositoryCache
        this._packageCache := packageCache

        if (Type(repositoryConfig) == "String") {
            repositoryConfig := Map(
                "type", "volantis",
                "location", repositoryConfig
            )
        } else if (!repositoryConfig.Has("type")) {
            repositoryConfig["type"] := "volantis"
        }

        this._repositoryType := repositoryConfig["type"]

        if (repositoryConfig.Has("location")) {
            this._repositoryLocation := repositoryConfig["location"]
        }
    }

    FetchPackageList() {
        if (this.packagesData == "") {
            if (this._repositoryCache.ItemExists("packages.json")) {
                this.packagesData := JsonData().FromString(this._repositoryCache.ReadItem("packages.json"))
            } else {
                this.packagesData := this.FetchPackageListFromRepository()
                this._repositoryCache.WriteItem("packages.json", JsonData(this.packagesData).ToString())
            }
        }

        return this.packagesData
    }

    FetchPackageListFromRepository() {
        throw MethodNotImplementedException("PackageRepositoryBase", "FetchPackageListFromRepository")
    }
}
