# 多平台打包支持总结

## 已添加的功能

### 1. Arch Linux PKGBUILD (`packaging/arch/PKGBUILD`)

用于 Arch Linux 及其衍生版的软件包构建。

**使用方法：**
```bash
cd packaging/arch
makepkg -si
```

**支持的发行版：**
- Arch Linux
- Manjaro
- EndeavourOS
- ArcoLinux

### 2. GitHub Actions 多平台构建 (`.github/workflows/linux-multi-distro.yml`)

自动构建多种格式的软件包。

**构建目标：**
- Ubuntu 22.04 (Qt 5.15)
- Debian 12 (Bookworm)
- Arch Linux (最新 Qt)
- AppImage
- .deb 包
- Arch PKG 包

**触发条件：**
- 手动触发 (workflow_dispatch)
- PR 修改相关文件
- master/main 分支推送

### 3. CircleCI 配置 (`.circleci/config.yml`)

提供与 GitHub Actions 类似的 CI 构建流程。

**工作流程：**
- build-ubuntu: Ubuntu 22.04 构建
- build-debian: Debian 12 构建
- build-arch: Arch Linux 构建
- package-appimage: AppImage 打包

### 4. AppImage 打包 (`scripts/packaging/build-appimage.sh`)

创建通用的 Linux AppImage 包。

**使用方法：**
```bash
./scripts/packaging/build-appimage.sh build/Release 2.0.0
```

**输出：**
- `enve-2.0.0-x86_64.AppImage`

**兼容性：**
- Ubuntu 20.04+
- Debian 11+
- Fedora 35+
- Arch Linux
- openSUSE Tumbleweed

### 5. Debian 包 (`scripts/packaging/build-deb.sh`)

创建 .deb 安装包。

**使用方法：**
```bash
./scripts/packaging/build-deb.sh build/Release 2.0.0
sudo dpkg -i enve_2.0.0_amd64.deb
```

**支持的发行版：**
- Ubuntu 20.04, 22.04, 24.04
- Debian 11, 12
- Linux Mint 20+
- Pop!_OS 20.04+

### 6. Arch 包 (`scripts/packaging/build-arch-package.sh`)

创建 Arch Linux 的 .pkg.tar.gz 包。

**使用方法：**
```bash
./scripts/packaging/build-arch-package.sh build/Release 2.0.0
sudo pacman -U enve-2.0.0-x86_64.pkg.tar.gz
```

### 7. 统一打包脚本 (`scripts/packaging/package-all.sh`)

一次性构建所有格式的软件包。

**使用方法：**
```bash
./scripts/packaging/package-all.sh build/Release 2.0.0
```

### 8. 桌面集成文件

- `org.maurycy.enve.desktop` - 桌面入口
- `org.maurycy.enve.xml` - MIME 类型定义

## 文件结构

```
enve/
├── .github/workflows/
│   └── linux-multi-distro.yml    # GitHub Actions 配置
├── .circleci/
│   └── config.yml                 # CircleCI 配置
├── packaging/
│   └── arch/
│       ├── PKGBUILD               # Arch PKGBUILD
│       └── fix-quazip-path.patch  # QuaZip 路径补丁
├── scripts/packaging/
│   ├── README.md                  # 打包文档
│   ├── build-appimage.sh          # AppImage 构建
│   ├── build-deb.sh               # Debian 包构建
│   ├── build-arch-package.sh      # Arch 包构建
│   └── package-all.sh             # 统一打包脚本
├── org.maurycy.enve.desktop       # 桌面文件
└── org.maurycy.enve.xml           # MIME 类型
```

## 构建流程

### 本地构建

1. **编译 enve:**
   ```bash
   ./scripts/ci/build-linux-baseline.sh
   ```

2. **打包：**
   ```bash
   # 构建所有格式
   ./scripts/packaging/package-all.sh build/Release 2.0.0
   
   # 或单独构建
   ./scripts/packaging/build-appimage.sh
   ./scripts/packaging/build-deb.sh
   ./scripts/packaging/build-arch-package.sh
   ```

### CI 自动构建

1. **GitHub Actions:**
   - 推送到 master 或创建 PR 时自动触发
   - 产物在 Actions 标签页下载

2. **CircleCI:**
   - 推送到 master 时自动触发
   - 产物在 CircleCI 界面下载

## 分发的软件包格式对比

| 格式 | 适用系统 | 优点 | 缺点 |
|------|----------|------|------|
| AppImage | 所有 Linux | 无需安装，便携 | 文件较大，需要 FUSE |
| .deb | Debian/Ubuntu | 系统集成好，依赖管理 | 仅限 Debian 系 |
| .pkg.tar.gz | Arch Linux | 与 pacman 集成 | 仅限 Arch 系 |
| PKGBUILD | Arch Linux | 可从 AUR 分发 | 需要编译时间 |

## 依赖处理

### 运行时依赖

所有打包脚本都声明了以下依赖：

- qt5-base
- qt5-multimedia
- qt5-svg
- qt5-webengine
- ffmpeg
- libmypaint
- gperftools
- libjson-c
- fontconfig
- freetype

### 构建时依赖

- qt5-tools
- qt5-webengine (构建)
- python
- curl
- patch
- make
- gcc/git

## 故障排除

### AppImage 无法运行

```bash
# 添加执行权限
chmod +x enve-*.AppImage

# 安装 FUSE (Ubuntu 22.04+)
sudo apt install libfuse2

# 或提取运行
./enve-*.AppImage --appimage-extract
cd squashfs-root
./AppRun
```

### .deb 包安装失败

```bash
# 修复依赖
sudo apt --fix-broken install

# 或使用 apt 安装
sudo apt install ./enve_2.0.0_amd64.deb
```

### Arch 包签名问题

```bash
# 临时禁用签名验证
sudo pacman -U --overwrite '*' enve-*.pkg.tar.gz
```

## 未来改进

1. **Fedora/RPM 支持** - 添加 .rpm 包构建
2. **Flatpak 支持** - 创建 Flatpak manifest
3. **Snap 支持** - 创建 snapcraft.yaml
4. **自动更新** - 集成更新检查机制
5. **代码签名** - GPG 签名软件包

## 相关文档

- [打包脚本 README](scripts/packaging/README.md)
- [GitHub Actions 工作流](.github/workflows/linux-multi-distro.yml)
- [CircleCI 配置](.circleci/config.yml)
- [PKGBUILD](packaging/arch/PKGBUILD)
