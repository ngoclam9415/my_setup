# My Setup
1. Install nescessary package
```sh
sudo apt-get install -y terminator
sudo apt-get install -y zsh
sudo apt-get install -y curl
sudo apt-get install -y git

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

sudo apt-get install gcc gcc+
```

2. Close terminal and install this package

```sh
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```


3. Download and install miniconda from [this link](https://docs.conda.io/en/latest/miniconda.html)


4. Add the plugin to the list of plugins for Oh My Zsh to load (inside ~/.zshrc) and add miniconda path:
```sh
export PATH=$HOME/miniconda3/bin:$PATH

...

plugins=(zsh-autosuggestions)
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