# VS Code Configuration

The settings must be placed at `~/.config/Code/User`

**Notice:** Do not forget to change the binary paths in the config.

- Run `wsl-ext.sh` if you have installed the extensions on windows and you want to only install those extensions that need to be installed separately on WSL.

- [Shortcut Cheatsheet (Windows)](https://code.visualstudio.com/shortcuts/keyboard-shortcuts-windows.pdf)
- [Another repo to find out more tips about VS Code](https://github.com/cavo789/vscode_tips)

## Export VSCode Extensions

```bash
code --list-extensions | xargs -L 1 echo code --install-extension # Unix

code --list-extensions | % { "code --install-extension $_" } # Windows PowerShell
```

### Shortcuts

- <kbd>Ctrl</kbd> + <kbd>n</kbd> Advanced New File.
- <kbd>Ctrl</kbd> + <kbd>q</kbd> Save All Opened Tabs.
- <kbd>Ctrl</kbd> + <kbd>k</kbd> Clear Command Line.
- <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>q</kbd> Closes Current Workspace/Folder.
- <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>l</kbd> Move cursor to end of the current line.
- <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>h</kbd> Move cursor to start of the current line.
- <kbd>Alt</kbd> + <kbd>l</kbd> Move cursor to right.
- <kbd>Alt</kbd> + <kbd>h</kbd> Move cursor to left.
- <kbd>Alt</kbd> + <kbd>k</kbd> Move cursor to up.
- <kbd>Alt</kbd> + <kbd>j</kbd> Move cursor to down.
- <kbd>Ctrl</kbd> + <kbd>UpArrow</kbd> Next Suggestion selector to up.
- <kbd>Ctrl</kbd> + <kbd>DownArrow</kbd> Next Suggestion selector to down.

### Fonts

- Dank Mono **(Font Family Primary)**
- JetBrains Mono
- Cascadia Code PL
- Operator Mono
- DejaVu Sans Mono
- Droid Sans Mono
- Hack (No Glyph)

### Themes

- Panda Theme **(Theme Primary)**
- halcyon **(Background For Custom Theme)**
- Monokai Pro
- Material Candy
- Guthub theme
- Flate
- Atom One Dark Theme
- Sublime material Theme

### Icons

- Fluent Icons **(Product Icon Primary)**
- Material Icon Theme **(File Icon Primary)**
- Material Theme Icons

### Suggested Extensions

- Tabnine AI Autocomplete (Alternative to GitHub Copilot)

### Extensions

- Advanced-new-file
- AREPL for python
- Auto Rename Tags
- Better comment
- Better TOML
- Code Runner
- CodeLLDB
- CodeSnap
- Color highlight
- Composer
- Crates
- CSS Peek
- Debugger for FireFox
- Dev Containers
- Docker
- Dotenv
- EditorConfig for VS Code
- Error Lens
- ES7+ React/Redux/React-Native snippets
- ESLint
- Excel viewer
- File Utils
- Git Extension Pack
- Git Graph
- Git Graph
- git history
- Github Pull Requests and issues
- Go
- Golang by aldijav
- Golang snippets
- Golang Snippets by honnamkuan
- Gremlins tracker for Visual Studio Code
- Hide files by Mouadh HSOUMI
- Html css support
- indent-rainbow
- isort
- JavaScript (ES6)
- JavaScript and TypeScript Nightly
- JSON Formatter
- Kubernetes
- Laravel blade formatter
- Laravel blade snippets
- Laravel extra intellisense
- Laravel goto view
- Laravel intellisense
- Laravel sinippets
- Live server
- Livewire goto
- Livewire Language SUpport
- Livewire Switcher
- Markdown All in One By Yu Zhang
- Markdown Preview Enhanced
- Markdownlint
- Multiple Cursor case preserve by Cardinal90
- Nginx Configuration Lang
- nginx-formatter
- Node.js Modules Intellisense
- npm intellisense
- Paste JSON as Code
- Path Intellisense
- PDF Viewer
- PHP awesome snippets
- php debug by xdebug
- php intelephense
- php intellisense
- php namespace resolver
- Placeholder Images
- Prettier - Code formatter
- Prettier ESLint
- Prisma
- Pylance
- Quokka.js
- Remote Development
- Rest client (Test back-end API)
- Rust syntax
- Rust-analyzer
- Sass by syler
- Save and Run
- SCSS intellisense
- Select until pattern
- shell-format
- shellman
- Simple React Snippets
- SQLite Viewer
- Tailwind CSS IntelliSense
- TallUI Laravel, PHP and TALL-Stack VScode Extensions
- Thunder Client
- Todo Tree
- Vetur
- Vscode-pets
- Vuter
- Willetts Tech - Theme (for PHP/CSS/JS)
- Windows Default Keybindings
- WSL
- XML
- YAML
- YAML sort by Pascal Reitermann
- ZipF5 - a zip file system

**DISABLED ONLY FOR USAGE:**

- Angular Language Service
- Angular Snippets (version 13)
- Apollo GraphQL
- Auto-Using for C#
- C/C++
- C# Namespace Autocompletion
- CMake
- CMake Tools
- CodeLLDB
- Dart
- Debugger for Unity
- Deno
- Deno Standard Library Snippets
- Extension pack for java
- Flutter
- flutter color
- flutter widget wrap
- GraphQL by GraphQL Foundation
- GraphQL by Maxime Quandalle
- GraphQL Language Support
- Jupyter
- Live Preiew
- Live Share
- Meteor
- Red hat commons
- Remote Server Protocol UI
- Shader languages support for VS Code
- ShaderlabVSCode(Free)
- Unity Code Snippets By cemuka
- Unity Code Snippets By Kleber Silva
- Unity Snippets by Ycleptic Studios
- vscode-solution-explorer by Fernando Escolar
