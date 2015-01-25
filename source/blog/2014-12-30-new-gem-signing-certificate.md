---
title: New RSpec Gem signing certificate
author: Sam Phippen
published: false
---

For the upcoming release of RSpec 3.2 we've created a new signing certificate
for the RSpec gems. The reason for this change is that 
[our old certificate](https://github.com/rspec/rspec/blob/6af4995482ade2d49ad361ee003dee29f713ab17/certs/rspec.pem)
expired. The new certificate can be found
[on GitHub](https://github.com/rspec/rspec/blob/858e0c2ac849d941bfd5b3a5c5e04a4f596fe666/certs/rspec.pem)
and has a 10 year expiry, so you can expect it to be used to verify all of the
RSpec gems for a while.

With the new certificate comes a new way of our end users ensuring that the
certificate is the correct one. A number of the RSpec core team members
will be adding [detatched GPG signatures](https://www.gnupg.org/gph/en/manual.html#AEN161) to
the core RSpec gem repository. This way, if you meet one of them in real life, you can
validate that the certificate that you have is the same one we hosted. The first signature
[mine](https://github.com/rspec/rspec/blob/858e0c2ac849d941bfd5b3a5c5e04a4f596fe666/certs/samphippen.asc) is
available on GitHub now. If I meet you at any conference, I'll be happy to do a key signing
with you so that you can ensure that you've got the real certificate.

Over the next few months, we'll be adding more signatures from other members of
the core team so that it is easier for you to validate the certificate.
