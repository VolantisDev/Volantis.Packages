class PackageRepositoryFactoryBase {
    _cacheDir := ""
    _tmpDir := ""
    _versionSorter := ""
    _repositoryTypes := Map(
        "volantis", "VolantisPackageRepository",
        "vcs", "VcsPackageRepository"
    )

    __New(cacheDir, tmpDir, versionSorter, repositoryTypes := "") {
        this._versionSorter := versionSorter
        this._cacheDir := cacheDir
        this._tmpDir := tmpDir

        if (repositoryTypes != "") {
            this.AddTypes(repositoryTypes)
        }
    }

    CreatePackageRepository(repositoryConfig) {
        if (!repositoryConfig.Has("location")) {
            throw DataException("Repository location not specified")
        }

        location := repositoryConfig["location"]
        repositoryType := repositoryConfig.Has("type") ? repositoryConfig["type"] : "volantis"

        if (!this._repositoryTypes.Has(repositoryType)) {
            throw DataException("Unknown repository type: " + repositoryType)
        }

        repositoryClass := this._repositoryTypes[repositoryType]

        if (!IsSet(%repositoryClass%)) {
            throw DataException("Unknown repository class: " + repositoryClass)
        }

        subdirName := this.GetCacheSubdirFromLocation(location)
        tmpDir := this._tmpDir . "\" . subdirName
        cacheDir := this._cacheDir . "\" . subdirName

        return %repositoryClass%(
            repositoryConfig,
            this.CreateRepositoryCache(cacheDir, tmpDir),
            this.CreatePackageCache(cacheDir, tmpDir)
        )
    }

    CreateRepositoryCache(cacheDir, tmpDir) {
        packageRepoCacheState := CacheState(
            cacheDir . "\repository",
            "repository-state",
            this._versionSorter
        )

        return FileCache(
            tmpDir . "\repository",
            packageRepoCacheState,
            cacheDir,
            "repository"
        )
    }

    CreatePackageCache(cacheDir, tmpDir) {
        vcsRepoCacheState := CacheState(
            cacheDir . "\packages",
            "packages-state",
            this._versionSorter
        )

        return VcsRepositoryCache(
            SimpleRepositoryManager(),
            tmpDir . "\packages",
            vcsRepoCacheState,
            cacheDir, "packages")
    }

    GetCacheSubdirFromLocation(location) {
        location := StrLower(location)
        location := StrReplace(location, "http://")
        location := StrReplace(location, "https://")
        location := StrReplace(location, "\", "--")
        location := StrReplace(location, "/", "--")
        location := StrReplace(location, ":", "--")
        return location
    }

    AddTypes(repositoryTypes) {
        for repositoryType, repositoryClass in repositoryTypes {
            this.AddType(repositoryType, repositoryClass)
        }
    }

    AddType(repositoryType, repositoryClass) {
        this._repositoryTypes[repositoryType] := repositoryClass
    }
}
