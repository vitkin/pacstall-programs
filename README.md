# My Pacstall Programs

This is a personal repository for [Pacstall](https://github.com/pacstall/pacstall) packages.

## Adding this repository

To add this repository to your pacstall installation:

```bash
pacstall -A github:vitkin/pacstall-programs
```

## Maintaining this repository

This repository uses
[`srcinfo.sh`](https://github.com/pacstall/pacstall-programs/blob/master/scripts/srcinfo.sh)
to manage package metadata.

To add or update a package:

1. Create/Update your package in `packages/<name>/<name>.pacscript`.

2. Run the script to generate metadata:

    ```bash
    ./scripts/srcinfo.sh add <name>
    ```

> [!NOTE]
> If this is a new package, the command will fail asking you to
> `git add` the generated `.SRCINFO` file.
> Do so, then run the command again.

To regenerate the index for all packages:

```bash
./scripts/srcinfo.sh build all
```

## Packages

- **template-package**: A starting point for new packages.
