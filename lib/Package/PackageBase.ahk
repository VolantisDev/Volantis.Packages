class PackageBase {
    packageName := ""
    packageInfoObj := ""
    packageDir := ""
    projectPackageObj := ""
    infoFileName := "volantis.json"

    Name {
        get => this.packageName
        set => this.packageName := value
    }

    Dir {
        get => this.packageDir
        set => this.packageDir := value
    }

    InfoFilePath {
        get => this.Dir . "/" . this.infoFileName
    }

    Project {
        get => this.projectPackageObj
    }

    IsProject {
        get => false
    }

    ProjectDir {
        get => this.Project.Dir
    }

    PackageInfo {
        get => this.packageInfoObj
    }

    __New(packageNameOrInfo, packageDir, projectPackage := "") {
        packageInfo := ""
        packageName := ""

        if (packageNameOrInfo.HasBase(PackageInfoBase.Prototype)) {
            packageInfo := packageNameOrInfo
            packageName := packageInfo.Name
        } else {
            packageName := packageNameOrInfo
        }

        this.packageName := packageName
        this.packageDir := packageDir

        if (projectPackage) {
            this.projectPackageObj := projectPackage
        }

        if (packageInfo) {
            this.packageInfoObj := packageInfo
        } else {
            this.CreatePackageInfo()
        }
    }

    CreatePackageInfo() {
        this.packageInfoObj := JsonDataPackageInfo(this.InfoFilePath)
    }
}
