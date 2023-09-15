class VolantisPackageRepository extends PackageRepositoryBase {
    _repositoryFilename := "volantis-packages.json"
    repoData := ""

    FetchPackageListFromRepository() {
        if (this.repoData == "") {
            repositoryUrl := this._repositoryLocation . "/" . this._repositoryFilename
            filePath := this._repositoryCache.GetCachedDownload(this._repositoryFilename, repositoryUrl)
            this.repoData := JsonData().FromFile(filePath)
        }

        packages := Map()

        if (this.repoData.Has("packages")) {
            for , packageDefinition in this.repoData["packages"] {
                packageName := packageDefinition["name"]
                packages[packageName] := packageDefinition
            }
        }

        return packages
    }
}
