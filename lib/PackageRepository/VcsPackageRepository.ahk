class VcsPackageRepository extends PackageRepositoryBase {
    FetchPackageListFromRepository() {
        packageName := ""

        if (this._repositoryConfig.Has("name")) {
            packageName := this._repositoryConfig["name"]
        } else {
            repoPath := this._packageCache.GetCachedDownload(this._repositoryLocation)
            packageFilePath := repoPath . "/volantis.json"

            if !FileExists(packageFilePath) {
                throw DataException("Couldn't cache repository from " . this._repositoryLocation . ".")
            }

            packageInfoMap := JsonData().FromFile(packageFilePath)

            if (!packageInfoMap.Has("name")) {
                throw DataException("Couldn't determine package name for " . this._repositoryLocation . ".")
            }

            packageName := packageInfoMap["name"]
        }

        return Map(packageName, this._repositoryLocation)
    }
}
