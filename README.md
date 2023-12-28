# vcpkg

A vcpkg port registry for Science.

## How to use

The ports in this registry are consumed as overlay ports. To use them:

```bash
# clone this repo in your favorite location
# e.g. `git clone git@github.com:sciencecorp/vcpkg.git`

# cd into the repo
cd vcpkg

# add repo's `ports/` to path in current session (will not persist)
export PATH=$PATH:$(pwd)/ports

# or, persist (bash)
echo "export PATH=\$PATH:$(pwd)/ports" >> ~/.bashrc
source ~/.bashrc

# or, persist (zsh)
echo "export PATH=\$PATH:$(pwd)/ports" >> ~/.zshenv
source ~/.zshenv
```
