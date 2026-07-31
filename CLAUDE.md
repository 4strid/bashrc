# CLAUDE.md

`4strid/bashrc` — the shell configuration for `ivy`, an Acer Aspire 5741G
running Arch. Sibling repo to [`4strid/pc`](https://github.com/4strid/pc),
which is `$HOME` itself and holds the dotfiles, `bin/` scripts and machine
notes.

This repo is **not** symlinked into place by `pc`'s `link.sh`. It is pulled in
by one line at the top of `~/.bashrc` (which *is* symlinked by `link.sh`):
`source $HOME/src/bashrc/bashrc` — the entry point that sources everything
else.

`sob` (defined in `reflekt`) re-sources `~/.bashrc`. After editing anything
here, that is how the change takes effect in an open terminal.

## This repo is the curse

`pc/CLAUDE.md` warns that the shell is heavily aliased and that grepping *that*
repo will not find an alias. This is where they actually live. Everything an
agent trips over on this machine is defined in these ten files, so changes here
are changes to the footing of every other task.

The README says it plainly and means it: *"These scripts are Evil."*

### Load order decides what bites a non-interactive shell

This is the single most useful thing to know about this repo. `bashrc` sources
in this order:

```sh
source $BASHRC/functions
source $BASHRC/exports
source $BASHRC/aliases       # ← everything above applies to ANY shell
source $BASHRC/shortcuts
source $BASHRC/reflekt

[[ $- != *i* ]] && return     # ← the interactive guard

source $BASHRC/shopts        # ← everything below is interactive-only
source $BASHRC/danger
```

Anything sourced above the guard reaches *every* shell — scripts, cron, coding
agents. Anything below it exists only in a terminal a human is sitting at.
That asymmetry is not a set of quirks to memorise case by case; it is just
this one file. When something behaves differently for a human than for an
agent, check which side of the guard it sits on before anything else.

The split is deliberate and load-bearing: `aliases` (above) holds new names
only, `danger` (below) holds everything that overrides a real command. Moving
a definition between those two files changes who it applies to — that is the
entire mechanism.

(A consequence worth knowing: `PS1` is built in `exports`, above the guard, but
interpolates `` `time` `` — which is only aliased in `danger`, below it. That
works solely because a prompt is never rendered non-interactively.)

### Never let a bare `sudo` run non-interactively

An agent shell has no TTY, so `sudo` cannot prompt. Three failures trip
`pam_faillock`, which then **rejects the correct password for 10 minutes**,
locking Astrid out of their own machine. It has happened twice, both times via
an alias below that silently prepended `sudo`.

If a command needs root, print it and let the human run it. Do not call `sudo`.

### What lives below the guard, and why

**Reorganised 2026-07-30.** Everything that shadows a real command or calls
`sudo` now lives in `danger`, below the guard. It used to live in `aliases`,
above it, which is why agents kept hanging on `cp -i` and tripping faillock.

| alias | expands to | why it's down there |
|---|---|---|
| `cp` | `cp -i` | **hangs forever** on a y/n that never comes |
| `mv` | `mv -i` | same |
| `ls` | `ls_or_cat` | a function, not `ls` |
| `cat` | `cat_or_ls` | a function, not `cat` |
| `cd` | `cd+` | wrapped |
| `grep` | `grep --exclude-dir=.git --exclude-dir=node_modules` | **silently** skips both — hides the stray `node_modules` that would have explained your bug |
| `tree` | `tree -C -I 'node_modules\|.git'` | forces colour, filters silently |
| `info` `lynx` | flags | shadow the real binary |
| `shutdown` | `sudo systemctl poweroff` | overrides the real `shutdown`; faillock trap |
| `restart` `suspend` | `sudo systemctl …` | `suspend` also overrides a bash builtin; faillock trap |
| `visudo` `umount` | `sudo …` | faillock trap |
| `time` | `date +%l:%M%P` | shadows timing for a human, not for an agent |

Verified in both directions: all of the above absent from `bash -lc`, and all
43 original aliases still present under `bash -ic`. `pacman` and `systemctl`
were `sudo`-aliased until 2026-07-29 and were removed for causing the lockouts.

**The invariant:** `aliases` may only define *new names*. If the name is also
a real binary or a shell builtin, or the body says `sudo`, it goes in `danger`.
Both files say so in their headers — keep it that way, or agent shells start
breaking again in ways nobody will connect back to this repo.

### a filter that isn't this repo's doing

Worth knowing so you don't misread a test: **Claude Code's shell snapshot
`unalias`es `grep`, `find` and `pkill`** regardless of what this repo does,
shadowing them with `ugrep`/`bfs`-backed builtins. So those three would be
absent from a Claude shell even if they were still above the guard.

That means Claude Code is *not* a valid place to test whether the guard works —
it strips three of the interesting names by itself. Use `bash -lc` for that; it
gets whatever `aliases` actually defines, with no harness in the way.

### Escape hatches

`exports` defines un-aliased forms. Bash expands aliases on the literal token,
so `$CP` is **never** alias-expanded — the reliable way to reach the real
binary:

| var | value |
|---|---|
| `$LS` | `ls --color=auto --hide="lost+found"` |
| `$CP` | `cp` — no `-i`, will not hang |
| `$RM` | `rm` |
| `$CAT` | `cat` |
| `$CD` | `cd` |

Absolute paths (`/usr/bin/cp`) work equally well and read clearer in scripts.
Prefer either over the bare command.

## Layout

| file | what |
|---|---|
| `bashrc` | entry point; sources the rest in the order above |
| `functions` | the bulk of it (~15K) — `cd+`, `tryhard`, `setadd`, `ls_or_cat`, `ok`, `batcolor`, `inception`, `screenshot` |
| `exports` | `PATH`, `NODE_PATH`, escape hatches, colours, `PS1` |
| `aliases` | **new names only** — `la`, `wifi`, `stop`, `desktop`, `vimrc`, `tree~`. above the guard, so these reach scripts and agents |
| `shortcuts` | one- and two-letter aliases (`g`, `t`, `v`, `n`, `:q`, `:e`) |
| `reflekt` | self-editing helpers — `sob`, and `_reflect_edit` to jump into a section |
| `shopts` | every `shopt` with a verdict beside it; interactive-only |
| `danger` | "things that could hurt people" — every override of a real command, and every `sudo`. below the guard, so humans only |
| `.bashvimrc` | vim settings for editing these |

`PATH` puts `~/bin` and `~/.npm/packages/bin` ahead of the system, so npm-global
binaries win over pacman's. `NODE_PATH` points at the global npm prefix so a
config living in `$HOME` — notably `~/eslint.config.js` — can resolve
globally-installed modules; without it `require("@eslint/js")` fails.

## Editing conventions

- Every file opens with a comment block listing its **dependencies**, including
  binaries (`/bin/vim`) and other functions defined here. Keep that block
  current when adding something — it is the only dependency manifest there is.
- Comments are informal and often jokes. Match the register; don't sand it down
  into corporate prose.
- Commit messages are lowercase, informal, and explain *why*.
- Old commits carry an older email on purpose — **never rewrite history to
  normalize author identity.** It was true when written.
- `.claude/` is gitignored.

## The machine

Machine-wide hazards live in `pc/CLAUDE.md` and are not duplicated here. The
one worth carrying: `/` is a **55G filesystem inside a 92G partition** (38G
unclaimed, `resize2fs` was never run) and `/home` is not separate, so headroom
is thinner than it looks. Run `df -h /` before anything that writes a lot.

## All tasks

Getting the thing working is the middle of a task, not the end. Close every
one with this sequence:

**1. Commit.** Part of the close sequence, not a separate request — don't leave
a dirty tree and report the job done. Work often spans this repo and
`~/src/pc`; each needs its own commit. Push only if asked.

**2. Post-mortem, then write it down.** Ask one question: *was there a step in
this task I would not have needed to take — or a wrong turn I would not have
taken — if CLAUDE.md had already told me something?* If yes, add it here (or to
`pc/CLAUDE.md` if it belongs there), and include it in the same commit.

Write the instruction **generally**. The next reader needs the rule that
prevents the trap, not a report of the incident that revealed it:

- ✗ "`cp` hung when I ran it in a script" — an anecdote
- ✓ "aliases sourced above the interactive guard in `bashrc` reach agent
  shells; the ones below it don't" — a rule that catches the whole family

Bias toward writing it down. Anything that cost twenty minutes, or that
silently did nothing while appearing to work, earns three lines — the
silent-success failures especially, since nothing else will ever surface them.
