class PackageManagerBase {
    _projectDir := ""
    cacheDir := ""
    tmpDir := ""
    projectPackage := ""
    repositoryMgr := ""
    dependencyTree := ""
    stateFileName := "volantis.state.json"
    projectStateObj := ""
    packagePaths := Map(
        "package", "volantis/packages",
        "library", "volantis/libraries",
        "application", "volantis/applications",
        "script", "volantis/scripts",
        "command", "volantis/commands",
        "module", "volantis/modules",
        "theme", "assets/themes/managed",
        "image-pack", "assets/images/managed",
        "icon-pack", "assets/icons/managed",
        "external", "assets/ext/managed"
    )

    Repositories {
        get => this.repositoryMgr
    }

    ProjectDir {
        get => this._projectDir
    }

    StateFilePath {
        get => this.ProjectDir . "\" . this.stateFileName
    }

    ProjectState {
        get => this.projectStateObj
        set => this.projectStateObj := value
    }

    __New(projectDir, cacheDir, tmpDir, versionSanitizerObj, versionSorter) {
        this._projectDir := projectDir
        this.cacheDir := cacheDir
        this.tmpDir := tmpDir
        repositoryFactory := SimplePackageRepositoryFactory(cacheDir, tmpDir, versionSorter)
        this.repositoryMgr := SimplePackageRepositoryManager(repositoryFactory)
        this.projectPackage := ProjectPackage(projectDir, cacheDir)
        this.projectStateObj := JsonDataPackageState(this.StateFilePath)
        this.dependencyTree := SimplePackageDependencyTree(
            this.repositoryMgr,
            this.projectPackage,
            versionSanitizerObj,
            versionSorter
        )

        this.repositoryMgr.RegisterRepositoryType(
            "git",
            "GitRepository",
            SimpleRepositoryTypeDetector("git", ".git", ".git"),
            Map()
        )

        if (this.projectPackage.PackageInfo.Has("paths")) {
            for packageType, packagePath in this.projectPackage.PackageInfo["paths"] {
                this.packagePaths[packageType] := packagePath
            }
        }

        if (this.projectPackage.PackageInfo.Has("repositories")) {
            this.repositoryMgr.SetRepositories(this.projectPackage.PackageInfo.Repositories)
        }
    }

    /**
     * If creating a PackageManager for a project extending AppBase or using another service container,
     * this static method can be used as a shortcut to create a new instance using known container
     * parameters/services.
     */
    static Create(container, projectDir := "", cacheDir := "", tmpDir := "") {
        className := this.Prototype.__Class

        if (projectDir == "") {
            projectDir := container.Parameter["app_dir"]
        }

        if (tmpDir == "") {
            tmpDir := container.Parameter["tmp_dir"]
        }

        if (cacheDir == "") {
            baseDir := container.HasParameter("config.cache_dir") ?
                container.Parameter["config.cache_dir"] :
                tmpDir . "\cache"
            cacheDir := baseDir . "\packages"
        }

        return %className%(
            projectDir,
            cacheDir,
            tmpDir
            container["version.sanitizer"],
            container["version.sorter"]
        )
    }

    CalculateDependencies(recalculate := false) {
        this.dependencyTree.CalculateDependencies(recalculate)
    }

    CachePackage(packageName, forceUpdate := false) {
        ; TODO Rewrite this because cache should be managed by each repository instance
        if  (!this.repositoryCache.ItemExists(packageName) || forceUpdate) {
            packageUrl := this.repositoryMgr.GetPackageUrl(packageName)

            if (packageUrl == "") {
                throw DataException("Package '" . packageName . "' not found")
            }

            this.repositoryCache.WriteItem(packageName, packageUrl)
        }
    }

    RemovePackageFromCache(packageName) {
        ; TODO Rewrite this because cache should be managed by each repository instance
        this.repositoryCache.RemoveItem(packageName)
    }

    PackageIsRequired(packageName) {
        return this.dependencyTree.PackageIsRequired(packageName)
    }

    WriteProjectInfoFile(saveBackup := true) {
        if (saveBackup) {
            this.BackupProjectInfoFile()
        }

        this.projectPackage.PackageInfo.WritePackageInfo()
    }

    DetermineDefaultPackageVersion(versionConstraint) {
        ; TODO: Calculate highest version comaptible with configuration
        throw MethodNotImplementedException("PackageManagerBase", "DetermineDefaultPackageVersion")
    }

    PackageIsCompatible(packageName, versionConstraint) {
        return this.dependencyTree.PackageIsCompatible(packageName, versionConstraint)
    }

    StandardizeVersionConstraintInfo(packageInfo) {
        if (!packageInfo.HasBase(Map.Prototype)) {
            packageInfo := Map(
                "version", packageInfo
            )
        }

        return packageInfo
    }

    Require(packageName, versionConstraint := "", dev := false) {
        versionConstraintInfo := this.StandardizeVersionConstraintInfo(versionConstraint)
        versionConstraint := versionConstraintInfo["version"]

        if (!versionConstraint) {
            versionConstraint := this.DetermineDefaultPackageVersion(versionConstraint)
        }

        if (!versionConstraint) {
            throw DataException("No valid version found for '" . packageName . "'")
        }

        if (!this.PackageIsCompatible(packageName, versionConstraint)) {
            throw DataException("Package '" . packageName . "' is not compatible with existing dependencies.")
        }

        this.projectPackage.PackageInfo.Dependencies[packageName] := versionConstraintInfo
        this.dependencyTree.PackageModified(packageName)
        this.CachePackage(packageName)
        this.InstallPackageFromCache(packageName, versionConstraint)
        this.projectPackage.PackageInfo.WritePackageInfo()
        this.UpdatePackageState()
    }

    UpdatePackageState() {
        ; TODO: Update the state file and save
    }

    InstallPackageFromCache(packageName, versionConstraint) {
        this.CachePackage(packageName)

        ; TODO: Install the correct version from cache
    }

    Remove(packageName) {
        ; TODO: Implement

        if (!this.PackageIsRequired(packageName)) {
            this.RemovePackageFromCache(packageName)
        }

        this.dependencyTree.PackagesChanged()
    }

    Install(includeDev := true) {
        ; TODO: Implement
    }

    Update(includeDev := true) {
        ; TODO: Implement

        this.dependencyTree.PackagesChanged()
    }
}
