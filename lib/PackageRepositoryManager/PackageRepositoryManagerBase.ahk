class PackageRepositoryManagerBase {
    repositoryTypes := Map(
        "volantis", "VolantisPackageRepository",
        "vcs", "VcsPackageRepository"
    )

    repositories := Map()
    knownPackages := Map()
    packageSources := Map()
    packageRepositoryFactory := ""

    __New(packageRepositoryFactory, packageSources := "", repositoryTypes := "") {
        this.packageRepositoryFactory := packageRepositoryFactory

        this.AddPackageSource("github", GithubPackageSource())

        if (packageSources) {
            for key, packageSourceObj in packageSources {
                this.AddPackageSource(key, packageSourceObj)
            }
        }

        if (repositoryTypes) {
            this.packageRepositoryFactory.AddTypes(repositoryTypes)
        }

    }

    AddPackageSource(key, packageSourceObj) {
        this.packageSources[key] := packageSourceObj
    }

    AddType(repositoryType, repositoryClass) {
        this.packageRepositoryFactory.AddType(repositoryType, repositoryClass)
    }

    AddTypes(repositoryTypes) {
        this.packageRepositoryFactory.AddTypes(repositoryTypes)
    }

    SetRepository(repositoryConfig) {
        location := repositoryConfig["location"]

        if (!location) {
            throw DataException("Repository location not specified")
        }

        this.repositories[location] := this.packageRepositoryFactory.CreatePackageRepository(repositoryConfig)

        return this
    }

    SetRepositories(repositoriesConfig) {
        for , repositoryConfig in repositoriesConfig {
            this.SetRepository(repositoryConfig)
        }

        return this
    }

    GetRepositories(repositoriesConfig) {
        repositories := Map()

        for , repositoryConfig in repositoriesConfig {
            location := repositoryConfig["location"]

            if (!location) {
                throw DataException("Repository location not specified")
            }

            repositories[location] := this.GetRepository(repositoryConfig)
        }

        return repositories
    }

    GetRepository(repositoryConfig) {
        location := repositoryConfig["location"]

        if (!location) {
            throw DataException("Repository location not specified")
        }

        if (!this.repositories.Has(location)) {
            this.SetRepository(repositoryConfig)
        }

        return this.repositories[location]
    }

    GetKnownPackages() {
        if (this.knownPackages.Count == 0) {
            for , repository in this.repositories {
                packageList := repository.FetchPackageList()

                for packageName, packageInfo in packageList {
                    this.knownPackages[packageName] := packageInfo
                }
            }
        }

        return this.knownPackages
    }

    GetPackageSourceInfo(packageName) {
        knownPackages := this.GetKnownPackages()

        if (!knownPackages.Has(packageName)) {
            throw DataException("Package not found: " . packageName)
        }

        return knownPackages[packageName]
    }

    GetPackageUrl(packageName) {
        packageSourceInfo := this.GetPackageSourceInfo(packageName)
        packageSourceKey := packageSourceInfo["type"]

        if (!this.packageSources.Has(packageSourceKey)) {
            throw DataException("Package source not found: " . packageSourceKey)
        }

        return this.packageSources[packageSourceKey].GetUrl(packageSourceInfo)
    }
}
