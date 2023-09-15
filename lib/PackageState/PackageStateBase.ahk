class PackageStateBase {
    parametersObj := ""
    parentStateObj := ""
    packageNameStr := ""
    childStateObjects := Map()

    PackageName {
        get => this.packageNameStr
        set => this.packageNameStr := value
    }

    Parameters {
        get => this.parametersObj
        set => this.parametersObj := value
    }

    ParameterMap {
        get => this.parametersObj.Get()
        set => this.parametersObj.Replace(value)
    }

    ParentState {
        get => this.parentStateObj
        set => this.parentStateObj := value
    }

    IsParent {
        get => this.parentStateObj != ""
    }

    Status {
        get => this.parameters["status"]
        set => this.parameters["status"] := value
    }

    InstalledVersion {
        get => this.parameters["installed_version"]
        set => this.parameters["installed_version"] := value
    }

    __New(packageName, parentState := "", parameters := "") {
        this.packageNameStr := packageName

        if (parentState) {
            this.parentStateObj := parentState
        }

        if (!parameters) {
            parameters := ParameterBag()
        }

        this.parametersObj := parameters
    }

    LoadState(stateFilePath) {
        if (FileExist(stateFilePath)) {
            this._loadState(stateFilePath)
        }
    }

    _loadState(stateFilePath) {
        throw MethodNotImplementedException("PackageStateBase", "_loadState")
    }

    SaveState(stateFilePath) {
        this._saveState(stateFilePath)
    }

    _saveState(stateFilePath) {
        throw MethodNotImplementedException("PackageStateBase", "_saveState")
    }

    SetChildState(stateObj) {
        this.childStateObjects[stateObj.PackageName] := stateObj
    }

    GetChildState(packageName) {
        return this.childStateObjects.Has(packageName) ?
            this.childStateObjects[packageName] :
            ""
    }

    SyncChildStatesToParameters() {
        for , childStateObj in this.childStateObjects {
            this.Parameters["dependencies." . childStateObj.PackageName] := childStateObj.ParameterMap
        }
    }

    SyncParametersToChildStates() {
        for , childStateObj in this.childStateObjects {
            if (this.Parameters.Has("dependencies." . childStateObj.PackageName)) {
                childStateObj.ParameterMap := this.Parameters["dependencies." . childStateObj.PackageName]
            }
        }
    }
}
