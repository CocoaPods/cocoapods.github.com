## Creating your own repository

A specification repository is a simple collection of podspec files organized with the following structure:

```
NAME/VERSION/NAME.podspec
```

```console
$ cd ~/.cocoapods/master
$ tree | head
.
└── A2DynamicDelegate
    └── 1.0
        └── A2DynamicDelegate.podspec
        1.0.1
        └── A2DynamicDelegate.podspec
        1.0.2
        └── A2DynamicDelegate.podspec
        1.0.3
        └── A2DynamicDelegate.podspec
```

Although the master repo is backed by a git repository, this is not required. For a repository to be valid it is only required to respect the above described file structure.

CocoaPods stores its repositories in the `~/.cocoapods/` folder.

### Adding a new repo

###### Manually

1. Make a folder with the name of the repo in `~/.cocoapods/`.
2. Populate the repository with podspecs respecting the required folder structure.

###### From an existing git remote

If you want to create a git backed repository you can use the `$ pod repo add` command.

### Disambiguation

If during the installation process is resolved a Pod whose required version is present in more than one repository, the alphabetical order of the names is used to disambiguate.

