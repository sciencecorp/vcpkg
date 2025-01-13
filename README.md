# vcpkg

A vcpkg port registry for Science.

## How to use

The ports in this registry are consumed as overlay ports. To use them...

Anywhere on your machine:

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

Or, within a specific repo:

```bash
# Add this repo as a submodule
git submodule add git@github.com:sciencecorp/vcpkg.git

# Add this to your vcpkg.json
{
  ...,
  "vcpkg-configuration": {
    "overlay-ports": ["<path to>/vcpkg/ports"],
  }
}

# Or in a makefile, or before you run CMake, set
VCPKG_OVERLAY_PORTS=<path to your vcpkg submodule>/ports

# Then you'll be able to run
vcpkg install # as usual
```

## Updating a Port
When you update a port (either by updating the hash it represents or the logic to build) you must also update the `versions/baseline.json`.

You can simply increment the `port-version` field if you update the port. You should also update the `baseline` field if the version has changed.

Example:
- Original baseline.json:
  "my-lib": { "baseline": "1.2.3", "port-version": 0 }

- After changing build flags:
  "my-lib": { "baseline": "1.2.3", "port-version": 1 }

- After upgrading to new version:
  "my-lib": { "baseline": "1.2.4", "port-version": 0 }