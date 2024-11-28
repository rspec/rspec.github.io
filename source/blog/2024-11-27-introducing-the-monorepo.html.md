---
title: Introducing the RSpec monorepo, and some updates on the future of RSpec.
author: Jon Rowe
no_comments: true
publish: true
---

## The quick version

We're switching to a monorepo out of the `rspec/rspec` repository on Github. The `main`
branch is a combination of all the repos `main` branches, `dev` is rebased on this during
the transition phase with the intent of `main` becoming the default when this is complete.

Please switch any git dependencies to at least `main` if not `dev`.

## The full story...

Since the early days of RSpec, it has consisted of multiple gems. The trio of
`rspec-core`, `rspec-expectations` and `rspec-mocks` containing the bulk of
the code, with the `rspec` metagem just deferring to these, and eventually the
`rspec-support` gem containing shared code.

At the time of creation these were all individual repos, and they have remained as such over
the lifetime of RSpec. There is an additional core repository, `rspec-dev` that contains tools
for dealing with the multiple repositories, creating PRs with shared updates, dealing with our
various maintenance branches.

Over time this situation has made it harder to coordinate work, for example requiring pinning PRs
against each other; harder to fix simple issues, for example you can't just edit a CI file to fix
an issue, you have to do so in rspec-dev, run commands to run them against all repositories, then
rebase off a maintenance branch and do so again; and harder to perform releases beyond single
repository patch versions.

We have been wanting to combine the repositories into one for some time, and it was just a matter
of finding the "right time", one of our alumni Yuji Nakayama, who wrote a great upgrade tool for
RSpec 2 to 3, also created the repository_merger gem that makes this possible.

But somehow it was never the right time, so finally, we're just jumping in and doing it...

So from this week, RSpec is now a monorepo for all future development.

## Steps we intend to take

1. Make the `rspec` repo public, its been private as a work in progress but now we're ready for help.
2. Transfer any open issues from the various repositories to the monorepo, then prevent new ones from
   being opened, and update the repos' READMEs.
3. Work on bringing the build for `3-13-maintenance` across so patches can be issued from the monorepo,
   but if we fail at this we will publish and backport any patches required across to the old repositories.
4. Bring across the remaining rspec-dev tooling, for example documentation generation, into the monorepo.
5. Bring across any PRs that can be salvaged, this may seem harsh but some are quite stale at this
   point, and they can always be reopened once rebased off the new repository. This has honestly
   been the main pain point for switching to a monorepo.

## What's next?

After the monorepo has stabilised, with its `main` being the default branch, what else does the future
hold for RSpec?

Our immediate plan has always been to begin resurrecting the RSpec 4 work that has languished, but
pragmatism here leads me to say that some of those changes may be postponed, but the next version of
the core gems will be at least "a version of RSpec 4", with some of the things we previously wanted
to bring forward within it, and later improvements to follow.

Primarily though we will be using the opportunity to change our supported Ruby policy, previously we
have stuck with a very strict version of semver where we considered dropping Ruby versions a breaking
change, hence our current build supports all the way back to 1.8.7. Yes you heard that right. Pretty
prehistoric.

In RSpec 4 we will be changing that policy to "currently supported Rubies at time of minor release",
what this means is we may update the minimum required Ruby version in our gem specs on minor release
versions in future. Given our policy of only supporting the latest major/minor pair this means essentially
that once a Ruby version is end of life, maintenance support for it will cease in RSpec.

Again this may seem harsh given our previous "we will be the last to drop support" policy, but Ruby
has stabilised so much over the decade since we released RSpec 3, the inconsistencies in versions
are largely ironed out.. (barring the pretty consequential changes of keyword arguments from Ruby 2.x to 3.x)
and with our slow release cadence I think this is a sensible change for making it easier to maintain RSpec
for the next decade. We still won't rush to remove support for any widely used Ruby, but we are formally
stating we reserve the right to do so within our versioning policy.
