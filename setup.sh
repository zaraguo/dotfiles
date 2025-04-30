#!/bin/bash

# 设置脚本中断选项
set -e # 出现错误立即退出
set -u # 使用未声明变量时报错

# 创建工作文件夹
mkdir -p "$HOME/workspace"

# 启动网络代理（以来 clash）,不然后续一些安装会失败
export https_proxy=http://127.0.0.1:7890 http_proxy=http://127.0.0.1:7890 all_proxy=socks5://127.0.0.1:7890

# === 检查并安装 Homebrew ===
if ! command -v brew >/dev/null; then
  echo "📦 正在安装 Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # 添加 Homebrew 到 PATH（如果尚未存在）
  if ! grep 'eval "$(/opt/homebrew/bin/brew shellenv)"' ~/.zshrc; then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>~/.zshrc
    source ~/.zshrc
  fi
fi

# === 安装Oh My Zsh ===
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# === 基础依赖 ===
echo "🚀 正在安装基础依赖..."
brew update && brew upgrade

brew install --cask font-maple-mono-nf-cn
brew install --cask ghostty
brew install orbstack
brew install autojump

# Vim 相关安装
brew install neovim
# lazsyvim 安装
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git

# === pyenv & Python 3.8(后续的 dotfile python 版本不能超过 3.10)安装 ===
echo "🐍 安装 Python 环境..."
brew install pyenv
# 配置 pyenv 环境变量（如果尚未存在）
if ! grep 'export PYENV_ROOT' ~/.zshrc; then
  echo 'export PYENV_ROOT="$HOME/.pyenv"' >>~/.zshrc
  echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >>~/.zshrc
  echo 'eval "$(pyenv init --path)"' >>~/.zshrc
fi
# 安装 Python 3.8
if ! pyenv versions | grep 3.8; then
  pyenv install 3.8.16
  pyenv global 3.8.16
fi

# === dotfiles同步与初始化 ===
echo "📥 同步并初始化 dotfiles..."
DOTFILES_REPO="git@github.com:zaraguo/dotfiles.git"
DOTFILES_DIR="$HOME/workspace/dotfiles"
if [ -d "$DOTFILES_DIR" ]; then
  cd "$DOTFILES_DIR" && git pull origin master
else
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
fi
cd "$DOTFILES_DIR"
chmod +x ./install # 确保 install 脚本有执行权限
./install

# NVM & node 安装
echo "📥 安装 nvm & node ..."
if [[ ! -d "$HOME/.nvm" ]]; then
  brew install nvm
  source ~/.zshrc
fi
nvm install node

# SDKMAN & jdk 安装
echo "🐍 安装 JAVA 环境..."
if ! command -v sdk >/dev/null; then
  curl -s "https://get.sdkman.io" | bash
  source ~/.zshrc
fi
sdk install java 21.0.7-amzn

# 最后刷新shell配置
source ~/.zshrc
