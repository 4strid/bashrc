# 4strid/bashrc

## queen of dotfiles

### How to use

Source `bashrc` in your .bashrc file.

The screen dance in `screen` — over ssh, always be in screen — attaches on
its own, but the logout half needs a hook, because `~/.bash_logout` is a
path only bash reads. Put this in yours:

    command -v screen_dance_out >/dev/null && screen_dance_out
    exit 0

### These scripts are Evil

My configuration changes a lot of default shell behavior including the
behavior of `cd` and other things. To avoid surprises, and to generally
know what you're signing up for you should probably read the scripts
before using any of it let alone all of it.

### Honestly?

You might be better served just copying the bits you like into your own .bashrc
Especially interesting are the `cd+` and `tryhard` functions as well as
my jazzy PS1 prompt.  You may find them... interesting, if nothing else.

I've annotated everything with dependencies so copy/install those too or
stuff will break.

(Mostly I want this in "the cloud" to keep my environment the same
between computers.)

*With love,*

- Astrid Ivy


#### See also
[4strid/pc](https://github.com/4strid/pc) for even more ridiculousness
