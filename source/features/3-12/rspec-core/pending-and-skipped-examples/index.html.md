---
layout: "feature_index"
---

# Pending and Skipped examples

Sometimes you will have a failing example that can not be fixed, but is useful to keep around. For instance, the fix could depend on an upstream patch being merged, or the example is not supported on JRuby. RSpec provides two features for dealing with this scenario.

An example can either be marked as _skipped_, in which is it not executed, or _pending_ in which it is executed but failure will not cause a failure of the entire suite. When a pending example passes (i.e. the underlying reasons for it being marked pending is no longer present) it will be marked as failed in order to communicate to you that it should no longer be marked as pending.
