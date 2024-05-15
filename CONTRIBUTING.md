# Freeze Code plugin contributions

Welcome everyone and thank you for wanting to contribute to this project.

I hope that everyone here, **remembers to always follow the
[code of conduct](https://github.com/AlejandroSuero/freeze-code.nvim/blob/main/CODE_OF_CONDUCT.md#contributor-covenant-code-of-conduct)**.

## Dependencies

This project uses [selene](https://github.com/Kampfkarren/selene) as the
linter, [stylua](https://github.com/JohnnyMorganz/StyLua) as the formatter and
[vusted](https://github.com/notomo/vusted) as the test runner.

```bash
cargo install selene
cargo install stylua
luarocks --lua-version=5.1 install vusted
```

> [!warning]
>
> In **CI** we will be using [codespell](https://github.com/codespell-project/codespell)
> to check that all is correctly spelled, you can use `make spell` to check it
> locally and `make spell-write` to perform fixable changes automatically.

## How to contribute

1. **Configure the development**

   - **Fork this repo**: Make a fork of this repo. For that, click on the **Fork**
     button at the top right side of the main page for this GitHub repo.

   - **Clone your fork**: After the fork, make a clone of your repo `username/freeze-code.nvim`
     on your local machine, `git clone <fork-URL>`.

   - **Add the main repo as remote**: To keep up with the changes,
     `git remote add upstream <main-repo-URL>`.

2. **Work on your changes**

   - **Sync the fork**: You can do this from your fork's repo, using the GitHub UI,
     or using your terminal, `gh repo sync -b main` or
     `git switch main && git fetch upstream && git merge upstream/main`.

   - **Create a new branch**: Before working on your changes, create a new branch,
     using `git switch -c <branch-name>`.

   - **Make your changes**: Implement your changes on your local machine. Make sure
     to follow the project standards (linting and formatting rules).

   > You can use `make lint` and `make test` to check if your changes are correct.

3. **Send your changes**

- **Commit your changes**: Once you are satisfied with your changes, commit them
  with a descriptive and concise message. Following the standards like in the
  [Neovim repo](https://github.com/neovim/neovim/blob/master/CONTRIBUTING.md#commit-messages),
  [conventional commit guidelines](https://www.conventionalcommits.org/en/v1.0.0).

> [!caution]
>
> The commits will be linted on every push.

```COMMITMSG
type(scope): subject

Problem:
...

Solution:
...
```

> [!note]
> Some of the types are: `build ci docs feat fix perf refactor revert test`
>
> You can leave the **body** blank, but it is nice if a complex change occurs,
> you do provide a concise **body**.

```COMMITMSG
Problem:
...

Solution:
...
```

> [!warning]
> To indicate **BREAKING CHANGES**:

```COMMITMSG
refactor(installation)!: drop support for nvim-0.8

BREAKING CHANGE: refactor to use neovim's API supported only in v0.9 or higher
```

- **Push to your fork**: Push your changes to your fork using
  `git push origin <branch-name>`.

- **Create a Pull Request (PR)**: Once you pushed your changes, make a pull request
  so we can see the changes and discuss over it if necessary. A clear description
  of the changes is always welcomed.

## Good practices

- **Check for open issues**: Duplicated issues are never good.

- **Check for open PRs**: Make sure there isn't another PR open tackling a similar
  issue or creating a similar feature. You can always help in an open PR.

- **Descriptive and concised commits**: [conventional commit messages](https://www.conventionalcommits.org/en/v1.0.0).

- **Follow the code style**: Try to match the code style as much as possible. Follow
  lint and format rules. For `md` files, [markdownlint](https://github.com/markdownlint/markdownlint);
  for `lua` files, [selene](https://github.com/Kampfkarren/selene) and [stylua](https://github.com/JohnnyMorganz/StyLua)
