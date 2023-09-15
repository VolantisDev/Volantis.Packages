class PackageDependencyBase {
    _packageName := ""
    _versionConstraint := ""
    _extraData := Map()
    _dependencies := Map()

    PackageName {
        get => this._packageName
    }

    VersionConstraint {
        get => this._versionConstraint
    }

    ExtraData {
        get => this._extraData
    }

    Dependencies {
        get => this._dependencies
    }

    __New(packageName, versionConstraint) {
        this._packageName := packageName

        if (versionConstraint.HasBase(Map.Prototype)) {
            extraData := versionConstraint

            if (!extraData.Has("version")) {
                throw Exception.New("InvalidArgument", "Version constraint must have a version key if it is a map.")
            }

            versionConstraint := extraData["version"]
            extraData.Delete("version")
            this._extraData := extraData
        }

        this._versionConstraint := versionConstraint
    }

    AddDependencies(dependencies) {
        for (dependencyName, dependencyVersionConstraint in dependencies) {
            this.AddDependency(dependencyName, dependencyVersionConstraint)
        }
    }

    AddDependency(dependencyName, dependencyVersionConstraint) {
        this._dependencies[dependencyName] := this.Prototype.Create(dependencyName, dependencyVersionConstraint)
    }

    static Create(name, versionConstraint) {
        return this(name, versionConstraint)
    }
}
