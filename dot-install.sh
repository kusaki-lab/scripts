# scp ~/bin/git.install <host>:
# scp ~/bin/dot-install.sh <host>:
# ssh -t <host> ./git.install
# ssh -t <host> ./dot-install.sh

sudo apt update
sudo apt install curl
curl https://raw.githubusercontent.com/kusaki-lab/dotfiles/main/install.sh > install.sh
bash ./install.sh
rm ./install.sh
