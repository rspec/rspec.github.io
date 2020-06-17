---
title: RSpec Branching Strategy
author: Jon Rowe
---

# The short version.

RSpec repositories will deprecate the use of `master` for the default branch
name. We will wait for a consensus on the new name for the default branch,
in particular what new default is choosen by Github.

If no other consensus is arrived at by 1st of August, `master` will be
renamed `main`. At that point all development effort will be based off
the new branch name, and use of `master` will illicit a warning on install
/ usage. All open PRs will be rebased.

# The long version.

RSpec's source code is hosted on Github. By default git, and thus Github has
historically used `master` as the name of the default, or main branch. This
term has sat uneasily on the minds of the team and with the recent community
led moves to eliminate this terminology from our technology stacks, we are going
to follow suit and rename this branch.

We currently favour `main` as the new name (it has shared muscle memory with
the old) but we also recognise that having community consensus around a
default name is important as it reduces the amount of surprise encountered by
developers. So we wil wait for the community to settle on a new default name,
in particular for Github to change their default, but if none has been
announced by 1st August we will use `main`.

We already have other branches in use for stable versions (e.g.
`3-9-maintenance`) and they will be unaffected.

Some people will believe this is an inconvience because `master` is used for
lots of things, but the term has its origins in the dominance of one person
over another, in particular in slavery and this change is about being
inclusive to all people.

## Implications

We have always encouraged the use of our main branch for getting pre-release
features before we release them as a group of gems, this means there are likely
people using the `master` branch via their Gemfiles. We will deprecate
`master` by means of notice in the documentation, and possibly a post install
/ on usage message from RSpec itself warning of the fact the branch will
become stale and not be updated further. Additionally we will look at
using branch protection rules preventing PRs against `master` from that date.

## Steps we intend to take.

1. Push `master` to `main` (or other new branch name).
2. Rebase all open PRs and update our builds.
3. Set the default to `main` (etc) for all RSpec repositories.
4. Push change deprecating `master` to `master`.
5. In the future (possibly when releasing RSpec 4) remove `master`.
