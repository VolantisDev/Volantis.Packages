/**
 * TODO: Calculate individual changes as they occur instead of having to
 * recalculate the entire tree every time.
 */
class PackageDependencyTreeBase {
    repositoryMgr := ""
    repositoryCache := ""
    dependencies := Map()
    dependencyTree := Map()
    mainPackage := ""
    _versionSanitizer := ""
    _versionSorter := ""
    calculatedAt := ""
    changedAt := A_Now

    IsCalculated {
        get => this.calculatedAt != ""
    }

    IsOutdated {
        get => !this.IsCalculated || this.changedAt > this.calculatedAt
    }

    __New(repositoryMgr, repositoryCache, mainPackage) {
        this.repositoryMgr := repositoryMgr
        this.repositoryCache := repositoryCache
        this.mainPackage := mainPackage
    }

    CachePackage(packageName, forceUpdate := false) {
        if  (!this.repositoryCache.ItemExists(packageName) || forceUpdate) {
            packageUrl := this.repositoryMgr.GetPackageUrl(packageName)

            if (packageUrl == "") {
                throw DataException("Package '" . packageName . "' not found")
            }

            this.repositoryCache.WriteItem(packageName, packageUrl)
        }

        return this.repositoryCache.GetCachePath(packageName)
    }

    PackageIsRequired(packageName) {
        this.CalculateDependencies(false)
        return this.dependencies.Has(packageName)
    }

    PackagesChanged(timestamp := "") {
        if (timestamp == "") {
            timestamp := A_Now
        }

        this.changedAt := timestamp
    }

    /**
     * Format: Map[versionString, vcsRef]
     *
     * Ex:
     * Map(
     *   "1.0.0", "v1.0.0",
     *   "dev-main", "main"
     * )
     */
    GetAvailableVersions(packageName, constraint := "") {
        versions := ""

        ; TODO: If version constraint is a commit hash, dev branch, or specific version, return that version alone
        constraintVersion := ""

        if (constraintVersion) {

        } else {
            ; TODO: Retrieve all package versions
            versions := Map()

            if (constraint) {
                versions := ListFilter(versions)
                    .Condition(, "{}") ; TODO: Use a new condition here to filter for versions that match the constraint
                    .Execute()
            }
        }



        return versions
    }

    ResolveSingleVersionFromConstraint(constraint) {
        singleVersion := ""



        IsValidVersionCondition()
        return this._versionSanitizer.IsVersion(constraint)

        return singleVersion
    }

    GetRecommendedVersion(packageName, constraint := "") {
        if (constraint == "") {
            constraint := "*"
        }

        ; TODO: Check if constraint is a commit hash. If so, set it as the version and validate that it exists

        version := ""

        if (version == "") {
            versions := this.GetAvailableVersions(packageName, constraint)

            if (versions.Count == 0) {
                throw DataException("No matching versions found for package '" . packageName . "'")
            }

            version := this._versionSorter.GetRecommendedVersion(versions)
        }
    }

    PackageIsCompatible(packageNameOrObj, versionConstraint) {
        packageName := ""
        packageObj := ""

        if (packageNameOrObj.HasBase(PackageBase.Prototype)) {
            packageObj := packageNameOrObj
            packageName := packageObj.Name
        } else {
            packageName := packageNameOrObj
        }

        packagePath := this.CachePackage(packageName)

        ; TODO: Figure out best version to install based on the version constraint

        ; TODO: Check out the volantis.json file from the selected version and read the dependencies from it

        ; TODO: Check if the provided package and version are compatible with the existing tree
    }

    PackageModified(packageName) {
        ; TODO: Recalculate dependencies for the tree of the provided package only
    }

    CalculateDependencies(recalculate := false) {
        this.dependencyTree := this.CalculateDependenciesForPackage(this.mainPackage, recalculate)
    }

    GetVersionConstraint(versionConstraint) {
        if (versionConstraint.HasBase(Map.Prototype)) {
            if (!versionConstraint.Has("version")) {
                throw DataException("Version constraint must have a version property.")
            }

            versionConstraint := versionConstraint["version"]
        }

        return versionConstraint
    }

    CalculateDependenciesForPackage(packageObj, forceRecalculate := false, saveToDependencies := true) {
        packageExists := this.dependencies.Has(packageObj.Name)

        if (!packageExists || forceRecalculate) {
            packageDependencies := Map()

            for packageName, versionConstraint in packageObj.PackageInfo.Dependencies {
                versionConstraint := this.GetVersionConstraint(versionConstraint)

                if (!this.PackageIsCompatible(packageName, versionConstraint)) {
                    throw DataException("Package '" packageName "' is not compatible with the other dependencies.")
                }


            }

            this.dependencies[packageObj.Name] := Map(
                "package", packageObj,
                "versionConstraint", "", ; TODO: Get current app version?
                "dependencies", packageDependencies
            )
        }

        return this.dependencies[packageObj.Name]["dependencies"]
    }

    CreateDependency(packageName, versionConstraint) {
        return SimplePackageDependency(packageName, versionConstraint)
    }
}
