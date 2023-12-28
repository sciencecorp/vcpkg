# vcpkg

A vcpkg port registry for Science.


## How to use

The ports in this registry are consumed as overlay ports. To use them:

```bash
# clone this repo in your favorite location
# e.g. `git clone git@github.com:sciencecorp/vcpkg.git`

# cd into the repo
cd vcpkg

# add repo to path in current session (will not persist)
export PATH=$PATH:$(pwd)

# or, persist (bash)
echo "export PATH=\$PATH:$(pwd)" >> ~/.bashrc
source ~/.bashrc

# or, persist (zsh)
echo "export PATH=\$PATH:$(pwd)" >> ~/.zshenv
source ~/.zshenv
```

