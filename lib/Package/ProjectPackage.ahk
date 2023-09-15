class ProjectPackage extends PackageBase {
    repositories := Map()
    knownPackages := Map()

    IsProject {
        get => true
    }

    ProjectDir {
        get => this.Dir
    }

    __New(projectDir) {
        super.__New(JsonDataPackageInfo(this.InfoFilePath), projectDir)
    }
}
