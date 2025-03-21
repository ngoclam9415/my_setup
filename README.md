# My Setup
1. Install nescessary package
```sh
sudo apt-get install -y terminator
sudo apt-get install -y zsh
sudo apt-get install -y curl
sudo apt-get install -y git

sudo apt-get install gcc gcc+

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

2. Close terminal and install this package

```sh
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```


3. Installing Rye as python package manager
Download Rye
```sh
curl -fsSL https://rye-up.com/get | bash
```
Add Shims to Path
```sh
echo 'source "$HOME/.rye/env"' >> ~/.zshrc
```
Shell completion
```sh
source ~/.zshrc
mkdir $ZSH_CUSTOM/plugins/rye
rye self completion -s zsh > $ZSH_CUSTOM/plugins/rye/_rye
```

4. Add the plugin to the list of plugins for Oh My Zsh to load (inside ~/.zshrc) and add miniconda path:
```sh
export PATH=$HOME/miniconda3/bin:$PATH
ZSH_THEME="gnzh"
...

plugins=(git zsh-autosuggestions rye)
```

5. Create **dev** env and run

```sh
conda init
```

6. Init git

```sh
git config --global user.email "ngoclam9415@gmail.com"
git config --global user.name "Lam Nguyen"
git config --global submodule.recurse true
```

7. Install unikey

```sh
sudo apt-get install ibus-unikey
ibus restart
```

### Optional for Trading

8. Install talib
```sh
sudo apt-get install clang
wget https://github.com/ta-lib/ta-lib/releases/download/v0.6.4/ta-lib_0.6.4_amd64.deb && sudo dpkg -i ta-lib_0.6.4_amd64.deb && rm ta-lib_0.6.4_amd64.deb
```

9. Create /data folder
```sh
sudo mkdir /data
sudo chmod -R 777 /data
```
